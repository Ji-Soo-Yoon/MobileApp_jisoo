class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double amount;
  final DateTime date;
  final String notes;
  final String businessPersonName;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.amount,
    required this.date,
    required this.notes,
    required this.businessPersonName,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      projectId: json['projectId'],
      taskId: json['taskId'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      businessPersonName: json['businessPersonName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'businessPersonName': businessPersonName,
    };
  }
}
