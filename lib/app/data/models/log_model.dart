class ActivityLog {
  final String title;
  final String desc;
  final String timestamp;
  final String type; // 'warning', 'info'

  ActivityLog({required this.title, required this.desc, required this.timestamp, required this.type});

  Map<String, dynamic> toJson() => {
    'title': title,
    'desc': desc,
    'timestamp': timestamp,
    'type': type,
  };

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
    title: json['title'],
    desc: json['desc'],
    timestamp: json['timestamp'],
    type: json['type'],
  );
}