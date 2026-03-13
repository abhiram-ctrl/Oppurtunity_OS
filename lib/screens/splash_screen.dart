import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _navigateToHome();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3400));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.4,
            colors: [Color(0xFF1A1045), Color(0xFF0D0D1A)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative orbs
              Positioned(
                top: -60,
                right: -60,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFF6C63FF,
                        ).withOpacity(0.04 + _pulseController.value * 0.04),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFF4FACFE,
                        ).withOpacity(0.03 + _pulseController.value * 0.03),
                      ),
                    );
                  },
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo container with glow
                    AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF4FACFE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C63FF).withOpacity(
                                      0.35 + _pulseController.value * 0.2,
                                    ),
                                    blurRadius:
                                        30 + _pulseController.value * 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.rocket_launch_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.elasticOut,
                          duration: const Duration(milliseconds: 900),
                        )
                        .fadeIn(duration: const Duration(milliseconds: 400)),
                    const SizedBox(height: 28),
                    // App name with gradient
                    ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF4FACFE)],
                          ).createShader(bounds),
                          child: Text(
                            'OpportunityOS',
                            style: GoogleFonts.inter(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 500),
                          duration: const Duration(milliseconds: 500),
                        )
                        .slideY(
                          begin: 0.4,
                          end: 0,
                          delay: const Duration(milliseconds: 500),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 10),
                    // Tagline
                    Text(
                          'Find internships instantly.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.45),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 500),
                        )
                        .slideY(
                          begin: 0.4,
                          end: 0,
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 72),
                    // Progress bar
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C63FF),
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 1100),
                      duration: const Duration(milliseconds: 400),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading opportunities...',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.25),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 1200),
                      duration: const Duration(milliseconds: 400),
                    ),
                  ],
                ),
              ),
              // Bottom tagline
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child:
                    Center(
                      child: Text(
                        'Powered by AI • Updated Daily',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.2),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 1300),
                      duration: const Duration(milliseconds: 500),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
