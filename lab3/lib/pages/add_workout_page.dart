import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/api_service.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final duration = int.tryParse(_durationController.text);
      final calories = int.tryParse(_caloriesController.text);

      if (duration == null || calories == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Durata și caloriile trebuie să fie numere valide')),
        );
        return;
      }

      final workout = Workout(
        type: _typeController.text,
        duration: duration,
        calories: calories,
        date: selectedDate.toIso8601String().split('T').first,
      );

      try {
        final savedWorkout = await ApiService.addWorkout(workout);
        Navigator.pop(context, savedWorkout);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la salvare: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Workout', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                color: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _typeController,
                          decoration: const InputDecoration(labelText: 'Type'),
                          validator: (value) => value == null || value.isEmpty ? 'Enter a type' : null,
                        ),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duration (min)'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter duration';
                            if (int.tryParse(value) == null) return 'Must be a number';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _caloriesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Calories'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter calories';
                            if (int.tryParse(value) == null) return 'Must be a number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                        TextButton(onPressed: _pickDate, child: const Text('Choose Date')),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.add),
                          label: const Text('Save Workout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
