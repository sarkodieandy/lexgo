class DictionaryTerm {
  final String word;
  final String? phonetic;
  final String? audioUrl;
  final List<String> meanings;
  final List<String> examples;
  final List<String> relatedTerms;

  DictionaryTerm({
    required this.word,
    this.phonetic,
    this.audioUrl,
    required this.meanings,
    this.examples = const [],
    this.relatedTerms = const [],
  });

  factory DictionaryTerm.fromJson(Map<String, dynamic> json) {
    // Extract phonetic and audio from phonetics list
    String? phoneticStr = json['phonetic'];
    String? audio;

    if (json['phonetics'] != null && json['phonetics'] is List) {
      for (var p in json['phonetics']) {
        if (p['text'] != null &&
            p['text'].toString().isNotEmpty &&
            phoneticStr == null) {
          phoneticStr = p['text'];
        }
        if (p['audio'] != null && p['audio'].toString().isNotEmpty) {
          audio = p['audio'];
          // we prioritize finding a valid audio file. if we find one we can stop (or prefer US/UK based on logic, but first is fine for now)
          if (audio!.endsWith('.mp3')) {
            break;
          }
        }
      }
    }

    // Extract meanings
    List<String> extractedMeanings = [];
    if (json['meanings'] != null && json['meanings'] is List) {
      for (var meaning in json['meanings']) {
        if (meaning['definitions'] != null && meaning['definitions'] is List) {
          for (var def in meaning['definitions']) {
            if (def['definition'] != null) {
              extractedMeanings.add(def['definition']);
              // Only take up to 2 definitions per term for UI simplicity, as per mockup
              if (extractedMeanings.length >= 2) break;
            }
          }
        }
        if (extractedMeanings.length >= 2) break;
      }
    }

    // Extract examples from definitions (example field in each definition)
    List<String> extractedExamples = [];
    if (json['meanings'] != null && json['meanings'] is List) {
      for (var meaning in json['meanings']) {
        if (meaning['definitions'] != null && meaning['definitions'] is List) {
          for (var def in meaning['definitions']) {
            if (def['example'] != null && def['example'].toString().isNotEmpty) {
              extractedExamples.add(def['example']);
              if (extractedExamples.length >= 3) break;
            }
          }
        }
        if (extractedExamples.length >= 3) break;
      }
    }

    // Extract related terms from synonyms in meanings
    List<String> extractedRelated = [];
    if (json['meanings'] != null && json['meanings'] is List) {
      for (var meaning in json['meanings']) {
        if (meaning['synonyms'] != null && meaning['synonyms'] is List) {
          for (var s in meaning['synonyms']) {
            if (!extractedRelated.contains(s)) {
              extractedRelated.add(s as String);
            }
            if (extractedRelated.length >= 5) break;
          }
        }
        if (extractedRelated.length >= 5) break;
      }
    }

    return DictionaryTerm(
      word: json['word'],
      phonetic: phoneticStr,
      audioUrl: audio,
      meanings: extractedMeanings,
      examples: extractedExamples,
      relatedTerms: extractedRelated,
    );
  }
}
