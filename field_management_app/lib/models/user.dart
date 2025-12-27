class User {
  final int id;
  final String name;
  final String email;
  final String employeeId;
  final String phone;
  final String role;
  final String zone;
  final int monthlyTasksCompleted;
  final int avgTimePerVisit;
  final int targetCompletion;
  final double customerFeedback;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.employeeId,
    required this.phone,
    required this.role,
    required this.zone,
    required this.monthlyTasksCompleted,
    required this.avgTimePerVisit,
    required this.targetCompletion,
    required this.customerFeedback,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      employeeId: json['employee_id'],
      phone: json['phone'] ?? '',
      role: json['role'],
      zone: json['zone'] ?? '',
      monthlyTasksCompleted: json['monthly_tasks_completed'] ?? 0,
      avgTimePerVisit: json['avg_time_per_visit'] ?? 0,
      targetCompletion: json['target_completion'] ?? 0,
      customerFeedback: (json['customer_feedback'] ?? 0.0).toDouble(),
    );
  }
}