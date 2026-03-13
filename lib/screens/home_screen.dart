import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/category_data.dart';
import '../models/opportunity.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import 'category_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Opportunity> _opportunities = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _loadOpportunities();
  }

  void _handleSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadOpportunities() async {
    final opportunities = await ApiService.instance.fetchOpportunities();
    if (!mounted) {
      return;
    }

    setState(() {
      _opportunities = opportunities;
      _isLoading = false;
    });
  }

  List<Opportunity> get _visibleOpportunities {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _opportunities;
    }

    return _opportunities.where((opportunity) {
      return opportunity.company.toLowerCase().contains(query) ||
          opportunity.role.toLowerCase().contains(query) ||
          opportunity.summary.toLowerCase().contains(query) ||
          opportunity.category.toLowerCase().contains(query);
    }).toList();
  }

  List<InternshipCategory> get _categories {
    return CategoryData.categories.map((category) {
      final count = _visibleOpportunities
          .where((opportunity) => opportunity.category == category.id)
          .length;
      return InternshipCategory(
        id: category.id,
        name: category.name,
        emoji: category.emoji,
        gradientColors: category.gradientColors,
        opportunityCount: count,
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      bottomNavigationBar: _buildBottomNav(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [_buildHomeContent(), const NotificationScreen()],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121F),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: const Color(0xFF6C63FF).withOpacity(0.18),
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.grid_view_rounded,
              color: Colors.white.withOpacity(0.4),
            ),
            selectedIcon: const Icon(
              Icons.grid_view_rounded,
              color: Color(0xFF6C63FF),
            ),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.white.withOpacity(0.4),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4757),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            selectedIcon: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFF6C63FF),
            ),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

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
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildSectionTitle()),
            if (_opportunities.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.05,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final category = _categories[index];
                    final categoryOpportunities = _visibleOpportunities
                        .where(
                          (opportunity) => opportunity.category == category.id,
                        )
                        .toList();
                    return CategoryCard(
                      category: category,
                      index: index,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    CategoryScreen(
                                      category: category,
                                      opportunities: categoryOpportunities,
                                    ),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOutCubic,
                                          ),
                                        ),
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 380,
                            ),
                          ),
                        );
                      },
                    );
                  }, childCount: _categories.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'No opportunities found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The app now reads from the backend only. Pull to refresh after importing a WhatsApp notification.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ],
        ),
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
                  'Good Morning 👋',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.45),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 4),
                Text(
                      'Find Your Path',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 400.ms)
                    .slideX(
                      begin: -0.15,
                      end: 0,
                      delay: 80.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C63FF), Color(0xFF4FACFE)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                delay: 150.ms,
              ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search roles, companies...',
            hintStyle: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 22,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Filter',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
    );
  }

  Widget _buildStatsRow() {
    final total = _opportunities.length;
    final urgent = _opportunities
        .where((o) => o.daysLeft <= 7 && o.daysLeft > 0)
        .length;
    final categories = _categories
        .where((category) => category.opportunityCount > 0)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'Total',
              value: '$total',
              icon: Icons.work_outline_rounded,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              label: 'Closing Soon',
              value: '$urgent',
              icon: Icons.timer_outlined,
              color: const Color(0xFFFF8C42),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              label: 'Categories',
              value: '$categories',
              icon: Icons.category_outlined,
              color: const Color(0xFF00D4AA),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 280.ms, duration: 400.ms),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 7),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withOpacity(0.45),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Browse Categories',
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            '${_categories.where((category) => category.opportunityCount > 0).length} active',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.35),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 320.ms, duration: 400.ms),
    );
  }
}
