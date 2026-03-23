import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'retro_board_view.dart';
import 'retro_view_model.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with SingleTickerProviderStateMixin {
  final _sessionNameController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSessionNameSubmit() async {
    final name = _sessionNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a session name'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
        final currentSession = viewModel.currentSession;
        if (currentSession != null) {
          _navigateToBoard(currentSession.id);
        }
      } else {
        // Session doesn't exist, create a new one
        final session = await viewModel.createSession(name);

        if (!mounted) return;

        if (session != null) {
          _navigateToBoard(session.id);
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToBoard(String sessionId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RetroBoardView(sessionId: sessionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 24 : 48,
                vertical: 32,
              ),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(isSmall),
                    SizedBox(height: isSmall ? 24 : 32),
                    _buildTitle(isSmall),
                    SizedBox(height: isSmall ? 32 : 48),
                    _buildSessionCard(isSmall),
                    const SizedBox(height: 32),
                    _buildFeatures(isSmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isSmall) {
    return Container(
      width: isSmall ? 72 : 88,
      height: isSmall ? 72 : 88,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmall ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.dashboard_rounded,
        color: Colors.white,
        size: isSmall ? 40 : 48,
      ),
    );
  }

  Widget _buildTitle(bool isSmall) {
    return Column(
      children: [
        Text(
          'RetroBoard',
          style: GoogleFonts.inter(
            fontSize: isSmall ? 32 : 44,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Collaborate and reflect with your team',
          style: GoogleFonts.inter(
            fontSize: isSmall ? 14 : 17,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSessionCard(bool isSmall) {
    final maxWidth = isSmall ? double.infinity : 460.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 24 : 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.meeting_room_rounded,
                    color: Color(0xFF818CF8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Join or Create Session',
                  style: GoogleFonts.inter(
                    fontSize: isSmall ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a session name to join an existing one or create a new session.',
              style: GoogleFonts.inter(
                fontSize: isSmall ? 13 : 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _sessionNameController,
              style: GoogleFonts.inter(
                fontSize: isSmall ? 15 : 16,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: 'Session Name',
                labelStyle: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5),
                ),
                hintText: 'e.g., Sprint 42 Retro',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.25),
                ),
                prefixIcon: Icon(
                  Icons.tag_rounded,
                  color: Colors.white.withOpacity(0.4),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
                ),
              ),
              onSubmitted: (_) => _handleSessionNameSubmit(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isSmall ? 48 : 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSessionNameSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF6366F1).withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Join Session',
                            style: GoogleFonts.inter(
                              fontSize: isSmall ? 15 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures(bool isSmall) {
    final features = [
      _FeatureItem(Icons.edit_note_rounded, 'Collect', 'Add thoughts anonymously'),
      _FeatureItem(Icons.workspaces_rounded, 'Group', 'Group similar ideas together'),
      _FeatureItem(Icons.how_to_vote_rounded, 'Vote', 'Prioritize what matters'),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isSmall ? double.infinity : 460),
      child: Row(
        children: features.map((f) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(f.icon, color: Colors.white.withOpacity(0.5), size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    f.title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    f.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.35),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  _FeatureItem(this.icon, this.title, this.subtitle);
}
