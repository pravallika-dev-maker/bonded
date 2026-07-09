import 'package:flutter/material.dart';
import '../widgets/primary_cta_button.dart';

class ReflectionCompletionScreen extends StatelessWidget {
  const ReflectionCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF260D1A), Color(0xFF090204)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                const Icon(
                  Icons.favorite,
                  color: Color(0xFF911746),
                  size: 48,
                ),
                const SizedBox(height: 32),
                const Text(
                  '“You showed up for yourself today”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'We’ll be here tomorrow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF9E7E5A),
                  ),
                ),
                const Spacer(flex: 3),
                PrimaryCtaButton(
                  text: 'Go to home',
                  icon: null,
                  width: double.infinity,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
