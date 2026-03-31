import 'package:flutter/material.dart';

class Opportunity {
  final String id;
  final String company;
  final String companyEmoji;
  final String role;
  final String summary;
  final String description;
  final DateTime deadline;
  final String applyLink;
  final List<String> sources;
  final String category;
  final String location;
  final String duration;
  final bool isPaid;
  final String stipend;
  final List<String> skills;

  const Opportunity({
    required this.id,
    required this.company,
    required this.companyEmoji,
    required this.role,
    required this.summary,
    required this.description,
    required this.deadline,
    required this.applyLink,
    required this.sources,
    required this.category,
    this.location = 'Remote',
    this.duration = '3 Months',
    this.isPaid = false,
    this.stipend = 'Unpaid',
    this.skills = const [],
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    final categoryId = _mapCategory(
      category: json['category']?.toString(),
      role: json['role']?.toString(),
      summary: json['summary']?.toString(),
    );
    final parsedDeadline = _parseDeadline(json['deadline']);
    return Opportunity(
      id: json['_id']?.toString() ?? '',
      company: json['company']?.toString() ?? 'Unknown Company',
      companyEmoji: _categoryEmoji(categoryId),
      role: json['role']?.toString() ?? 'Unknown Role',
      summary: json['summary']?.toString() ?? '',
      description: json['summary']?.toString() ?? '',
      deadline: parsedDeadline,
      applyLink: json['apply_link']?.toString() ?? '',
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      category: categoryId,
    );
  }

  static DateTime _parseDeadline(Object? value) {
    if (value == null) {
      return DateTime.now().add(const Duration(days: 7));
    }

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) {
      return DateTime.now().add(const Duration(days: 7));
    }

    return parsed.toLocal();
  }

  static String _mapCategory({
    String? category,
    String? role,
    String? summary,
  }) {
    // Check exact backend category string first (fast path)
    final exactCat = (category ?? '').trim().toLowerCase();
    if (exactCat == 'others' || exactCat == 'other') return 'others';
    if (exactCat == 'ai/ml' || exactCat == 'ai / ml') return 'ai_ml';
    if (exactCat == 'data science') return 'data_science';
    if (exactCat == 'web development') return 'web_dev';
    if (exactCat == 'mobile development') return 'mobile_dev';
    if (exactCat == 'cloud / devops' || exactCat == 'cloud/devops') {
      return 'cloud_devops';
    }
    if (exactCat == 'cybersecurity') return 'cybersecurity';
    if (exactCat == 'genomics / life sciences' ||
        exactCat == 'genomics/life sciences') {
      return 'genomics_lifescience';
    }

    // Fallback: keyword matching across category + role + summary
    final cat = '${category ?? ''} ${role ?? ''} ${summary ?? ''}'
        .toLowerCase();
    if (cat.trim().isEmpty) return 'others';
    if (cat.contains('genomic') ||
        cat.contains('genomics') ||
        cat.contains('life science') ||
        cat.contains('life sciences') ||
        cat.contains('bioinformatics') ||
        cat.contains('biotech') ||
        cat.contains('biotechnology')) {
      return 'genomics_lifescience';
    }
    if (RegExp(r'\bai\b').hasMatch(cat) ||
        RegExp(r'\bml\b').hasMatch(cat) ||
        cat.contains('machine learning') ||
        cat.contains('artificial intelligence') ||
        cat.contains('deep learning') ||
        cat.contains('natural language') ||
        cat.contains('computer vision') ||
        cat.contains('nlp')) {
      return 'ai_ml';
    }
    if (cat.contains('data science') ||
        cat.contains('data analysis') ||
        cat.contains('data')) {
      return 'data_science';
    }
    if (cat.contains('web') ||
        cat.contains('frontend') ||
        cat.contains('backend') ||
        cat.contains('full stack') ||
        cat.contains('software engineer') ||
        cat.contains('software developer') ||
        cat.contains('react') ||
        cat.contains('node')) {
      return 'web_dev';
    }
    if (cat.contains('mobile') ||
        cat.contains('android') ||
        cat.contains('ios') ||
        cat.contains('flutter')) {
      return 'mobile_dev';
    }
    if (cat.contains('cloud') ||
        cat.contains('devops') ||
        cat.contains('infra')) {
      return 'cloud_devops';
    }
    if (cat.contains('cyber') || cat.contains('security')) {
      return 'cybersecurity';
    }
    return 'others';
  }

  static String _categoryEmoji(String categoryId) {
    switch (categoryId) {
      case 'ai_ml':
        return '🤖';
      case 'data_science':
        return '📊';
      case 'web_dev':
        return '🌐';
      case 'mobile_dev':
        return '📱';
      case 'cloud_devops':
        return '☁️';
      case 'cybersecurity':
        return '🔐';
      case 'genomics_lifescience':
        return '🧬';
      case 'others':
        return '💬';
      default:
        return '💼';
    }
  }

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineDay.difference(today).inDays;
  }

  String get urgency {
    if (daysLeft < 0) return 'expired';
    if (daysLeft <= 3) return 'critical';
    if (daysLeft <= 7) return 'warning';
    return 'safe';
  }

  Color get urgencyColor {
    switch (urgency) {
      case 'expired':
        return const Color(0xFF8B8B8B);
      case 'critical':
        return const Color(0xFFFF4757);
      case 'warning':
        return const Color(0xFFFF8C42);
      default:
        return const Color(0xFF00D4AA);
    }
  }

  String get urgencyLabel {
    if (daysLeft < 0) return 'Expired';
    if (daysLeft == 0) return 'Today';
    if (daysLeft == 1) return '1 day left';
    return '$daysLeft days left';
  }
}

class InternshipCategory {
  final String id;
  final String name;
  final String emoji;
  final List<Color> gradientColors;
  final int opportunityCount;

  const InternshipCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradientColors,
    required this.opportunityCount,
  });
}
