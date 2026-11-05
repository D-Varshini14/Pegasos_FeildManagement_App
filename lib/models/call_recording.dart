class CallRecording {
  final String id;
  final String clientName;
  final String phoneNumber;
  final String filePath;
  final String fileName;
  final int durationSeconds;
  final DateTime dateTime;
  final String callType; // Outgoing, Incoming, Meeting
  String notes;
  final int? leadId;
  final int? taskId;
  final int? fileSizeBytes;

  CallRecording({
    required this.id,
    required this.clientName,
    required this.phoneNumber,
    required this.filePath,
    required this.fileName,
    required this.durationSeconds,
    DateTime? dateTime,
    this.callType = 'Outgoing',
    this.notes = '',
    this.leadId,
    this.taskId,
    this.fileSizeBytes,
  }) : dateTime = dateTime ?? DateTime.now();

  String get formattedDuration {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientName': clientName,
        'phoneNumber': phoneNumber,
        'filePath': filePath,
        'fileName': fileName,
        'durationSeconds': durationSeconds,
        'dateTime': dateTime.toIso8601String(),
        'callType': callType,
        'notes': notes,
        'leadId': leadId,
        'taskId': taskId,
        'fileSizeBytes': fileSizeBytes,
      };

  factory CallRecording.fromJson(Map<String, dynamic> json) => CallRecording(
        id: json['id'] ?? '',
        clientName: json['clientName'] ?? 'Unknown Client',
        phoneNumber: json['phoneNumber'] ?? '',
        filePath: json['filePath'] ?? '',
        fileName: json['fileName'] ?? '',
        durationSeconds: json['durationSeconds'] ?? 0,
        dateTime: json['dateTime'] != null
            ? DateTime.parse(json['dateTime'])
            : DateTime.now(),
        callType: json['callType'] ?? 'Outgoing',
        notes: json['notes'] ?? '',
        leadId: json['leadId'],
        taskId: json['taskId'],
        fileSizeBytes: json['fileSizeBytes'],
      );
}
