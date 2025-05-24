import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/workouts';

  static Future<List<Workout>> fetchWorkouts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((e) => Workout.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load workouts');
    }
  }

  static Future<Workout> addWorkout(Workout workout) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(workout.toJson()),
    );

    if (response.statusCode == 201) {
      return Workout.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add workout');
    }
  }


  static Future<void> deleteWorkout(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete workout');
    }
  }

  static Future<void> updateWorkout(Workout workout) async {
  if (workout.id == null) throw Exception('Workout ID is null');
  final url = '$baseUrl/${workout.id}';
  final response = await http.put(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(workout.toJson()),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to update workout');
  }
}

}
