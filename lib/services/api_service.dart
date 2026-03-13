import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../models/opportunity.dart';

const String _configuredBackendBaseUrl = 'http://192.168.137.205:5000';
const List<String> _candidateBackendBaseUrls = <String>[
  _configuredBackendBaseUrl,
  'http://10.0.2.2:5000',
  'http://127.0.0.1:5000',
  'http://localhost:5000',
];

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  String? _workingBaseUrl;

  Future<List<Opportunity>> fetchOpportunities() async {
    final response = await _get('/opportunities');
    if (response == null) {
      return [];
    }

    try {
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => Opportunity.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      developer.log(
        'API returned status ${response.statusCode}',
        name: 'ApiService',
      );
      return [];
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch opportunities: $e',
        name: 'ApiService',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<bool> checkHealth() async {
    final response = await _get('/test');
    return response?.statusCode == 200;
  }

  Future<http.Response?> _get(String path) async {
    for (final baseUrl in _orderedBaseUrls) {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl$path'),
              headers: const {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 8));

        if (response.statusCode >= 200 && response.statusCode < 500) {
          _workingBaseUrl = baseUrl;
          return response;
        }
      } catch (e, stackTrace) {
        developer.log(
          'Failed to reach $baseUrl$path: $e',
          name: 'ApiService',
          stackTrace: stackTrace,
        );
      }
    }

    return null;
  }

  List<String> get _orderedBaseUrls {
    final ordered = <String>[];
    if (_workingBaseUrl != null) {
      ordered.add(_workingBaseUrl!);
    }
    for (final baseUrl in _candidateBackendBaseUrls) {
      if (!ordered.contains(baseUrl)) {
        ordered.add(baseUrl);
      }
    }
    return ordered;
  }
}
