import 'package:flutter/material.dart';
import 'package:myibd_app/models/food_entry.dart';
import 'package:myibd_app/repositories/food_repository.dart';

class FoodFormScreen extends StatefulWidget {
  const FoodFormScreen({super.key});

  @override
  State<FoodFormScreen> createState() => _FoodFormScreenState();
}

class _FoodFormScreenState extends State<FoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodRepository = FoodRepository();
  
  DateTime _timestamp = DateTime.now();
  String _mealName = '';
  List<String> _ingredients = [];
  String _amount = 'some';
  String _category = 'lunch';
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void dispose() {
    _mealNameController.dispose();
    _ingredientController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientController.text.trim().isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text.trim());
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }
  
  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        final foodEntry = FoodEntry(
          userId: 'user123', // In real app, get from auth
          timestamp: _timestamp,
          mealName: _mealNameController.text,
          ingredients: _ingredients,
          amount: _amount,
          category: _category,
          notes: _notesController.text,
        );
        
        await _foodRepository.save(foodEntry);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food entry recorded')),
          );
          Navigator.pop(context, true); // Return true to indicate data was saved
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Food'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _timestamp,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_timestamp),
                    );
                    if (time != null) {
                      setState(() {
                        _timestamp = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Text('Select Date & Time: ${_timestamp.toString().substring(0, 16)}'),
              ),
              const SizedBox(height: 16),
              
              // Meal Name
              TextFormField(
                controller: _mealNameController,
                decoration: const InputDecoration(
                  labelText: 'Meal Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter meal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _category,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                  DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                  DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                  DropdownMenuItem(value: 'snack', child: Text('Snack')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Amount
              const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _amount,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'some', child: Text('Some')),
                  DropdownMenuItem(value: 'lots', child: Text('Lots')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _amount = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Ingredients
              const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      decoration: const InputDecoration(
                        hintText: 'Add ingredient',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addIngredient(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Ingredient list
              if (_ingredients.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _ingredients.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          dense: true,
                          title: Text(_ingredients[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _removeIngredient(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              
              // Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Save button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}