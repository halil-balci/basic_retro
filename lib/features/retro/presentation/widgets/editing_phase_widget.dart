import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/retro_thought.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';

class EditingPhaseWidget extends StatefulWidget {
  const EditingPhaseWidget({super.key});

  @override
  State<EditingPhaseWidget> createState() => _EditingPhaseWidgetState();
}

class _EditingPhaseWidgetState extends State<EditingPhaseWidget> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = Map.fromEntries(
      RetroConstants.categories.map((category) => 
        MapEntry(category, TextEditingController())),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Card(
                color: Colors.amber,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Editing Phase: Add your thoughts anonymously. Other participants\' thoughts are blurred.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: RetroConstants.categories.map((category) {
                  Color categoryColor;
                  switch (RetroConstants.categoryColors[category]) {
                    case 'green':
                      categoryColor = Colors.green;
                      break;
                    case 'red':
                      categoryColor = Colors.red;
                      break;
                    case 'blue':
                      categoryColor = Colors.blue;
                      break;
                    default:
                      categoryColor = Colors.grey;
                  }
                  
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: category != RetroConstants.categories.last ? 16 : 0,
                      ),
                      child: _buildCategoryColumn(category, categoryColor, viewModel),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryColumn(String category, Color color, RetroViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              RetroConstants.categoryTitles[category] ?? category,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controllers[category],
              decoration: InputDecoration(
                hintText: RetroConstants.categoryDescriptions[category] ?? 'Add a $category item...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addThought(category, viewModel),
                ),
              ),
              onSubmitted: (_) => _addThought(category, viewModel),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            ..._buildThoughtsList(category, viewModel),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildThoughtsList(String category, RetroViewModel viewModel) {
    return (viewModel.thoughtsByCategory[category] ?? <RetroThought>[])
        .map((thought) => _BlurredThoughtCard(
              thought: thought,
              shouldBlur: viewModel.shouldBlurThought(thought),
            ))
        .toList();
  }

  void _addThought(String category, RetroViewModel viewModel) async {
    final content = _controllers[category]?.text.trim() ?? '';
    if (content.isEmpty) return;

    try {
      await viewModel.addThought(content, category);
      _controllers[category]?.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding thought: $e')),
        );
      }
    }
  }
}

class _BlurredThoughtCard extends StatelessWidget {
  final RetroThought thought;
  final bool shouldBlur;

  const _BlurredThoughtCard({
    required this.thought,
    required this.shouldBlur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: shouldBlur
                  ? Stack(
                      children: [
                        Text(
                          thought.content,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.transparent,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.visibility_off,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      thought.content,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
