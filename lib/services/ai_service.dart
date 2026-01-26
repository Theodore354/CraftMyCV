import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cv_helper_app/models/change_suggestion.dart';
import 'package:cv_helper_app/models/polish_profile.dart';

class AiService {
  /// Toggle this to true if you ever want to test the UI
  /// without calling the backend / OpenAI.
  static const bool useMock = false;

  /// 🔗 Deployed Firebase Function URL for CV polishing (draftChanges).
  ///
  /// Make sure this matches the Function URL from your Firebase deploy logs.
  static const String _draftChangesEndpoint =
      'https://draftchanges-5el5km2x5q-uc.a.run.app';

  /// 🔗 Deployed Firebase Function URL for cover letter generation.
  ///
  /// 👉 UPDATE THIS to the real URL shown after:
  ///     firebase deploy --only functions:generateCoverLetter
  static const String _coverLetterEndpoint =
      'https://generatecoverletter-5el5km2x5q-uc.a.run.app';

  /// Fetch structured change suggestions from the AI backend.
  ///
  /// rawText        → CV text (pasted for now)
  /// profile        → PolishProfile (role, industry, tone, etc.)
  /// areas          → Sections to focus on
  /// userInstruction→ Extra free-text instructions
  static Future<List<ChangeSuggestion>> draftChanges({
    required String rawText,
    required PolishProfile profile,
    required List<String> areas,
    required String userInstruction,
  }) async {
    // 🔁 Local mock mode (good for UI testing without spending tokens)
    if (useMock) {
      return [
        ChangeSuggestion(
          id: 'c1',
          scope: 'summary',
          before: 'Experienced developer.',
          after:
              'Impact-driven ${profile.role} in ${profile.industry}; ${profile.tone.toLowerCase()}.',
          rationale: 'Lead with value; match target profile; keep it concise.',
        ),
        ChangeSuggestion(
          id: 'c2',
          scope: 'experience[0].bullets[0]',
          before: 'Worked on APIs.',
          after: 'Reduced API p95 latency by ~35% via caching & async IO.',
          rationale: 'Add metric + action verb + specific impact.',
        ),
      ];
    }

    final payload = jsonEncode({
      'rawText': rawText,
      'profile': profile.toJson(),
      'areas': areas,
      'instruction': userInstruction,
    });

    http.Response resp;
    try {
      resp = await http
          .post(
            Uri.parse(_draftChangesEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 45));
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Bad response format: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // Check if response is HTML (e.g., Cloud Run 503 error)
      final contentType = resp.headers['content-type'] ?? '';
      if (contentType.contains('text/html')) {
        throw Exception(
          'AI Service is temporarily unavailable (503). Please try again in a minute.',
        );
      }
      // Surface backend errors from the function/OpenAI
      throw Exception('AI service error (${resp.statusCode}): ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    final changesJson =
        (decoded is Map && decoded['changes'] is List)
            ? (decoded['changes'] as List)
            : const <dynamic>[];

    return changesJson
        .whereType<Map<String, dynamic>>()
        .map(ChangeSuggestion.fromJson)
        .toList();
  }

  /// Generate a tailored cover letter using the AI backend.
  ///
  /// jobTitle   → Role user is applying for
  /// company    → Company name
  /// description→ Job description / key requirements
  static Future<String> generateCoverLetter({
    required String jobTitle,
    required String company,
    required String description,
  }) async {
    // For now we always call the backend (no mock here yet).
    if (_coverLetterEndpoint == 'https://YOUR_GENERATE_COVER_LETTER_URL_HERE') {
      throw Exception(
        'Cover letter endpoint not set. Please update _coverLetterEndpoint in AiService.',
      );
    }

    final payload = jsonEncode({
      'jobTitle': jobTitle,
      'company': company,
      'description': description,
    });

    http.Response resp;
    try {
      resp = await http
          .post(
            Uri.parse(_coverLetterEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 45));
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Bad response format: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('AI service error (${resp.statusCode}): ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);

    // Expecting: { "letter": "....." }
    final letter =
        (decoded is Map && decoded['letter'] is String)
            ? decoded['letter'] as String
            : '';

    if (letter.isEmpty) {
      throw Exception('Empty letter received from AI service');
    }

    return letter;
  }
}
