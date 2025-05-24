class Workout {
  final String? id;
  final String type;
  final int duration;
  final int calories;
  final String date;

  Workout({
    this.id,
    required this.type,
    required this.duration,
    required this.calories,
    required this.date,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id']?.toString(),
      type: json['type'] ?? '',
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration'].toString()) ?? 0,
      calories: json['calories'] is int ? json['calories'] : int.tryParse(json['calories'].toString()) ?? 0,
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'duration': duration,
      'calories': calories,
      'date': date,
    };
  }
}
