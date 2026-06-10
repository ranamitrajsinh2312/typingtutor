import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

// =========================================================================
// 🌊 SPLASH SCREEN — Animated, Attractive
// =========================================================================

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => SplashState();
}

class SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));

    _ctrl.forward();
    Timer(AppDurations.splashDelay, () => Get.offNamed(AppRoutes.dashboard));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B6E), Color(0xFF1A237E), Color(0xFF311B92)],
          ),
        ),
        child: Stack(children: [
          // Decorative circles
          Positioned(top: -60, right: -60, child: _decorCircle(200, Colors.white.withOpacity(0.04))),
          Positioned(bottom: -80, left: -80, child: _decorCircle(260, Colors.white.withOpacity(0.03))),
          Positioned(top: size.height * 0.35, right: -30, child: _decorCircle(120, Colors.white.withOpacity(0.05))),

          // Main content
          Center(child: AnimatedBuilder(animation: _ctrl, builder: (_, __) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ScaleTransition(scale: _scaleAnim, child: FadeTransition(opacity: _fadeAnim,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(AppAssets.appLogo, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.keyboard_alt_rounded,
                      color: Color(0xFF1A237E), size: 50)),
                ),
              )),

              const SizedBox(height: 32),

              // App name
              SlideTransition(position: _slideAnim, child: FadeTransition(opacity: _fadeAnim,
                child: Column(children: [
                  DefaultTextStyle(
                    style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                    child: AnimatedTextKit(
                      animatedTexts: [TypewriterAnimatedText(AppText.appTitle, speed: const Duration(milliseconds: 80), cursor: '|')],
                      isRepeatingAnimation: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(AppText.splashTagline, style: GoogleFonts.poppins(
                    color: const Color(0xFF80DEEA), fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(AppConfig.versionLabel, style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ]),
              )),

              const SizedBox(height: 60),

              FadeTransition(opacity: _fadeAnim, child: SizedBox(
                width: 36, height: 36,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                  strokeWidth: 2.5,
                  backgroundColor: Colors.white.withOpacity(0.15),
                ),
              )),
            ],
          ))),
        ]),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
