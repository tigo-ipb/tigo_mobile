import 'package:flutter/material.dart';
import 'package:tigo_mobile/core/constants/app_theme.dart';
import 'package:tigo_mobile/features/pemesan/views/login/role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Staggered Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<Color?> _backgroundColor;
  late Animation<double> _contentFadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // 1. Logo Scale (0.0 to 1.2 seconds): 0% to 30% of timeline
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.30, curve: Curves.easeIn),
      ),
    );

    // 2. Text Slide & Fade In (1.2 to 2.2 seconds): 30% to 55% of timeline
    _textSlide = Tween<Offset>(begin: const Offset(0.0, 0.8), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.30, 0.40, curve: Curves.easeOutCubic),
          ),
        );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.40, curve: Curves.easeIn),
      ),
    );

    // 3. Background Color Transition (2.8 to 3.6 seconds): 70% to 90% of timeline
    _backgroundColor = ColorTween(begin: Colors.white, end: AppColors.sky500)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.70, 0.90, curve: Curves.easeInOut),
          ),
        );

    // 4. Content Fade Out (during background color transition to blue)
    _contentFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 0.85, curve: Curves.easeOut),
      ),
    );

    // Trigger navigation on animation completion
    _controller.forward().then((_) {
      _navigateToRolePage();
    });
  }

  void _navigateToRolePage() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RoleView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            color: _backgroundColor.value,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Opacity(
                opacity: _contentFadeOut.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo scale transition
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Image.asset(
                          'lib/assets/Logo Tigo.png',
                          width: 140,
                          height: 140,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Slogan slide & fade transition
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Text(
                          'Your Ticket on the Go!',
                          style: AppTextStyles.medium(
                            16,
                            AppColors.sky500,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
