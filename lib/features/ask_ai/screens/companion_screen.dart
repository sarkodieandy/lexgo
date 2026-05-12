import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/ai_api_service.dart';

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen> with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FlutterTts _flutterTts = FlutterTts();
  final AiApiService _aiApiService = AiApiService();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  String _statusText = 'How may i help you';
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioRecorder.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/recording.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _statusText = 'Listening...';
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _statusText = 'Processing...';
      });

      if (path != null) {
        await _processVoiceInput(path);
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      setState(() {
        _isProcessing = false;
        _statusText = 'How may i help you';
      });
    }
  }

  Future<void> _processVoiceInput(String path) async {
    try {
      // 1. Transcribe audio
      final transcription = await _aiApiService.transcribeAudio(path);
      
      if (transcription.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusText = 'Sorry, I couldn\'t hear anything.';
        });
        return;
      }

      setState(() {
        _statusText = 'Thinking...';
      });

      // 2. Get AI Response
      String fullResponse = '';
      await for (final chunk in _aiApiService.askAiStream(transcription)) {
        fullResponse += chunk;
      }

      setState(() {
        _isProcessing = false;
        _statusText = 'Speaking...';
      });

      // 3. Speak response
      await _flutterTts.speak(fullResponse);

      setState(() {
        _statusText = 'How may i help you';
      });
    } catch (e) {
      debugPrint('Error processing voice input: $e');
      setState(() {
        _isProcessing = false;
        _statusText = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1A), // Even darker navy
      body: SafeArea(
        child: Stack(
          children: [
            // Top Chip
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/companion_icon.png',
                        width: 20,
                        height: 20,
                        color: Colors.blue.shade900,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Companion',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Middle Sphere
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                            offset: const Offset(10, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/companion_sphere.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.purple.shade900,
                                        Colors.blue.shade900,
                                        Colors.black,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    _statusText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Buttons
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 60), // Spacer for centering mic
                    
                    // Mic Button
                    GestureDetector(
                      onTapDown: (_) => _startRecording(),
                      onTapUp: (_) => _stopRecording(),
                      onTapCancel: () => _stopRecording(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isRecording)
                            ...List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 80 + (index * 20 * _pulseController.value),
                                    height: 80 + (index * 20 * _pulseController.value),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3 - (index * 0.1)),
                                        width: 1.5,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isRecording ? Icons.mic : Icons.mic_none,
                              size: 36,
                              color: const Color(0xFF0B162C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Close Button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.close, color: Colors.white70, size: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_isProcessing)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white38,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
