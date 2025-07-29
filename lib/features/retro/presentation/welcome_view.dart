import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'retro_board_view.dart';
import 'retro_view_model.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final _sessionNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSessionNameSubmit() async {
    final name = _sessionNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final viewModel = context.read<RetroViewModel>();
      
      // First try to join the session
      final joined = await viewModel.joinSession(name);
      
      if (!mounted) return;
      
      if (joined) {
        // Successfully joined existing session
        final currentSession = viewModel.currentSession;
        if (currentSession != null) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RetroBoardView(sessionId: currentSession.id),
            ),
          );
        }
      } else {
        // Session doesn't exist, create a new one
        final session = await viewModel.createSession(name);
        
        if (!mounted) return;
        
        if (session != null) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RetroBoardView(sessionId: session.id),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Retro Board',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter a session name to join or create',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Enter Session Name',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _sessionNameController,
                            decoration: const InputDecoration(
                              labelText: 'Session Name',
                              border: OutlineInputBorder(),
                              hintText: 'Enter session name to create or join',
                            ),
                            onSubmitted: (_) => _handleSessionNameSubmit(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _handleSessionNameSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: Text(_isLoading ? 'Please wait...' : 'Enter Session'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Recent Sessions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RecentSessionsList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createNewSession() async {
    final name = _sessionNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session name')),
      );
      return;
    }

    try {
      final viewModel = context.read<RetroViewModel>();
      final session = await viewModel.createSession(name);
      
      if (!mounted) return;
      
      if (session != null) {
        _sessionNameController.clear();
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RetroBoardView(sessionId: session.id),
          ),
        );
      }
      
      if (!mounted) return;
      
      if (session != null) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RetroBoardView(sessionId: session.id),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating session: $e')),
      );
    }
  }

  Future<void> _joinExistingSession() async {
    final sessionName = _joinCodeController.text.trim();
    if (sessionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session name')),
      );
      return;
    }

    try {
      final viewModel = context.read<RetroViewModel>();
      final joined = await viewModel.joinSession(sessionName);
      
      if (!mounted) return;
      
      if (joined) {
        final currentSession = context.read<RetroViewModel>().currentSession;
        if (currentSession != null) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RetroBoardView(sessionId: currentSession.id),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session with this name not found')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining session: $e')),
      );
    }
  }
}

class _joinCodeController {
  static var text;
}

class _CreateSessionCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCreateSession;

  const _CreateSessionCard({
    required this.controller,
    required this.onCreateSession,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create New Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Session Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  hintText: 'Enter a name for your session',
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onCreateSession,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Create Session'),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinSessionCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onJoinSession;

  const _JoinSessionCard({
    required this.controller,
    required this.onJoinSession,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Join Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Session Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  hintText: 'Enter the session name to join',
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onJoinSession,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Join Session'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSessionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        final sessions = viewModel.userSessions;

        if (sessions.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No recent sessions',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(session.name),
                subtitle: Text('ID: ${session.id}'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => RetroBoardView(
                          sessionId: session.id,
                        ),
                      ),
                    );
                  },
                  child: const Text('Join'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
