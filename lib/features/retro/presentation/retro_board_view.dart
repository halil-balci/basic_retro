import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/retro_thought.dart';
import 'retro_view_model.dart';

class RetroBoardView extends StatefulWidget {
  final String sessionId;

  const RetroBoardView({
    super.key,
    required this.sessionId,
  });

  @override
  State<RetroBoardView> createState() => _RetroBoardViewState();
}

class _RetroBoardViewState extends State<RetroBoardView> {
  final Map<String, TextEditingController> _controllers = {
    'Sad': TextEditingController(),
    'Mad': TextEditingController(),
    'Glad': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<RetroViewModel>();
    viewModel.selectSession(widget.sessionId);
  }

  @override
  void dispose() {
    final viewModel = context.read<RetroViewModel>();
    // Make sure to leave the session and clean up
    if (viewModel.currentSessionId != null) {
      viewModel.leaveSession();
    }
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.currentSession == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  'Retro: ${viewModel.currentSession?.name ?? ""}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                _buildActiveUsers(viewModel),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Session ID: ${widget.sessionId}'),
                      action: SnackBarAction(
                        label: 'Copy',
                        onPressed: () {
                          // TODO: Add clipboard functionality
                        },
                      ),
                    ),
                  );
                },
                tooltip: 'Share session',
              ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBoard(viewModel),
        );
      },
    );
  }

  Widget _buildActiveUsers(RetroViewModel viewModel) {
    final activeUsers = viewModel.currentSession?.activeUsers ?? {};
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.person, size: 16),
        const SizedBox(width: 4),
        Text('${activeUsers.length} active'),
        const SizedBox(width: 8),
        if (activeUsers.isNotEmpty)
          Tooltip(
            message: activeUsers.values.join(', '),
            child: const Icon(Icons.info_outline, size: 16),
          ),
      ],
    );
  }

  Widget _buildBoard(RetroViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCategoryColumn('Sad', Colors.green, viewModel),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryColumn('Mad', Colors.red, viewModel),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryColumn('Glad', Colors.blue, viewModel),
              ),
            ],
          ),
        ],
      ),
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
              category,
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
                hintText: 'Add a $category item...',
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
        .map((thought) => _ThoughtCard(thought: thought))
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

class _ThoughtCard extends StatelessWidget {
  final RetroThought thought;

  const _ThoughtCard({required this.thought});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              thought.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Removed authorName for anonymity
          ],
        ),
      ),
    );
  }
}
