import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'reflection_completion_screen.dart';
import '../services/api_service.dart';

class ReflectionFlowScreen extends StatefulWidget {
  final int day;
  const ReflectionFlowScreen({super.key, required this.day});

  @override
  State<ReflectionFlowScreen> createState() => _ReflectionFlowScreenState();
}

class _ReflectionFlowScreenState extends State<ReflectionFlowScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  int _currentStep = 0;
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _currentSteps = [];
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await ApiService.getTodayQuestion();
      final data = response['data'] ?? response;
      
      final sessionIdRaw = data['session_id'] ?? data['sessionId'] ?? data['id'];
      final rawQuestions = data['questions'] ?? (data is List ? data : [data]);

      final List<Map<String, dynamic>> parsedSteps = [];
      for (var rq in rawQuestions) {
        if (rq is Map) {
          parsedSteps.add({
            'type': rq['question_type'] ?? rq['type'] ?? 'text',
            'question': rq['question_text'] ?? rq['question'] ?? 'Reflect on this moment...',
            'id': rq['id'] ?? rq['question_id'],
            'hint': rq['hint'] ?? 'Speak your heart...',
          });
        }
      }

      if (mounted) {
        setState(() {
          _sessionId = sessionIdRaw is int ? sessionIdRaw : int.tryParse(sessionIdRaw?.toString() ?? '');
          _currentSteps = parsedSteps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _nextStep(dynamic answer) {
    _showBondedAIFeedback();
  }

  void _showBondedAIFeedback() {
    final step = _currentSteps[_currentStep];
    final question = step['question'] as String;
    
    // Simulate AI Response based on the question
    String aiResponse = "That takes courage to admit. Remember, healing is a journey you both take step by step.";
    if (question.contains("Why are they taking this break?")) {
      aiResponse = "I hear your pain. It's natural to feel this way. But consider that your partner might also be overwhelmed and needing space to breathe, not just pulling away from you.";
    } else if (question.contains("What do you want to improve?")) {
      aiResponse = "That's a beautiful intention. Remember, true improvement comes from understanding their needs just as much as expressing your own. You're on the right path.";
    } else if (question.contains("rate your relationship?")) {
      aiResponse = "These numbers don't define you. A lower score is an opportunity, not a failure. They might be struggling to express themselves too.";
    } else if (question.contains("mistakes you made")) {
      aiResponse = "Owning your part takes immense courage. Remember, your partner has their struggles too, but your self-awareness here is the beautiful first step toward healing.";
    } else if (question.contains("What will I improve?")) {
      aiResponse = "A strong commitment. Make sure you're doing this not just to win them back, but to grow as an individual. They will notice the genuine change.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.90), // Darker, premium feel
      builder: (context) {
        return _BondedAIFeedbackOverlay(aiText: aiResponse);
      },
    ).then((_) {
      if (mounted) {
        if (_currentStep < _currentSteps.length - 1) {
          setState(() {
            _currentStep++;
          });
        } else {
          _finishDay();
        }
      }
    });
  }

  void _finishDay() {
    // Signal genuine completion back to the caller (main dashboard)
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: Stack(
        children: [
          // ── Breathing Background ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8 + (_breathingController.value * 0.4),
                      colors: const [
                        Color(0xFF260D1A),
                        Color(0xFF090204),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header / Back ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5E3A4B), size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'DAY ${widget.day} REFLECTION',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Color(0xFF9E7E5A),
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer for balance
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                          ),
                        )
                      : _errorMessage != null
                          ? Center(
                              child: Text(
                                'Error: $_errorMessage',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            )
                          : _currentSteps.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No reflection questions available today.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : _buildCurrentStep(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_currentStep >= _currentSteps.length) return const SizedBox.shrink();
    
    final step = _currentSteps[_currentStep];
    if (step['type'] == 'text') {
      return _ReflectionTextInput(
        key: ValueKey('step_$_currentStep'),
        question: step['question'],
        hint: step['hint'],
        onNext: _nextStep,
      );
    } else if (step['type'] == 'rating') {
      return _ReflectionRatingInput(
        key: ValueKey('step_$_currentStep'),
        question: step['question'],
        categories: step['categories'] ?? ['Happiness', 'Trust', 'Communication'],
        onNext: () => _nextStep(null),
      );
    } else if (step['type'] == 'mistakes') {
      return _ReflectionMistakesInput(
        key: ValueKey('step_$_currentStep'),
        question: step['question'],
        options: step['options'] ?? ['Anger', 'Overthinking', 'Ego', 'Ignoring'],
        onNext: () => _nextStep(null),
      );
    }
    
    // Fallback to text input for unknown types
    return _ReflectionTextInput(
      key: ValueKey('step_$_currentStep'),
      question: step['question'] ?? 'Reflect...',
      hint: 'Speak your heart...',
      onNext: _nextStep,
    );
  }
}

class _ReflectionTextInput extends StatefulWidget {
  final String question;
  final String hint;
  final Function(String) onNext;

  const _ReflectionTextInput({
    super.key,
    required this.question,
    required this.hint,
    required this.onNext,
  });

  @override
  State<_ReflectionTextInput> createState() => _ReflectionTextInputState();
}

class _ReflectionTextInputState extends State<_ReflectionTextInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            widget.question,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 48),
          
          // ── Text Input Area ──
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              cursorColor: const Color(0xFF9E7E5A),
              cursorWidth: 1.2,
              showCursor: true,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: Color(0xFFDD8F9F),
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF3D1B28),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
          
          // ── Action Row (Mic & Next) ──
          // Use Padding with Media Query to ensure it doesn't feel cramped with keyboard
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 40.0,
            ),
            child: Row(
              children: [
                // Microphone Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0711),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF3D1627), width: 1),
                    ),
                    child: const Icon(Icons.mic_none_rounded, color: Color(0xFF9E7E5A), size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                // Next Button
                Expanded(
                  child: GestureDetector(
                    onTap: _controller.text.trim().isNotEmpty 
                        ? () => widget.onNext(_controller.text.trim()) 
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      decoration: BoxDecoration(
                        color: _controller.text.trim().isNotEmpty 
                            ? const Color(0xFF1A1214) 
                            : const Color(0xFF0D080A),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _controller.text.trim().isNotEmpty 
                              ? const Color(0xFF911746).withOpacity(0.5) 
                              : const Color(0xFF26151B),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                            color: _controller.text.trim().isNotEmpty
                                ? const Color(0xFFDD8F9F)
                                : const Color(0xFF5A3C47),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionRatingInput extends StatefulWidget {
  final String question;
  final List<String> categories;
  final VoidCallback onNext;

  const _ReflectionRatingInput({
    super.key,
    required this.question,
    required this.categories,
    required this.onNext,
  });

  @override
  State<_ReflectionRatingInput> createState() => _ReflectionRatingInputState();
}

class _ReflectionRatingInputState extends State<_ReflectionRatingInput> {
  final Map<String, double> _ratings = {};

  @override
  void initState() {
    super.initState();
    for (var cat in widget.categories) {
      _ratings[cat] = 5.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            widget.question,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: ListView(
              children: widget.categories.map((cat) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: const Color(0xFF911746),
                        inactiveTrackColor: const Color(0xFF1B0711),
                        thumbColor: const Color(0xFFDD8F9F),
                        overlayColor: const Color(0xFFDD8F9F).withOpacity(0.1),
                        trackHeight: 2,
                      ),
                      child: Slider(
                        value: _ratings[cat]!,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _ratings[cat]!.toInt().toString(),
                        onChanged: (val) {
                          setState(() {
                            _ratings[cat] = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: GestureDetector(
              onTap: widget.onNext,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1214),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF911746).withOpacity(0.5),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Finish Reflection',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                      color: Color(0xFFDD8F9F),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionMistakesInput extends StatefulWidget {
  final String question;
  final List<String> options;
  final VoidCallback onNext;

  const _ReflectionMistakesInput({
    super.key,
    required this.question,
    required this.options,
    required this.onNext,
  });

  @override
  State<_ReflectionMistakesInput> createState() => _ReflectionMistakesInputState();
}

class _ReflectionMistakesInputState extends State<_ReflectionMistakesInput> {
  final Set<String> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            widget.question,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: widget.options.map((option) {
                final isSelected = _selectedOptions.contains(option);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedOptions.remove(option);
                      } else {
                        _selectedOptions.add(option);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF911746) : const Color(0xFF1B0711),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFDD8F9F) : const Color(0xFF3D1627),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: isSelected ? Colors.white : const Color(0xFF5E3A4B),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: GestureDetector(
              onTap: _selectedOptions.isNotEmpty ? widget.onNext : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: _selectedOptions.isNotEmpty 
                      ? const Color(0xFF1A1214) 
                      : const Color(0xFF0D080A),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _selectedOptions.isNotEmpty 
                        ? const Color(0xFF911746).withOpacity(0.5) 
                        : const Color(0xFF26151B),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                      color: _selectedOptions.isNotEmpty
                          ? const Color(0xFFDD8F9F)
                          : const Color(0xFF5A3C47),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BondedAIFeedbackOverlay extends StatefulWidget {
  final String aiText;
  const _BondedAIFeedbackOverlay({required this.aiText});

  @override
  State<_BondedAIFeedbackOverlay> createState() => _BondedAIFeedbackOverlayState();
}

class _BondedAIFeedbackOverlayState extends State<_BondedAIFeedbackOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Slower, more calming
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Aesthetic, warm, and elegant background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF331A24), // Warm, soft dark pinkish hue at top
                      Color(0xFF090204), // Deep dark base
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Beautiful Bonded AI Avatar
                    _BondedAIAvatar(animationController: _pulseController),
                    const SizedBox(height: 16),
                    const Text(
                      'BONDED AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0,
                        color: Color(0xFFF7C3CD), // Warm soft pink
                      ),
                    ),
                    const SizedBox(height: 56),
                    // AI Response Text
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 15 * (1 - value)),
                            child: Text(
                              widget.aiText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFFFF5F7), // Very soft warm white text
                                height: 1.4,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    // Tap to continue
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.7 + (_pulseController.value * 0.3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFF7C3CD).withOpacity(0.3),
                                width: 1,
                              ),
                              color: const Color(0xFFF7C3CD).withOpacity(0.05),
                            ),
                            child: const Text(
                              'Tap to continue',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFF7C3CD), // Soft pink
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        );
                      },
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
}

class _BondedAIAvatar extends StatelessWidget {
  final AnimationController animationController;
  const _BondedAIAvatar({required this.animationController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final pulse = animationController.value;
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Very gentle, diffused soft glow (not neon, just a subtle warmth)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF9D1D9).withOpacity(0.15 + (pulse * 0.1)),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              
              // The elegant, smooth orb
              Transform.translate(
                offset: Offset(0, -4 * pulse), // Delicate floating effect
                child: Container(
                  width: 72 + (pulse * 3),
                  height: 72 + (pulse * 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Soft, warm, elegant gradient (pearl-like)
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF0F3), // Pure soft warm white
                        Color(0xFFF7C3CD), // Light dusty pink
                        Color(0xFFE5A4B2), // Warm hue
                      ],
                    ),
                    boxShadow: [
                      // Inner/Outer soft shadows for a polished "pearl" finish
                      BoxShadow(
                        color: const Color(0xFFE5A4B2).withOpacity(0.3),
                        blurRadius: 20 + (pulse * 10),
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: -2,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: Center(
                    // A very subtle, cute inner element (a soft heart)
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.white.withOpacity(0.95),
                      size: 26,
                    ),
                  ),
                ),
              ),
              
              // Tiny, elegant orbiting/floating soft sparkles
              Transform.translate(
                offset: Offset(-30, -20 - (pulse * 4)),
                child: Opacity(
                  opacity: 0.7 - (pulse * 0.2),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFFFF0F3), size: 12),
                ),
              ),
              Transform.translate(
                offset: Offset(35, 25 + (pulse * 5)),
                child: Opacity(
                  opacity: 0.5 + (pulse * 0.3),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFF7C3CD), size: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
