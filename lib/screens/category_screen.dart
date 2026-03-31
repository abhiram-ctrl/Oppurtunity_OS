import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/opportunity.dart';
import '../services/api_service.dart';
import '../widgets/opportunity_card.dart';

class CategoryScreen extends StatefulWidget {
  final InternshipCategory category;
  final List<Opportunity> opportunities;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.opportunities,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Closing Soon', 'Remote', 'Paid'];
  late List<Opportunity> _opportunities;

  @override
  void initState() {
    super.initState();
    _opportunities = List<Opportunity>.from(widget.opportunities);
  }

  Future<void> _handleDelete(Opportunity opportunity) async {
    final success = await ApiService.instance.deleteOpportunity(opportunity.id);
    if (!mounted) return;
    if (success) {
      setState(() {
        _opportunities.removeWhere((o) => o.id == opportunity.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Opportunity deleted.',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete. Please try again.',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: const Color(0xFFFF4757).withOpacity(0.85),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<Opportunity> get _filteredOpportunities {
    final all = _opportunities;
    switch (_selectedFilter) {
      case 'Closing Soon':
        return all.where((o) => o.daysLeft <= 7 && o.daysLeft > 0).toList();
      case 'Remote':
        return all
            .where((o) => o.location.toLowerCase().contains('remote'))
            .toList();
      case 'Paid':
        return all.where((o) => o.isPaid).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildFilterRow()),
          SliverToBoxAdapter(child: _buildResultsCount()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final opps = _filteredOpportunities;
                  if (opps.isEmpty) {
                    return _buildEmptyState();
                  }
                  return OpportunityCard(
                    opportunity: opps[index],
                    index: index,
                    onDelete: () => _handleDelete(opps[index]),
                  );
                },
                childCount: _filteredOpportunities.isEmpty
                    ? 1
                    : _filteredOpportunities.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0D0D1A),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.blurBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.category.gradientColors[0].withOpacity(0.6),
                widget.category.gradientColors[1].withOpacity(0.3),
                const Color(0xFF0D0D1A),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 56, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            widget.category.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${_opportunities.length} opportunities',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.55),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 0, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10, bottom: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4FACFE)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildResultsCount() {
    final count = _filteredOpportunities.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
      child: Text(
        '$count result${count == 1 ? '' : 's'} found',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.white.withOpacity(0.35),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Text('🔍', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No results for "$_selectedFilter"',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _selectedFilter = 'All'),
              child: Text(
                'Clear filter',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
