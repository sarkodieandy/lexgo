import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/dictionary_model.dart';

class DictionaryApiService {
  static const String _baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  // Hardcoded dictionary of legal terms mapped by starting letter
  static final Map<String, List<String>> legalTermsByLetter = {
    'A': [
      'Abandonment',
      'Abatement',
      'Accessory',
      'Acquittal',
      'Affidavit',
      'Appeal',
    ],
    'B': ['Bail', 'Bankruptcy', 'Battery', 'Beneficiary', 'Breach', 'Burglary'],
    'C': ['Capacity', 'Chattel', 'Citation', 'Codicil', 'Consent', 'Contract'],
    'D': ['Damages', 'Decree', 'Deed', 'Defamation', 'Defendant', 'Deposition'],
    'E': [
      'Easement',
      'Embezzlement',
      'Eminent',
      'Entity',
      'Equity',
      'Eviction',
    ],
    'F': ['Felony', 'Fiduciary', 'Fraud', 'Frisk'],
    'G': ['Garnishment', 'Guarantor', 'Guardian', 'Guilty'],
    'H': ['Habeas', 'Hearing', 'Hearsay', 'Homicide'],
    'I': ['Immunity', 'Injunction', 'Intent', 'Intestate'],
    'J': ['Judgment', 'Jurisdiction', 'Jury', 'Justice'],
    'K': ['Kidnapping', 'Kin'],
    'L': ['Larceny', 'Lawsuit', 'Lease', 'Liability', 'Lien', 'Litigation'],
    'M': [
      'Malice',
      'Malpractice',
      'Mandamus',
      'Manslaughter',
      'Misdemeanor',
      'Mortgage',
    ],
    'N': ['Negligence', 'Notary', 'Notice', 'Nuisance'],
    'O': ['Oath', 'Objection', 'Offense', 'Ordinance'],
    'P': ['Pardon', 'Parole', 'Patent', 'Perjury', 'Plaintiff', 'Plea'],
    'Q': ['Quash', 'Quorum'],
    'R': [
      'Ratification',
      'Rebuttal',
      'Remedy',
      'Repeal',
      'Restitution',
      'Robbery',
    ],
    'S': ['Sanction', 'Slander', 'Statute', 'Subpoena', 'Summons', 'Surety'],
    'T': ['Testimony', 'Title', 'Tort', 'Transcript', 'Trespass', 'Trust'],
    'U': ['Unconstitutional', 'Usury'],
    'V': ['Vandalism', 'Venue', 'Verdict', 'Void', 'Voir'],
    'W': ['Waive', 'Warrant', 'Will', 'Witness', 'Writ'],
    'X': [],
    'Y': ['Yield'],
    'Z': ['Zoning'],
  };

  /// Fetches the definition from the Free Dictionary API.
  Future<DictionaryTerm?> fetchTerm(String term) async {
    try {
      final uri = Uri.parse('$_baseUrl/$term');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isNotEmpty) {
          return DictionaryTerm.fromJson(jsonList.first);
        }
      } else {
        // If not found (404), return null.
        debugPrint('Term not found in dictionary: $term');
      }
    } catch (e) {
      debugPrint('Error fetching term $term: $e');
    }
    return null;
  }

  /// Fetches definitions for an entire letter
  Future<List<DictionaryTerm>> fetchTermsForLetter(String letter) async {
    final terms = legalTermsByLetter[letter.toUpperCase()] ?? [];
    List<DictionaryTerm> results = [];

    // In a real app we might batch or stagger these, but for a small list we can do concurrent API calls.
    // The Free Dictionary API does not require keys, but we should be mindful of rate limits.
    // For 5-6 items, Future.wait is fine.
    List<Future<DictionaryTerm?>> fetchFutures = terms
        .map((term) => fetchTerm(term))
        .toList();

    final fetchedTerms = await Future.wait(fetchFutures);

    for (var term in fetchedTerms) {
      if (term != null) {
        results.add(term);
      }
    }

    return results;
  }

  /// Searches local legal terms that contain the query string.
  List<String> searchLocalTerms(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    final results = <String>[];
    legalTermsByLetter.forEach((letter, terms) {
      results.addAll(
        terms.where((term) => term.toLowerCase().contains(lowerQuery)),
      );
    });
    // Sort results to prioritize those starting with the query
    results.sort((a, b) {
      final aStarts = a.toLowerCase().startsWith(lowerQuery);
      final bStarts = b.toLowerCase().startsWith(lowerQuery);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      return a.compareTo(b);
    });
    return results;
  }
}
