import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/api_service.dart';

class EditWorkoutPage extends StatefulWidget {
  final Workout workout;

  const EditWorkoutPage({super.key, required this.workout});

  @override
  State<EditWorkoutPage> createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.workout.type);
    _durationController =
        TextEditingController(text: widget.workout.duration.toString());
    _caloriesController =
        TextEditingController(text: widget.workout.calories.toString());
    selectedDate = DateTime.tryParse(widget.workout.date) ?? DateTime.now();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final updated = Workout(
        id: widget.workout.id,
        type: _typeController.text,
        duration: int.parse(_durationController.text),
        calories: int.parse(_caloriesController.text),
        date: selectedDate.toIso8601String().split('T').first,
      );

      try {
        await ApiService.updateWorkout(updated);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la actualizare: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Workout', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
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
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          controller: _typeController,
                          decoration: const InputDecoration(labelText: 'Type'),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Duration (min)'),
                          validator: (value) =>
                              value == null || int.tryParse(value) == null
                                  ? 'Must be number'
                                  : null,
                        ),
                        TextFormField(
                          controller: _caloriesController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Calories'),
                          validator: (value) =>
                              value == null || int.tryParse(value) == null
                                  ? 'Must be number'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                        TextButton(
                          onPressed: _pickDate,
                          child: const Text('Choose Date'),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.save),
                          label: const Text('Update Workout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
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
