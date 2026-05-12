import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lexgo/models/dictionary_model.dart';

class WordDetailScreen extends StatefulWidget {
  final DictionaryTerm term;
  final List<DictionaryTerm> allTerms;
  final int currentIndex;

  const WordDetailScreen({
    super.key,
    required this.term,
    required this.allTerms,
    required this.currentIndex,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late int _currentIndex;
  late DictionaryTerm _term;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _term = widget.term;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _goToIndex(int index) {
    if (index < 0 || index >= widget.allTerms.length) return;
    setState(() {
      _currentIndex = index;
      _term = widget.allTerms[index];
    });
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex < widget.allTerms.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B162C),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Dictionary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Dark Header: Word + Definition ───────────────────────────────
          Stack(
            children: [
              // Watermark scales icon in the background
              Positioned(
                right: -20,
                bottom: -10,
                child: Opacity(
                  opacity: 0.08,
                  child: const Icon(
                    Icons.balance,
                    size: 160,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word + audio icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            _term.word,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (_term.audioUrl != null &&
                            _term.audioUrl!.isNotEmpty)
                          GestureDetector(
                            onTap: () => _playAudio(_term.audioUrl!),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // "Definition" label
                    Text(
                      'Definition',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Primary definition
                    Text(
                      _term.meanings.isNotEmpty
                          ? _term.meanings.first
                          : 'No definition available.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── White Card Body ───────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Examples ─────────────────────────────────────
                          if (_term.examples.isNotEmpty) ...[
                            ...List.generate(
                              _term.examples.length,
                              (i) => _buildExampleBlock(
                                'Example ${i + 1}',
                                _term.examples[i],
                              ),
                            ),
                          ] else ...[
                            // Fallback: show remaining meanings as examples
                            ...List.generate(
                              (_term.meanings.length > 1
                                      ? _term.meanings.sublist(1)
                                      : [])
                                  .length,
                              (i) => _buildExampleBlock(
                                'Example ${i + 1}',
                                _term.meanings.sublist(1)[i],
                              ),
                            ),
                            if (_term.meanings.length <= 1)
                              Text(
                                'No usage examples available.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],

                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 16),

                          // ── Related Terms ─────────────────────────────────
                          const Text(
                            'Related Terms:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_term.relatedTerms.isNotEmpty)
                            ...(_term.relatedTerms.map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '-$t',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ))
                          else
                            Text(
                              'No related terms available.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // ── Previous / Next Buttons ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Previous
                        Expanded(
                          child: OutlinedButton(
                            onPressed: hasPrev
                                ? () => _goToIndex(_currentIndex - 1)
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0B162C),
                              side: BorderSide(
                                color: hasPrev
                                    ? const Color(0xFF0B162C)
                                    : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Next
                        Expanded(
                          child: ElevatedButton(
                            onPressed: hasNext
                                ? () => _goToIndex(_currentIndex + 1)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B162C),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildExampleBlock(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
