import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class NewLetterScreen extends StatefulWidget {
  const NewLetterScreen({super.key});

  @override
  State<NewLetterScreen> createState() => _NewLetterScreenState();
}

class _NewLetterScreenState extends State<NewLetterScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  bool _showSavedMessage = false;
  Timer? _typingTimer;
  late String _placeholder;

  final List<String> _placeholders = [
    'I miss you today...',
    'There’s something I never said...',
    'I wish you understood...',
    'Thinking of you...',
    'Sometimes it feels like...',
  ];

  @override
  void initState() {
    super.initState();
    _placeholder = _placeholders[DateTime.now().second % _placeholders.length];
    _controller.addListener(_onTextChanged);
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _saveEntry() {
    setState(() {
      _showSavedMessage = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
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
                        onPressed: _controller.text.isNotEmpty ? _saveEntry : null,
                        child: Text(
                          'Keep this with me',
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
                          autofocus: true,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.6,
                          ),
                          decoration: InputDecoration(
                            hintText: _placeholder,
                            hintStyle: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF4A343D),
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
                          const Text(
                            'Prefer speaking instead?',
                            style: TextStyle(fontSize: 13, color: Color(0xFF866571)),
                          ),
                          const Icon(Icons.mic_none, color: Color(0xFF866571), size: 20),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _FeelingTag(label: 'Missed them'),
                          const SizedBox(width: 8),
                          _FeelingTag(label: 'Remembered something'),
                        ],
                      ),
                      const SizedBox(height: 16),
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

class _FeelingTag extends StatelessWidget {
  final String label;
  const _FeelingTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26151B)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF866571)),
      ),
    );
  }
}
