import 'package:flutter/material.dart';

import '../models/opportunity.dart';

class CategoryData {
  CategoryData._();

  static const List<InternshipCategory> categories = [
    InternshipCategory(
      id: 'ai_ml',
      name: 'AI / ML',
      emoji: '🤖',
      gradientColors: [Color(0xFF7B2FF7), Color(0xFFF107A3)],
      opportunityCount: 0,
    ),
    InternshipCategory(
      id: 'data_science',
      name: 'Data Science',
      emoji: '📊',
      gradientColors: [Color(0xFF0061FF), Color(0xFF60EFFF)],
      opportunityCount: 0,
    ),
    InternshipCategory(
      id: 'web_dev',
      name: 'Web Dev',
      emoji: '🌐',
      gradientColors: [Color(0xFFF7971E), Color(0xFFFFD200)],
      opportunityCount: 0,
    ),
    InternshipCategory(
      id: 'mobile_dev',
      name: 'Mobile Dev',
      emoji: '📱',
      gradientColors: [Color(0xFF11998E), Color(0xFF38EF7D)],
      opportunityCount: 0,
    ),
    InternshipCategory(
      id: 'cloud_devops',
      name: 'Cloud / DevOps',
      emoji: '☁️',
      gradientColors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
      opportunityCount: 0,
    ),
    InternshipCategory(
      id: 'cybersecurity',
      name: 'Cybersecurity',
      emoji: '🔐',
      gradientColors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      opportunityCount: 0,
    ),
    InternshipCategory(
      id: 'genomics_lifescience',
      name: 'Genomics / Life Sciences',
      emoji: '🧬',
      gradientColors: [Color(0xFF1D976C), Color(0xFF93F9B9)],
      opportunityCount: 0,
    ),
    InternshipCategory(
      id: 'others',
      name: 'Others',
      emoji: '💬',
      gradientColors: [Color(0xFF636FA4), Color(0xFFE8CBC0)],
      opportunityCount: 0,
    ),
  ];
}
