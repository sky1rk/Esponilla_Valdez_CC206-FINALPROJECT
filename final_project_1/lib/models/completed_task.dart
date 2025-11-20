class CompletedTask {
  final String title;
  final DateTime completionDate;

  CompletedTask({required this.title, required this.completionDate});

  factory CompletedTask.fromJson(Map<String, dynamic> json) {
    return CompletedTask(
      title: json['title'] as String,
      completionDate: DateTime.parse(json['completionDate'] as String),
    );
  }
}
