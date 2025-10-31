import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/presentation/mixins/responsive_mixin.dart';
import 'retro_board_view.dart';
import 'retro_view_model.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with ResponsiveMixin {
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
    final isSmall = isSmallScreen(context);
    final padding = getResponsivePadding(context);
    final titleSize = getResponsiveTitleSize(context);
    final fontSize = getResponsiveFontSize(context);
    final iconSize = getResponsiveIconSize(context, small: 40, large: 60);
    final spacing = getResponsiveSpacing(context);
    final borderRadius = getResponsiveBorderRadius(context);
    
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo section
                  _buildLogo(iconSize, borderRadius),
                  SizedBox(height: spacing * 2),
                  // Title section
                  _buildTitle(titleSize, fontSize, isSmall),
                  SizedBox(height: spacing * 3),
                  // Session card
                  _buildSessionCard(context, isSmall, padding, titleSize, fontSize, borderRadius),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build logo widget
  Widget _buildLogo(double iconSize, double borderRadius) {
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.dashboard_rounded,
        color: Colors.white,
        size: iconSize * 0.6,
      ),
    );
  }

  /// Build title section
  Widget _buildTitle(double titleSize, double fontSize, bool isSmall) {
    return Column(
      children: [
        Text(
          'Retro Board',
          style: TextStyle(
            fontSize: isSmall ? titleSize + 6 : titleSize + 8,
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
      ],
    );
  }

  /// Build session card
  Widget _buildSessionCard(
    BuildContext context,
    bool isSmall,
    double padding,
    double titleSize,
    double fontSize,
    double borderRadius,
  ) {
    final maxWidth = isSmall ? double.infinity : 450.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
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
                decoration: InputDecoration(
                  labelText: 'Session Name',
                  hintText: 'e.g., Sprint Planning 2024',
                  prefixIcon: const Icon(Icons.meeting_room_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                onSubmitted: (_) => _handleSessionNameSubmit(),
              ),
              SizedBox(height: padding),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSessionNameSubmit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmall ? 14 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
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
    );
  }
}
