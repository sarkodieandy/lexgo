import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lexgo/models/dictionary_model.dart';
import 'package:lexgo/services/dictionary_api_service.dart';
import 'word_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final DictionaryApiService _apiService = DictionaryApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<String> alphabets = List.generate(
    26,
    (index) => String.fromCharCode(65 + index),
  );
  String _selectedLetter = 'A';

  bool _isLoading = false;
  List<DictionaryTerm> _currentTerms = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchTermsForLetter(_selectedLetter);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchTermsForLetter(String letter) async {
    setState(() {
      _isLoading = true;
      _currentTerms = [];
    });

    try {
      final terms = await _apiService.fetchTermsForLetter(letter);
      setState(() {
        _currentTerms = terms;
      });
    } catch (e) {
      // Handle error visually if needed
      debugPrint('Error loading terms: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onLetterSelected(String letter) {
    if (_selectedLetter == letter && _searchQuery.isEmpty) return;
    setState(() {
      _selectedLetter = letter;
      _searchQuery = '';
      _searchController.clear();
    });
    _fetchTermsForLetter(letter);
  }


  Future<void> _performLocalAndRemoteSearch(String query) async {
    setState(() {
      _isLoading = true;
      _currentTerms = [];
    });

    try {
      // 1. Get matching local term names
      final matchingNames = _apiService.searchLocalTerms(query);
      
      if (matchingNames.isNotEmpty) {
        // 2. Fetch definitions for the top matches (limit to 10 for performance)
        final topNames = matchingNames.take(10).toList();
        List<Future<DictionaryTerm?>> futures = topNames.map((name) => _apiService.fetchTerm(name)).toList();
        final results = await Future.wait(futures);
        
        if (mounted) {
          setState(() {
            _currentTerms = results.whereType<DictionaryTerm>().toList();
            _isLoading = false;
          });
        }
      } else {
        // 3. If no local matches, try a direct external search
        final term = await _apiService.fetchTerm(query);
        if (mounted) {
          setState(() {
            _currentTerms = term != null ? [term] : [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error during search: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      setState(() {
        _searchQuery = query.trim();
      });

      if (_searchQuery.isEmpty) {
        _fetchTermsForLetter(_selectedLetter);
      } else {
        _performLocalAndRemoteSearch(_searchQuery);
      }
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C), // Dark navy header background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
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
            onPressed: () {
              // Focus the search field? Handled by the search bar below now.
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5), // Light background for the content
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  _buildHeaderContent(),

                  // Letter title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      _searchQuery.isNotEmpty ? 'Search Results' : _selectedLetter,
                      style: TextStyle(
                        fontSize: _searchQuery.isNotEmpty ? 24 : 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Selected Letter Terms List
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0B162C),
                            ),
                          )
                        : _currentTerms.isEmpty
                        ? const Center(
                            child: Text(
                              'No definitions found for this letter.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _currentTerms.length,
                            itemBuilder: (context, index) {
                              final term = _currentTerms[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WordDetailScreen(
                                        term: term,
                                        allTerms: _currentTerms,
                                        currentIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: _buildTermCard(term),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // A-Z Sidebar
            Container(
              width: 30,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200, // Very light grey for side bar
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: alphabets.map((letter) {
                  final isSelected = letter == _selectedLetter;
                  return GestureDetector(
                    onTap: () => _onLetterSelected(letter),
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.black54,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0B162C), width: 4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.book, size: 40, color: Color(0xFF0B162C)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Law Dictionary',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B162C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore legal terms in simple language.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for a legal term...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0B162C)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFF0B162C), width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermCard(DictionaryTerm term) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                term.word,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              if (term.audioUrl != null && term.audioUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () => _playAudio(term.audioUrl!),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (term.meanings.isNotEmpty)
            ...List.generate(term.meanings.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '${index + 1}.) ${term.meanings[index]}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              );
            })
          else
            const Text(
              'No definition found.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
