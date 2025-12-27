class Task {
  final int id;
  final String title;
  final String description;
  final String type;
  final String location;
  final DateTime scheduledTime;
  final String status;
  final String? notes;
  final String assignedToName;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.scheduledTime,
    required this.status,
    this.notes,
    required this.assignedToName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      location: json['location'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      status: json['status'],
      notes: json['notes'],
      assignedToName: json['assigned_to_name'],
    );
  }
}