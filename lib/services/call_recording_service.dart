import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/call_recording.dart';

class CallRecordingService {
  static final CallRecordingService _instance = CallRecordingService._internal();
  factory CallRecordingService() => _instance;
  CallRecordingService._internal();

  AudioRecorder? _audioRecorder;
  AudioPlayer? _measuringPlayer;

  bool _isRecording = false;
  bool _isPaused = false;
  DateTime? _recordingStartTime;
  Timer? _durationTimer;
  int _currentSeconds = 0;

  // Active recording metadata
  String? _activeClientName;
  String? _activePhoneNumber;
  int? _activeLeadId;
  int? _activeTaskId;
  String? _activeNotes;
  String? _activeFilePath;

  final StreamController<int> _durationStreamController =
      StreamController<int>.broadcast();
  final StreamController<bool> _isRecordingStreamController =
      StreamController<bool>.broadcast();

  Stream<int> get onDurationChanged => _durationStreamController.stream;
  Stream<bool> get onRecordingStateChanged => _isRecordingStreamController.stream;

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  int get currentDurationSeconds => _currentSeconds;

  AudioRecorder get recorder {
    _audioRecorder ??= AudioRecorder();
    return _audioRecorder!;
  }

  // ─────────────────────────────────────────
  // USER ID HELPER
  // ─────────────────────────────────────────

  Future<String> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final userData = jsonDecode(userString);
        return userData['employeeId'] ??
            userData['id']?.toString() ??
            'default';
      }
    } catch (_) {}
    return 'default';
  }

  Future<String> _getStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recDir = Directory('${appDir.path}/call_recordings');
    if (!await recDir.exists()) {
      await recDir.create(recursive: true);
    }
    return recDir.path;
  }

  // ─────────────────────────────────────────
  // IN-APP RECORDING
  // ─────────────────────────────────────────

  Future<bool> hasPermission() async {
    try {
      return await recorder.hasPermission();
    } catch (e) {
      debugPrint('Error checking recording permission: $e');
      return false;
    }
  }

  Future<bool> startRecording({
    required String clientName,
    required String phoneNumber,
    int? leadId,
    int? taskId,
    String notes = '',
  }) async {
    try {
      if (_isRecording) {
        await cancelRecording();
      }

      final hasPerm = await hasPermission();
      if (!hasPerm) {
        debugPrint('Microphone permission denied for call recording');
        return false;
      }

      final dirPath = await _getStorageDirectory();
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'call_${cleanPhone}_$timestamp.m4a';
      final filePath = '$dirPath/$fileName';

      _activeClientName = clientName;
      _activePhoneNumber = phoneNumber;
      _activeLeadId = leadId;
      _activeTaskId = taskId;
      _activeNotes = notes;
      _activeFilePath = filePath;

      const recordConfig = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      );

      await recorder.start(recordConfig, path: filePath);

      _isRecording = true;
      _isPaused = false;
      _recordingStartTime = DateTime.now();
      _currentSeconds = 0;
      _isRecordingStreamController.add(true);
      _durationStreamController.add(0);

      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isPaused) {
          _currentSeconds++;
          _durationStreamController.add(_currentSeconds);
        }
      });

      return true;
    } catch (e) {
      debugPrint('Error starting call recording: $e');
      _isRecording = false;
      _isRecordingStreamController.add(false);
      return false;
    }
  }

  Future<void> pauseRecording() async {
    if (_isRecording && !_isPaused) {
      try {
        await recorder.pause();
        _isPaused = true;
      } catch (e) {
        debugPrint('Error pausing recording: $e');
      }
    }
  }

  Future<void> resumeRecording() async {
    if (_isRecording && _isPaused) {
      try {
        await recorder.resume();
        _isPaused = false;
      } catch (e) {
        debugPrint('Error resuming recording: $e');
      }
    }
  }

  Future<CallRecording?> stopRecording() async {
    if (!_isRecording) return null;

    _durationTimer?.cancel();
    _durationTimer = null;

    try {
      final path = await recorder.stop();
      _isRecording = false;
      _isPaused = false;
      _isRecordingStreamController.add(false);

      // Allow file buffer to completely flush to storage
      await Future.delayed(const Duration(milliseconds: 300));

      final finalPath = path ?? _activeFilePath;
      if (finalPath == null) return null;

      final file = File(finalPath);
      int fileSizeBytes = 0;
      if (await file.exists()) {
        fileSizeBytes = await file.length();
      }

      int durationSec = _currentSeconds > 0 ? _currentSeconds : 1;
      try {
        final probePlayer = AudioPlayer();
        await probePlayer.setSource(DeviceFileSource(finalPath));
        final measuredDur = await probePlayer.getDuration();
        if (measuredDur != null && measuredDur.inSeconds > 0) {
          durationSec = measuredDur.inSeconds;
        }
        await probePlayer.stop();
        await probePlayer.dispose();
      } catch (_) {}

      final fileName = finalPath.split(Platform.pathSeparator).last;
      final recording = CallRecording(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        clientName: _activeClientName ?? 'Client Call',
        phoneNumber: _activePhoneNumber ?? '',
        filePath: finalPath,
        fileName: fileName,
        durationSeconds: durationSec,
        dateTime: _recordingStartTime ?? DateTime.now(),
        callType: 'Outgoing',
        notes: _activeNotes ?? '',
        leadId: _activeLeadId,
        taskId: _activeTaskId,
        fileSizeBytes: fileSizeBytes,
      );

      await saveRecording(recording);
      _clearActiveData();
      return recording;
    } catch (e) {
      debugPrint('Error stopping call recording: $e');
      _clearActiveData();
      return null;
    }
  }

  Future<void> cancelRecording() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    if (_isRecording) {
      try {
        await recorder.stop();
        if (_activeFilePath != null) {
          final file = File(_activeFilePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      } catch (e) {
        debugPrint('Error canceling recording: $e');
      }
    }
    _clearActiveData();
  }

  void _clearActiveData() {
    _isRecording = false;
    _isPaused = false;
    _activeClientName = null;
    _activePhoneNumber = null;
    _activeLeadId = null;
    _activeTaskId = null;
    _activeNotes = null;
    _activeFilePath = null;
    _currentSeconds = 0;
    _isRecordingStreamController.add(false);
  }

  // ─────────────────────────────────────────
  // ATTACH/IMPORT EXISTING AUDIO FILE
  // ─────────────────────────────────────────

  Future<CallRecording?> attachRecordingFile({
    required String clientName,
    required String phoneNumber,
    int? leadId,
    int? taskId,
    String notes = '',
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['m4a', 'mp3', 'wav', 'aac', 'amr', 'opus', 'ogg'],
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final sourcePath = result.files.single.path!;
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return null;
      }

      final dirPath = await _getStorageDirectory();
      final originalName = result.files.single.name;
      final extension = originalName.contains('.')
          ? originalName.split('.').last
          : 'm4a';
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetFileName = 'attached_${cleanPhone}_$timestamp.$extension';
      final targetPath = '$dirPath/$targetFileName';

      // Copy file to app storage for permanence
      await sourceFile.copy(targetPath);
      final copiedFile = File(targetPath);
      final fileSize = await copiedFile.length();

      // Measure duration cleanly with a dedicated player that is immediately disposed
      int durationSec = 0;
      try {
        final probePlayer = AudioPlayer();
        await probePlayer.setSource(DeviceFileSource(targetPath));
        final duration = await probePlayer.getDuration();
        if (duration != null && duration.inSeconds > 0) {
          durationSec = duration.inSeconds;
        }
        await probePlayer.stop();
        await probePlayer.dispose();
      } catch (_) {
        // Fallback estimate based on file size if measurement fails
        if (fileSize > 0) {
          durationSec = (fileSize / 16000).round();
          if (durationSec < 1) durationSec = 1;
        }
      }

      final recording = CallRecording(
        id: 'rec_$timestamp',
        clientName: clientName.isNotEmpty ? clientName : 'Recorded Call',
        phoneNumber: phoneNumber,
        filePath: targetPath,
        fileName: targetFileName,
        durationSeconds: durationSec,
        dateTime: DateTime.now(),
        callType: 'Attached Recording',
        notes: notes,
        leadId: leadId,
        taskId: taskId,
        fileSizeBytes: fileSize,
      );

      await saveRecording(recording);
      return recording;
    } catch (e) {
      debugPrint('Error attaching call recording: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────
  // STORAGE & PERSISTENCE
  // ─────────────────────────────────────────

  Future<List<CallRecording>> getRecordings({String? query, int? leadId, int? taskId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final key = 'call_recordings_$userId';
      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonString);
      List<CallRecording> list = decoded
          .map((item) => CallRecording.fromJson(item as Map<String, dynamic>))
          .toList();

      // Filter by query if provided
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list.where((r) {
          return r.clientName.toLowerCase().contains(q) ||
              r.phoneNumber.toLowerCase().contains(q) ||
              r.notes.toLowerCase().contains(q);
        }).toList();
      }

      // Filter by leadId or taskId
      if (leadId != null) {
        list = list.where((r) => r.leadId == leadId).toList();
      }
      if (taskId != null) {
        list = list.where((r) => r.taskId == taskId).toList();
      }

      // Sort descending (latest first)
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    } catch (e) {
      debugPrint('Error loading call recordings: $e');
      return [];
    }
  }

  Future<void> saveRecording(CallRecording recording) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final key = 'call_recordings_$userId';

      final all = await getRecordings();
      // Remove any existing with same ID
      all.removeWhere((r) => r.id == recording.id);
      all.insert(0, recording);

      final encoded = jsonEncode(all.map((r) => r.toJson()).toList());
      await prefs.setString(key, encoded);
    } catch (e) {
      debugPrint('Error saving call recording: $e');
    }
  }

  Future<bool> deleteRecording(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final key = 'call_recordings_$userId';

      final all = await getRecordings();
      final targetIndex = all.indexWhere((r) => r.id == id);
      if (targetIndex != -1) {
        final rec = all[targetIndex];
        // Delete audio file on disk
        try {
          final file = File(rec.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}

        all.removeAt(targetIndex);
        final encoded = jsonEncode(all.map((r) => r.toJson()).toList());
        await prefs.setString(key, encoded);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting call recording: $e');
      return false;
    }
  }

  Future<void> updateNotes(String id, String notes) async {
    try {
      final all = await getRecordings();
      final index = all.indexWhere((r) => r.id == id);
      if (index != -1) {
        all[index].notes = notes;
        final prefs = await SharedPreferences.getInstance();
        final userId = await _getUserId();
        final key = 'call_recordings_$userId';
        final encoded = jsonEncode(all.map((r) => r.toJson()).toList());
        await prefs.setString(key, encoded);
      }
    } catch (e) {
      debugPrint('Error updating recording notes: $e');
    }
  }

  Future<void> updateDuration(String id, int durationSeconds) async {
    try {
      final all = await getRecordings();
      final index = all.indexWhere((r) => r.id == id);
      if (index != -1) {
        all[index] = CallRecording(
          id: all[index].id,
          clientName: all[index].clientName,
          phoneNumber: all[index].phoneNumber,
          filePath: all[index].filePath,
          fileName: all[index].fileName,
          durationSeconds: durationSeconds,
          dateTime: all[index].dateTime,
          callType: all[index].callType,
          notes: all[index].notes,
          leadId: all[index].leadId,
          taskId: all[index].taskId,
          fileSizeBytes: all[index].fileSizeBytes,
        );
        final prefs = await SharedPreferences.getInstance();
        final userId = await _getUserId();
        final key = 'call_recordings_$userId';
        final encoded = jsonEncode(all.map((r) => r.toJson()).toList());
        await prefs.setString(key, encoded);
      }
    } catch (e) {
      debugPrint('Error updating recording duration: $e');
    }
  }

  void dispose() {
    _durationTimer?.cancel();
    _durationStreamController.close();
    _isRecordingStreamController.close();
    _audioRecorder?.dispose();
    _measuringPlayer?.dispose();
  }
}
