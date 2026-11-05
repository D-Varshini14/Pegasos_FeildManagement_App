import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/call_recording.dart';
import '../services/call_recording_service.dart';
import '../providers/theme_provider.dart';
import '../utils/app_typography.dart';

class CallRecordingsScreen extends StatefulWidget {
  final int? filterLeadId;
  final int? filterTaskId;
  final String? initialClientName;
  final String? initialPhoneNumber;
  final bool autoStartRecording;

  const CallRecordingsScreen({
    super.key,
    this.filterLeadId,
    this.filterTaskId,
    this.initialClientName,
    this.initialPhoneNumber,
    this.autoStartRecording = false,
  });

  @override
  State<CallRecordingsScreen> createState() => _CallRecordingsScreenState();
}

class _CallRecordingsScreenState extends State<CallRecordingsScreen> {
  static const Color primaryBlue = Color(0xFF0F3A68);

  final CallRecordingService _service = CallRecordingService();
  final AudioPlayer _player = AudioPlayer();

  List<CallRecording> _recordings = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Playback state
  String? _currentlyPlayingId;
  PlayerState _playerState = PlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _completeSub;

  @override
  void initState() {
    super.initState();
    _initAudioListeners();
    _loadRecordings();

    // If autoStartRecording requested and prefilled client details provided, prompt recording
    if (widget.autoStartRecording &&
        widget.initialPhoneNumber != null &&
        widget.initialPhoneNumber!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNewRecordingDialog(
          prefillName: widget.initialClientName,
          prefillPhone: widget.initialPhoneNumber,
          leadId: widget.filterLeadId,
          taskId: widget.filterTaskId,
        );
      });
    }
  }

  void _initAudioListeners() {
    // Configure global AudioContext for uninterrupted media playback
    try {
      final AudioContext audioContext = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      );
      AudioPlayer.global.setAudioContext(audioContext);
      _player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Error setting AudioContext: $e');
    }

    _posSub = _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _currentPosition = pos);
    });

    _durSub = _player.onDurationChanged.listen((dur) {
      if (mounted && dur.inSeconds > 0) {
        setState(() => _totalDuration = dur);
      }
    });

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _playerState = state);
      }
    });

    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
          _playerState = PlayerState.completed;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _player.stop();
    _player.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecordings() async {
    setState(() => _isLoading = true);
    final list = await _service.getRecordings(
      query: _searchQuery,
      leadId: widget.filterLeadId,
      taskId: widget.filterTaskId,
    );
    if (mounted) {
      setState(() {
        _recordings = list;
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────
  // AUDIO PLAYBACK CONTROLS
  // ─────────────────────────────────────────

  Future<void> _togglePlay(CallRecording recording) async {
    final file = File(recording.filePath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio file not found on device'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_currentlyPlayingId == recording.id) {
      if (_playerState == PlayerState.playing) {
        await _player.pause();
      } else {
        await _player.resume();
      }
    } else {
      await _player.stop();
      final initialDurSec = recording.durationSeconds > 0 ? recording.durationSeconds : 1;
      setState(() {
        _currentlyPlayingId = recording.id;
        _currentPosition = Duration.zero;
        _totalDuration = Duration(seconds: initialDurSec);
        _playerState = PlayerState.playing;
      });

      try {
        await _player.play(DeviceFileSource(recording.filePath));

        // Read real duration from player and update if needed
        final dynamicDur = await _player.getDuration();
        if (dynamicDur != null && dynamicDur.inSeconds > 0 && mounted) {
          setState(() {
            _totalDuration = dynamicDur;
          });
          if (dynamicDur.inSeconds != recording.durationSeconds) {
            await _service.updateDuration(recording.id, dynamicDur.inSeconds);
            final idx = _recordings.indexWhere((r) => r.id == recording.id);
            if (idx != -1 && mounted) {
              setState(() {
                _recordings[idx] = CallRecording(
                  id: recording.id,
                  clientName: recording.clientName,
                  phoneNumber: recording.phoneNumber,
                  filePath: recording.filePath,
                  fileName: recording.fileName,
                  durationSeconds: dynamicDur.inSeconds,
                  dateTime: recording.dateTime,
                  callType: recording.callType,
                  notes: recording.notes,
                  leadId: recording.leadId,
                  taskId: recording.taskId,
                  fileSizeBytes: recording.fileSizeBytes,
                );
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Playback error: $e');
        if (mounted) {
          setState(() {
            _currentlyPlayingId = null;
            _playerState = PlayerState.stopped;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playback error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _seek(double val) async {
    final newPos = Duration(seconds: val.toInt());
    await _player.seek(newPos);
  }

  // ─────────────────────────────────────────
  // CALL HELPER
  // ─────────────────────────────────────────

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not call $phone'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─────────────────────────────────────────
  // DIALOGS & ACTIONS
  // ─────────────────────────────────────────

  void _showNewRecordingDialog({
    String? prefillName,
    String? prefillPhone,
    int? leadId,
    int? taskId,
  }) {
    final nameCtrl = TextEditingController(text: prefillName ?? '');
    final phoneCtrl = TextEditingController(text: prefillPhone ?? '');
    final notesCtrl = TextEditingController();

    bool isRecordingActive = false;
    int liveSeconds = 0;
    StreamSubscription? liveDurSub;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.mic, color: primaryBlue, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isRecordingActive ? 'Recording Call...' : 'Record or Attach Call',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A202C),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          if (isRecordingActive) {
                            _service.cancelRecording();
                          }
                          liveDurSub?.cancel();
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (!isRecordingActive) ...[
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Client Name *',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Call Notes / Purpose',
                        prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Choice 1: Start In-App Audio Recording
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.mic, color: Colors.white),
                        label: const Text('Start Recording Now',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter Client Name and Phone Number'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final started = await _service.startRecording(
                            clientName: nameCtrl.text.trim(),
                            phoneNumber: phoneCtrl.text.trim(),
                            leadId: leadId,
                            taskId: taskId,
                            notes: notesCtrl.text.trim(),
                          );

                          if (started) {
                            setSheetState(() {
                              isRecordingActive = true;
                              liveSeconds = 0;
                            });

                            liveDurSub = _service.onDurationChanged.listen((sec) {
                              setSheetState(() => liveSeconds = sec);
                            });
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Microphone permission required to record calls'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Choice 2: Attach Existing Audio File (from native Call Recorder)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.attach_file, color: primaryBlue),
                        label: const Text('Attach Audio File (From Native Recorder)',
                            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter Client Name and Phone Number'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(ctx);
                          final attached = await _service.attachRecordingFile(
                            clientName: nameCtrl.text.trim(),
                            phoneNumber: phoneCtrl.text.trim(),
                            leadId: leadId,
                            taskId: taskId,
                            notes: notesCtrl.text.trim(),
                          );

                          if (attached != null) {
                            await _loadRecordings();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Call recording attached successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ] else ...[
                    // Active Recording UI
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.12),
                            ),
                            child: const Center(
                              child: Icon(Icons.mic, color: Colors.red, size: 40),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            nameCtrl.text.trim(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            phoneCtrl.text.trim(),
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatSeconds(liveSeconds),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                              fontFeatures: [],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recording in progress... Make sure call is on speakerphone if recording in-app.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 12),
                          if (phoneCtrl.text.trim().isNotEmpty) ...[
                            OutlinedButton.icon(
                              icon: const Icon(Icons.phone_in_talk, size: 16, color: primaryBlue),
                              label: Text('Dial ${phoneCtrl.text.trim()} (Speakerphone)',
                                  style: const TextStyle(color: primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _makeCall(phoneCtrl.text.trim()),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.cancel, color: Colors.grey),
                                label: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  liveDurSub?.cancel();
                                  await _service.cancelRecording();
                                  Navigator.pop(ctx);
                                },
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.stop, color: Colors.white),
                                label: const Text('Stop & Save',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  liveDurSub?.cancel();
                                  final rec = await _service.stopRecording();
                                  Navigator.pop(ctx);
                                  if (rec != null) {
                                    await _loadRecordings();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Call recording saved!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditNotesDialog(CallRecording recording) {
    final notesCtrl = TextEditingController(text: recording.notes);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Call Notes'),
        content: TextField(
          controller: notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter notes about this conversation...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () async {
              await _service.updateNotes(recording.id, notesCtrl.text.trim());
              Navigator.pop(ctx);
              await _loadRecordings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notes updated successfully'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(CallRecording recording) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Recording'),
        content: Text('Are you sure you want to delete the recording for ${recording.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_currentlyPlayingId == recording.id) {
                await _player.stop();
                setState(() => _currentlyPlayingId = null);
              }
              await _service.deleteRecording(recording.id);
              Navigator.pop(ctx);
              await _loadRecordings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recording deleted'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatSeconds(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─────────────────────────────────────────
  // BUILD METHOD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Calculate total duration across all recordings
    final int totalSec = _recordings.fold(0, (sum, r) => sum + r.durationSeconds);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.filterLeadId != null
              ? 'Lead Call Recordings'
              : widget.filterTaskId != null
                  ? 'Visit Call Recordings'
                  : 'Call Recordings',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: themeProvider.isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRecordings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Summary Header
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        setState(() => _searchQuery = v);
                        _loadRecordings();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by client, phone, notes...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                  _loadRecordings();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overview Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.grey.withOpacity(0.05),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.record_voice_over, color: Colors.grey[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${_recordings.length} ${_recordings.length == 1 ? 'Recording' : 'Recordings'}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Total: ${_formatSeconds(totalSec)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Recordings List
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                    : _recordings.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadRecordings,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _recordings.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, index) => _buildRecordingCard(_recordings[index]),
                            ),
                          ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red[600],
        onPressed: () => _showNewRecordingDialog(
          prefillName: widget.initialClientName,
          prefillPhone: widget.initialPhoneNumber,
          leadId: widget.filterLeadId,
          taskId: widget.filterTaskId,
        ),
        icon: const Icon(Icons.mic, color: Colors.white),
        label: const Text('Record Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_in_talk_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No Call Recordings Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Record calls or attach recording files from your phone to review conversations anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.mic, color: Colors.white),
            label: const Text('Record or Attach Call', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _showNewRecordingDialog(
              prefillName: widget.initialClientName,
              prefillPhone: widget.initialPhoneNumber,
              leadId: widget.filterLeadId,
              taskId: widget.filterTaskId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingCard(CallRecording rec) {
    final bool isPlayingThis = _currentlyPlayingId == rec.id && _playerState == PlayerState.playing;
    final bool isCurrent = _currentlyPlayingId == rec.id;

    final durationSec = (isCurrent && _totalDuration.inSeconds > 0)
        ? _totalDuration.inSeconds
        : (rec.durationSeconds > 0 ? rec.durationSeconds : 1);
    final currentPosSec = isCurrent ? _currentPosition.inSeconds : 0;
    final sliderVal = currentPosSec.toDouble().clamp(0.0, durationSec.toDouble());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: isPlayingThis ? Colors.green : primaryBlue, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client info + call button + menu
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryBlue.withOpacity(0.1),
                child: Text(
                  rec.clientName.isNotEmpty ? rec.clientName[0].toUpperCase() : 'C',
                  style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.clientName,
                      style: AppTypography.cardTitle.copyWith(fontSize: 15, color: const Color(0xFF1A1A1A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          rec.phoneNumber,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Call Type Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      rec.callType.contains('Attached') ? Icons.file_present : Icons.phone_forwarded,
                      size: 11,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rec.formattedDuration,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Options Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (val) {
                  if (val == 'edit_notes') {
                    _showEditNotesDialog(rec);
                  } else if (val == 'call_again') {
                    _makeCall(rec.phoneNumber);
                  } else if (val == 'open_native') {
                    _openInNativePlayer(rec);
                  } else if (val == 'file_info') {
                    _showFileInfoDialog(rec);
                  } else if (val == 'delete') {
                    _showDeleteDialog(rec);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'call_again',
                    child: Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: primaryBlue),
                        SizedBox(width: 8),
                        Text('Call Client'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'open_native',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Open in System Player'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'file_info',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text('File Info & Path'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit_notes',
                    child: Row(
                      children: [
                        Icon(Icons.edit_note, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Edit Notes'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Recording', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (rec.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                rec.notes,
                style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Audio Player Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isPlayingThis ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 36,
                    color: isPlayingThis ? Colors.green : primaryBlue,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _togglePlay(rec),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      trackHeight: 3,
                      activeTrackColor: isPlayingThis ? Colors.green : primaryBlue,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: isPlayingThis ? Colors.green : primaryBlue,
                    ),
                    child: Slider(
                      min: 0.0,
                      max: durationSec > 0 ? durationSec.toDouble() : 1.0,
                      value: sliderVal,
                      onChanged: isCurrent
                          ? (v) => _seek(v)
                          : (v) {},
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isCurrent
                      ? '${_formatSeconds(currentPosSec)} / ${_formatSeconds(durationSec)}'
                      : rec.formattedDuration,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM yyyy • hh:mm a').format(rec.dateTime),
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
              GestureDetector(
                onTap: () => _makeCall(rec.phoneNumber),
                child: Row(
                  children: [
                    const Icon(Icons.phone_forwarded, size: 12, color: primaryBlue),
                    const SizedBox(width: 4),
                    const Text('Call Back',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryBlue)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openInNativePlayer(CallRecording rec) async {
    final file = File(rec.filePath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording file not found on device'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    try {
      final uri = Uri.file(rec.filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved at: ${rec.filePath}'),
              backgroundColor: primaryBlue,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File location: ${rec.filePath}'),
            backgroundColor: primaryBlue,
          ),
        );
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return 'Unknown size';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showFileInfoDialog(CallRecording rec) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: primaryBlue),
            SizedBox(width: 8),
            Text('Recording Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Client', rec.clientName),
              _infoRow('Phone', rec.phoneNumber),
              _infoRow('Duration', rec.formattedDuration),
              _infoRow('Recorded', DateFormat('dd MMM yyyy, hh:mm a').format(rec.dateTime)),
              _infoRow('File Size', _formatBytes(rec.fileSizeBytes ?? 0)),
              _infoRow('File Name', rec.fileName),
              const SizedBox(height: 10),
              const Text('Device Storage Location:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A202C))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  rec.filePath,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
            label: const Text('Open External', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(ctx);
              _openInNativePlayer(rec);
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
