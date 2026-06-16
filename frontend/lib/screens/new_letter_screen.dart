import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class NewLetterScreen extends StatefulWidget {
  final int? letterId;
  final String? initialText;
  final String? initialTitle;
  final String? initialType;

  const NewLetterScreen({
    super.key,
    this.letterId,
    this.initialText,
    this.initialTitle,
    this.initialType,
  });

  @override
  State<NewLetterScreen> createState() => _NewLetterScreenState();
}

class _NewLetterScreenState extends State<NewLetterScreen> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  bool _showSavedMessage = false;
  Timer? _typingTimer;
  late String _placeholder;
  
  String _selectedType = 'Heartfelt';
  final List<String> _letterTypes = ['Heartfelt', 'Funny', 'Deep', 'Apology', 'Casual'];

  final List<String> _placeholders = [
    'I miss you today...',
    'There’s something I never said...',
    'I wish you understood...',
    'Thinking of you...',
    'Sometimes it feels like...',
  ];

  bool _isSaving = false;
  
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isProcessing = false;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _selectedType = widget.initialType ?? 'Heartfelt';
    _placeholder = _placeholders[DateTime.now().second % _placeholders.length];
    _controller.addListener(_onTextChanged);
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

  void _saveEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.letterId != null) {
        // Edit mode
        await ApiService.updateLetter(
          widget.letterId!,
          content: text,
          title: _selectedType,
          letterType: _selectedType.toLowerCase(),
        );
      } else {
        // Create mode
        await ApiService.createLetter(
          content: text,
          title: _selectedType,
          letterType: _selectedType.toLowerCase(),
        );
      }
      
      if (mounted) {
        setState(() {
          _isSaving = false;
          _showSavedMessage = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save letter: ${e.toString().replaceAll('Exception:', '').trim()}'),
            backgroundColor: const Color(0xFF911746),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSavedMessage) {
      return Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, color: Color(0xFFDD8F9F), size: 48),
                const SizedBox(height: 32),
                const Text(
                  '“Some things don’t need to be sent to be understood”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'It’s okay to keep this here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF866571),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    AnimatedOpacity(
                      opacity: _isTyping ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: TextButton(
                        onPressed: (_controller.text.isNotEmpty && !_isSaving) ? _saveEntry : null,
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9E7E5A)),
                                ),
                              )
                            : Text(
                                widget.letterId != null ? 'Update Letter' : 'Keep this with me',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: _controller.text.isNotEmpty ? const Color(0xFF9E7E5A) : const Color(0xFF4A343D),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Type Selector ---
                AnimatedOpacity(
                  opacity: _isTyping ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _letterTypes.map((type) {
                        final isSelected = _selectedType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFDD8F9F).withValues(alpha: 0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFDD8F9F) : const Color(0xFF26151B),
                              ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFFDD8F9F) : const Color(0xFF866571),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Main Content ---
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What are you holding inside today...',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You don’t have to filter anything here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF866571),
                          ),
                        ),
                        const SizedBox(height: 48),

                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: null,
                          autofocus: widget.letterId == null,
                          cursorColor: const Color(0xFF9E7E5A),
                          cursorWidth: 1.2,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFDD8F9F),
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: _placeholder,
                            hintStyle: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF3D1B28),
                            ),
                            border: InputBorder.none,
                          ),
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

                // --- Bottom Actions ---
                AnimatedOpacity(
                  opacity: _isTyping ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      const Divider(color: Color(0xFF26151B)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedSwitcher(
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
                                    : const Text(
                                        'Prefer speaking instead?',
                                        key: ValueKey('idle'),
                                        style: TextStyle(
                                          fontSize: 13, 
                                          color: Color(0xFF866571),
                                        ),
                                      ),
                          ),
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          '“Not everything meant to be felt… needs to be sent.”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF4A343D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Your words are safe here',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF26151B),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
