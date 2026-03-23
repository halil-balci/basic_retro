import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection.dart';
import 'features/retro/presentation/welcome_view.dart';
import 'features/retro/presentation/retro_board_view.dart';
import 'features/retro/presentation/retro_view_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Read session name from URL hash fragment (e.g. /#/Sprint%2042 → 'Sprint 42')
  static String? _getSessionNameFromUrl() {
    try {
      final uri = Uri.base;
      // Support hash-style /#/SESSION_NAME
      final hash = uri.fragment; // e.g. '/Sprint%2042'
      if (hash.startsWith('/') && hash.length > 1) {
        final raw = hash.substring(1);
        final decoded = Uri.decodeComponent(raw);
        if (decoded.isNotEmpty && decoded != 'home') return decoded;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final initialSessionName = _getSessionNameFromUrl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => getIt<RetroViewModel>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RetroBoard',
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        theme: _buildTheme(),
        // If launched with a session name in the URL, go directly to board
        home: initialSessionName != null
            ? _SessionEntryPoint(sessionName: initialSessionName)
            : const WelcomeView(),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6366F1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
    );
  }
}

/// Handles the case where the user lands on a session URL directly.
/// Joins the session by name and navigates to the board.
class _SessionEntryPoint extends StatefulWidget {
  final String sessionName;
  const _SessionEntryPoint({required this.sessionName});

  @override
  State<_SessionEntryPoint> createState() => _SessionEntryPointState();
}

class _SessionEntryPointState extends State<_SessionEntryPoint> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _joinSession());
  }

  Future<void> _joinSession() async {
    final viewModel = context.read<RetroViewModel>();
    try {
      final joined = await viewModel.joinSession(widget.sessionName);
      if (!mounted) return;

      if (joined && viewModel.currentSession != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RetroBoardView(sessionId: viewModel.currentSession!.id),
          ),
        );
      } else {
        // Session not found, go to welcome page
        setState(() => _failed = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeView()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _failed = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeView()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 24),
            if (!_failed) ...[
              const CircularProgressIndicator(color: Color(0xFF6366F1)),
              const SizedBox(height: 16),
              Text(
                'Joining "${widget.sessionName}"...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 40),
              const SizedBox(height: 12),
              Text(
                'Session not found',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Redirecting to home...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}