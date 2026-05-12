import 'package:flutter/material.dart';
import '../../../../services/ai_api_service.dart';
import 'companion_screen.dart';

class _ChatMessage {
  String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiApiService _aiApiService = AiApiService();

  bool _isLoading = false;
  List<_ChatMessage> _messages = [];

  final List<Map<String, dynamic>> _topics = [
    {'title': 'Constitutional Law', 'icon': Icons.balance},
    {'title': 'Contract Law', 'icon': Icons.menu_book},
    {'title': 'Criminal Law', 'icon': Icons.gavel},
    {'title': 'Tort Law', 'icon': Icons.lightbulb_outline},
    {'title': 'What is Law', 'icon': Icons.list},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await _aiApiService.getHistory(limit: 25);
      if (response['success'] == true && response['aiHistory'] != null) {
        final List<dynamic> history = response['aiHistory'];
        final newMessages = <_ChatMessage>[];
        // Parse history assuming reverse chronological order from API
        for (var item in history.reversed) {
          if (item['question'] != null) {
            newMessages.add(_ChatMessage(text: item['question'], isUser: true));
          }
          if (item['answer'] != null) {
            newMessages.add(_ChatMessage(text: item['answer'], isUser: false));
          }
        }
        if (mounted && newMessages.isNotEmpty) {
          setState(() {
            _messages = newMessages;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _messages.add(_ChatMessage(text: '', isUser: false));
      _isLoading = true;
    });

    _questionController.clear();
    _scrollToBottom();

    try {
      await for (var chunk in _aiApiService.askAiStream(question)) {
        if (!mounted) break;
        setState(() {
          _messages.last.text += chunk;
        });
        _scrollToBottom();
      }
      // Note: The backend auto-saves the Q&A and increments askAiCount.
      // No local stat tracking needed here.
    } catch (e) {
      if (!mounted) return;
      final errorText = e.toString().replaceAll('Exception: ', '');
      setState(() {
        // Replace the empty AI placeholder with the error message
        _messages.last.text = '⚠️ $errorText';
      });
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMessage(_ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF0B162C) : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : null,
            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
          ),
          boxShadow: [
            if (!message.isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          message.text.isEmpty && !message.isUser ? '...' : message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : const Color(0xFF0B162C),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsOrChat() {
    if (_messages.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // AI Assistant Icon & Headers
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Color(0xFF0B162C),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Legal Assistant',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B162C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get instant help with legal concepts and knowlege',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Suggested Topics
            ..._topics.map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: Icon(
                      topic['icon'],
                      color: const Color(0xFF0B162C),
                    ),
                    title: Text(
                      topic['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    onTap: () {
                      _questionController.text =
                          "Tell me about ${topic['title']}";
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessage(_messages[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Ask AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Expanded(child: _buildTopicsOrChat()),

            // Bottom Input Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.mic_none, color: Color(0xFF0B162C), size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CompanionScreen()),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _questionController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: 'Ask me about any legal concept...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => _submitQuestion(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B162C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send, color: Colors.white),
                          onPressed: _isLoading ? null : _submitQuestion,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AI responses are for educational purposes. Always verify legal information with authoritative sources.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
