import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/workout.dart';
import '../services/api_service.dart';
import 'add_workout_page.dart';
import 'workout_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Workout>> _workouts;
  String searchQuery = '';
  bool sortDescending = true;
  String? filterType;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    _workouts = ApiService.fetchWorkouts();
  }

  List<Workout> _processWorkouts(List<Workout> original) {
    List<Workout> filtered = original
        .where((w) => w.type.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (filterType != null && filterType!.isNotEmpty) {
      filtered = filtered.where((w) => w.type == filterType).toList();
    }

    filtered.sort((a, b) => sortDescending
        ? b.date.compareTo(a.date)
        : a.date.compareTo(b.date));

    return filtered;
  }

  Widget _buildPieChart(List<Workout> workouts) {
    final countByType = <String, int>{};
    for (var w in workouts) {
      countByType[w.type] = (countByType[w.type] ?? 0) + 1;
    }

    final sections = countByType.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: entry.key,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Text("Workout Types Distribution", style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: PieChart(PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Workout Manager',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWorkoutPage()),
              );
              if (result != null && result is Workout) {
                setState(() => _loadWorkouts());
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<List<Workout>>(
              future: _workouts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Eroare: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Niciun antrenament.', style: TextStyle(color: Colors.white)),
                  );
                }

                final workouts = _processWorkouts(snapshot.data!);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelText: 'Search by type',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        ),
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            dropdownColor: Colors.blueGrey[800],
                            value: filterType,
                            hint: const Text('Filter', style: TextStyle(color: Colors.white)),
                            style: const TextStyle(color: Colors.white),
                            icon: const Icon(Icons.filter_alt, color: Colors.white),
                            items: ['Running', 'Cycling', 'Swimming', 'Cardio', 'asd']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList()
                              ..insert(0, const DropdownMenuItem(value: null, child: Text('All'))),
                            onChanged: (value) => setState(() => filterType = value),
                          ),
                          IconButton(
                            onPressed: () => setState(() => sortDescending = !sortDescending),
                            icon: Icon(
                              sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    if (workouts.isNotEmpty) _buildPieChart(workouts),
                    Expanded(
                      child: ListView.builder(
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final w = workouts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                leading: const Icon(Icons.fitness_center, color: Colors.blueAccent),
                                title: Text('${w.type} (${w.duration} min)',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text('${w.calories} kcal • ${w.date}'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkoutDetailPage(workout: w),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() => _loadWorkouts());
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}