import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'reflection_completion_screen.dart';
import '../services/api_service.dart';
import '../widgets/flying_fairy_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
      final status = await ApiService.getReflectionTodayStatus();
      if (status != null && (status['userCompleted'] == true || status['user_completed'] == true)) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1A1214),
              title: const Text("Already Completed", style: TextStyle(color: Color(0xFFFFF5F7))),
              content: const Text("Today's reflection has already been completed. Take time to sit with your thoughts and return tomorrow.", style: TextStyle(color: Color(0xFFE5A4B2))),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _finishDay();
                  },
                  child: const Text("OK", style: TextStyle(color: Color(0xFFDD8F9F))),
                )
              ],
            )
          );
        }
        return;
      }

      final response = await ApiService.getTodayQuestion();
      final data = response['data'] ?? response;
      
      final sessionIdRaw = data['session_id'] ?? data['sessionId'] ?? data['id'];
      
      List<dynamic> rawQuestions = [];
      if (data['questions'] != null && data['questions'] is List) {
        rawQuestions = data['questions'];
      } else if (data['question'] != null) {
        rawQuestions = [data['question']];
      } else if (data is List) {
        rawQuestions = data;
      } else {
        rawQuestions = [data];
      }

      final isMissedDay = data['is_missed_day'] ?? data['isMissedDay'] ?? false;
      if (isMissedDay && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Looks like a reflection is still waiting for you. Let's continue where you left off."),
            backgroundColor: Color(0xFF1A1214),
            duration: Duration(seconds: 4),
          ),
        );
      }

      final List<Map<String, dynamic>> parsedSteps = [];
      for (var rq in rawQuestions) {
        if (rq is Map) {
          parsedSteps.add({
            'type': rq['questionType'] ?? rq['question_type'] ?? rq['type'] ?? 'text',
            'question': rq['questionText'] ?? rq['question_text'] ?? rq['question'] ?? 'Reflect on this moment...',
            'id': rq['id'] ?? rq['question_id'],
            'hint': rq['hintText'] ?? rq['hint_text'] ?? rq['hint'] ?? 'Speak your heart...',
            'category': rq['categoryName'] ?? rq['category'] ?? 'Reflection',
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

  Future<void> _nextStep(dynamic answer) async {
    if (_sessionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session not found.')));
      }
      return;
    }
    
    final step = _currentSteps[_currentStep];
    final questionIdRaw = step['id'];
    if (questionIdRaw == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question ID not found.')));
      }
      return;
    }
    final int questionId = questionIdRaw is int ? questionIdRaw : int.tryParse(questionIdRaw.toString()) ?? 0;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFDD8F9F))),
    );

    try {
      final payload = {
        'sessionId': _sessionId,
        'questionId': questionId,
        'textAnswer': answer.toString(),
      };
      debugPrint('DEBUG - submitReflectionAnswer Payload: $payload');

      final response = await ApiService.submitReflectionAnswer(
        sessionId: _sessionId!,
        questionId: questionId,
        textAnswer: answer.toString(),
      );
      
      debugPrint('DEBUG - submitReflectionAnswer Response: $response');

      // Pop the loader
      if (mounted) Navigator.pop(context);

      final aiReaction = response['aiReaction'] as Map<String, dynamic>?;
      if (aiReaction != null) {
        debugPrint('DEBUG - Parsed aiReaction: $aiReaction');
        _showBondedAIFeedback(aiReaction);
      } else {
        throw Exception("Missing AI reaction from server.");
      }
    } catch (e) {
      // Pop the loader
      if (mounted) Navigator.pop(context);
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('already submitted')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You've already completed today's reflection. Come back tomorrow for a new question."),
              backgroundColor: Color(0xFF1A1214),
            ),
          );
          _finishDay();
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit answer: ${e.toString().replaceAll('Exception:', '').trim()}'),
            backgroundColor: const Color(0xFF93315C),
          ),
        );
      }
    }
  }

  void _showBondedAIFeedback(Map<String, dynamic> aiReaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.90), // Darker, premium feel
      builder: (context) {
        return _BondedAIFeedbackOverlay(aiReaction: aiReaction);
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.info_outline, color: const Color(0xFFDD8F9F).withOpacity(0.5), size: 48),
                                    const SizedBox(height: 16),
                                    Text(
                                      _errorMessage!.contains('No active relationship found') 
                                          ? "You don't have an active separation to reflect on right now. Head back to the dashboard to start one."
                                          : _errorMessage!.replaceAll('Exception: Network error: Exception:', '').replaceAll('Exception:', '').trim(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFDD8F9F),
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Go Back', style: TextStyle(color: Colors.white70)),
                                    ),
                                  ],
                                ),
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
        category: step['category'],
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
      category: step['category'] ?? 'Reflection',
      onNext: _nextStep,
    );
  }
}

class _ReflectionTextInput extends StatefulWidget {
  final String question;
  final String hint;
  final String category;
  final Function(String) onNext;

  const _ReflectionTextInput({
    super.key,
    required this.question,
    required this.hint,
    required this.category,
    required this.onNext,
  });

  @override
  State<_ReflectionTextInput> createState() => _ReflectionTextInputState();
}

class _ReflectionTextInputState extends State<_ReflectionTextInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isTyping = false;
  bool _isProcessing = false;
  Timer? _typingTimer;
  String _previousText = '';

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.requestFocus();
    _speech = stt.SpeechToText();
  }

  void _onTextChanged() {
    if (_controller.text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
    } else if (_controller.text.isEmpty && _isTyping) {
      setState(() => _isTyping = false);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isTyping = false);
    });
  }
  
  void _startSpeechListen() {
    if (!mounted) return;
    _previousText = _controller.text;
    if (_previousText.isNotEmpty && !_previousText.endsWith(' ') && !_previousText.endsWith('\n')) {
      _previousText += ' ';
    }
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (val) {
        if (mounted) {
          setState(() {
            final currentText = _previousText + val.recognizedWords;
            _controller.value = TextEditingValue(
              text: currentText,
              selection: TextSelection.collapsed(offset: currentText.length),
            );
          });
        }
      },
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          debugPrint('onStatus: $val');
          if (val == 'done' || val == 'notListening') {
             if (mounted) {
               setState(() { _isListening = false; _isProcessing = true; });
               Future.delayed(const Duration(milliseconds: 800), () {
                 if (mounted) setState(() => _isProcessing = false);
               });
             }
          }
        },
        onError: (val) {
          debugPrint('onError: $val');
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );
      if (available) {
        _startSpeechListen();
      }
    } else {
      setState(() {
        _isListening = false;
        _isProcessing = true;
      });
      _speech.stop();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  AnimatedOpacity(
                    opacity: _isTyping ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      widget.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _isTyping ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // ── Text Input Area ──
                  TextField(
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
                  
                  const SizedBox(height: 48),
                  
                  // Micro-interaction: "Take your time"
                  Center(
                    child: AnimatedOpacity(
                      opacity: (!_isTyping && _controller.text.isNotEmpty) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: const Text(
                        'Take your time...',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF4A343D),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // extra padding for scrolling
                ],
              ),
            ),
          ),
          
          // ── Action Row (Mic & Next) ──
          AnimatedOpacity(
            opacity: _isTyping ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 40.0,
              ),
              child: Row(
                children: [
                  // Microphone Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _listen();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isListening ? 64 : 56,
                      height: _isListening ? 64 : 56,
                      decoration: BoxDecoration(
                        color: _isListening ? const Color(0xFF911746).withValues(alpha: 0.2) : const Color(0xFF1B0711),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: _isListening ? const Color(0xFFDD8F9F).withValues(alpha: 0.8) : const Color(0xFF3D1627), 
                          width: _isListening ? 1.5 : 1.0,
                        ),
                        boxShadow: _isListening ? [
                          BoxShadow(
                            color: const Color(0xFFDD8F9F).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ] : [],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none_rounded, 
                        color: _isListening ? const Color(0xFFDD8F9F) : const Color(0xFF9E7E5A), 
                        size: _isListening ? 28 : 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text & Waveform OR Next Button
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _isListening
                          ? Row(
                              key: const ValueKey('listening'),
                              children: [
                                const Text(
                                  'Listening...',
                                  style: TextStyle(
                                    fontSize: 13, 
                                    color: Color(0xFFDD8F9F),
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _WaveformIndicator(),
                              ],
                            )
                          : _isProcessing
                              ? const Text(
                                  'Processing...',
                                  key: ValueKey('processing'),
                                  style: TextStyle(
                                    fontSize: 13, 
                                    color: Color(0xFFDD8F9F),
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : GestureDetector(
                                  key: const ValueKey('next_button'),
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
                                            ? const Color(0xFF911746).withValues(alpha: 0.5) 
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
                  ),
                ],
              ),
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
  final Map<String, dynamic> aiReaction;
  const _BondedAIFeedbackOverlay({required this.aiReaction});

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
    final String reactionText = widget.aiReaction['reactionText'] ?? widget.aiReaction['reaction_text'] ?? "Thank you for sharing.";
    final String emotion = widget.aiReaction['emotionDetected'] ?? widget.aiReaction['emotion_detected'] ?? "neutral";
    final String tone = widget.aiReaction['tone'] ?? "supportive";

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
                    // New Beautiful Flying Fairy Avatar
                    const FlyingFairyWidget(triggerSuccess: true),
                    const SizedBox(height: 56), // Increased whitespace
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
                              reactionText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 20, // Smaller text block for better readability
                                fontWeight: FontWeight.w400, // No bold/heavy font
                                color: Color(0xFFFFF5F7), // Very soft warm white text
                                height: 1.6, // More line height for readability
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

class _WaveformIndicator extends StatefulWidget {
  @override
  State<_WaveformIndicator> createState() => _WaveformIndicatorState();
}

class _WaveformIndicatorState extends State<_WaveformIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final delay = index * 0.2;
            final value = math.sin((_controller.value * 2 * math.pi) + (delay * math.pi));
            final height = 12.0 + (value * 8.0).abs();
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFDD8F9F),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
