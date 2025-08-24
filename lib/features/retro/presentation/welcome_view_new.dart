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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Retro Board',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Collaborate and reflect with your team',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Join Session',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter a session name to join existing or create new',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _sessionNameController,
                              decoration: const InputDecoration(
                                labelText: 'Session Name',
                                hintText: 'e.g., Sprint Planning 2024',
                                prefixIcon: Icon(Icons.meeting_room_rounded),
                              ),
                              onSubmitted: (_) => _handleSessionNameSubmit(),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleSessionNameSubmit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading 
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Join Session',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
