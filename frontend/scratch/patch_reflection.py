import re

file_path = "lib/screens/reflection_flow_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# We want to replace everything from `class _ReflectionTextInputState extends State<_ReflectionTextInput> {`
# down to the end of the `_ReflectionTextInputState` class.

# The end is right before `class _ReflectionRatingInput extends StatefulWidget {`

new_class = """class _ReflectionTextInputState extends State<_ReflectionTextInput> {
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
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (available) {
        _previousText = _controller.text;
        if (_previousText.isNotEmpty && !_previousText.endsWith(' ') && !_previousText.endsWith('\\n')) {
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
        );
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
"""

waveform_indicator = """
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
"""

pattern = r"class _ReflectionTextInputState extends State<_ReflectionTextInput> \{.*?(?=\nclass _ReflectionRatingInput extends StatefulWidget \{)"
new_content = re.sub(pattern, new_class, content, flags=re.DOTALL)

if new_content == content:
    print("Failed to replace!")
else:
    # Ensure math and async are imported
    if "import 'dart:async';" not in new_content:
        new_content = new_content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:async';")
    if "import 'dart:math' as math;" not in new_content:
        new_content = new_content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:math' as math;")

    new_content += waveform_indicator
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("Successfully replaced!")
