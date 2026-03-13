import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/opportunity.dart';
import '../services/api_service.dart';
import 'opportunity_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Opportunity> _opportunities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    final live = await ApiService.instance.fetchOpportunities();
    if (mounted) {
      setState(() {
        _opportunities = live
            .where((o) => o.daysLeft >= 0 && o.daysLeft <= 10)
            .toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    final critical = _opportunities
        .where((o) => o.urgency == 'critical')
        .toList();
    final warning = _opportunities
        .where((o) => o.urgency == 'warning')
        .toList();
    final safe = _opportunities.where((o) => o.urgency == 'safe').toList();

    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFF6C63FF),
        backgroundColor: const Color(0xFF1A1A2E),
        onRefresh: _loadOpportunities,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildAlertBanner(_opportunities.length)),
            if (critical.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildGroupTitle(
                  '🔴  Apply Today — Critical',
                  const Color(0xFFFF4757),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildNotificationCard(
                      context,
                      critical[i],
                      i,
                      'critical',
                    ),
                    childCount: critical.length,
                  ),
                ),
              ),
            ],
            if (warning.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildGroupTitle(
                  '🟠  Closing This Week',
                  const Color(0xFFFF8C42),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildNotificationCard(
                      context,
                      warning[i],
                      i,
                      'warning',
                    ),
                    childCount: warning.length,
                  ),
                ),
              ),
            ],
            if (safe.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildGroupTitle(
                  '🟢  Upcoming Deadlines',
                  const Color(0xFF00D4AA),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) =>
                        _buildNotificationCard(context, safe[i], i, 'safe'),
                    childCount: safe.length,
                  ),
                ),
              ),
            ],
            if (_opportunities.isEmpty)
              SliverFillRemaining(child: _buildEmptyState()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'No urgent deadlines',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No backend opportunities with urgent deadlines yet',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deadline Alerts',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay ahead, never miss a deadline',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.07),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildAlertBanner(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.25),
              const Color(0xFF4FACFE).withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF9D97FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count internships need attention',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Deadlines closing within 10 days',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
    );
  }

  Widget _buildGroupTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Opportunity opportunity,
    int index,
    String urgency,
  ) {
    final color = opportunity.urgencyColor;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                OpportunityDetailScreen(opportunity: opportunity),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 280),
          ),
        );
      },
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left accent bar
                    Container(
                      width: 3,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Alert message
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.85),
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${opportunity.daysLeft == 0 ? 'Today' : '${opportunity.daysLeft} day${opportunity.daysLeft == 1 ? '' : 's'} left'} ',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                                const TextSpan(text: 'to apply for '),
                                TextSpan(
                                  text:
                                      '${opportunity.company} – ${opportunity.role}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Info row
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: Colors.white.withOpacity(0.35),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                opportunity.location,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (opportunity.isPaid) ...[
                                Icon(
                                  Icons.payments_outlined,
                                  size: 11,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  opportunity.stipend,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Company emoji + arrow
                    Column(
                      children: [
                        Text(
                          opportunity.companyEmoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 150 + index * 70),
                duration: const Duration(milliseconds: 350),
              )
              .slideX(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: 150 + index * 70),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
              ),
    );
  }
}
