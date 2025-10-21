import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
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
    final padding = context.responsivePadding;
    final titleSize = context.responsiveTitleSize;
    final fontSize = context.responsiveFontSize;
    
    // Responsive icon and card dimensions
    final iconSize = ResponsiveLayout.getResponsiveValue<double>(
      context: context,
      mobile: 60.0,
      tablet: 80.0,
      desktop: 100.0,
    );
    
    final maxWidth = ResponsiveLayout.getResponsiveValue<double>(
      context: context,
      mobile: 420.0,
      tablet: 500.0,
      desktop: 600.0,
    );
    
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
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: iconSize * 0.5,
                      ),
                    ),
                    SizedBox(height: padding),
                    Text(
                      'Retro Board',
                      style: TextStyle(
                        fontSize: titleSize + 8,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Collaborate and reflect with your team',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: padding * 2),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(padding * 1.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Join Session',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter a session name to join existing or create new',
                              style: TextStyle(
                                fontSize: fontSize - 1,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: padding),
                            TextField(
                              controller: _sessionNameController,
                              style: TextStyle(fontSize: fontSize),
                              decoration: const InputDecoration(
                                labelText: 'Session Name',
                                hintText: 'e.g., Sprint Planning 2024',
                                prefixIcon: Icon(Icons.meeting_room_rounded),
                              ),
                              onSubmitted: (_) => _handleSessionNameSubmit(),
                            ),
                            SizedBox(height: padding),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleSessionNameSubmit,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.isMobile ? 14 : 16,
                                ),
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
                                : Text(
                                    'Join Session',
                                    style: TextStyle(
                                      fontSize: fontSize,
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
