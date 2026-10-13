import 'package:flutter/material.dart';
import 'package:ios_sliding_navbar/ios_sliding_navbar.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Sliding Navbar Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  // ── Demo 1: Simple segmented control ──────────────────────────────────────
  int _segIndex = 0;

  // ── Demo 2: PageController sync ───────────────────────────────────────────
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // ── Demo 3: NavItems with badges ──────────────────────────────────────────
  int _navIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1513),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1513),
        title: const Text('ios_sliding_navbar demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Demo 1 ──────────────────────────────────────────────────────
            _sectionLabel('Simple segmented control'),
            const SizedBox(height: 12),
            SlidingSegmentedNavbar(
              items: const ['Pickup', 'Delivery', 'Dine-in'],
              currentIndex: _segIndex,
              onTabChanged: (i) => setState(() => _segIndex = i),
            ),
            const SizedBox(height: 8),
            Text(
              'Selected: ${['Pickup', 'Delivery', 'Dine-in'][_segIndex]}',
              style: const TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 40),

            // ── Demo 2 ──────────────────────────────────────────────────────
            _sectionLabel('Synced with PageView'),
            const SizedBox(height: 12),
            SlidingSegmentedNavbar(
              items: const ['Feed', 'Explore', 'Inbox'],
              pageController: _pageController,
              currentIndex: _pageIndex,
              onTabChanged: (i) => setState(() => _pageIndex = i),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                children: [
                  _pageCard('📰 Feed'),
                  _pageCard('🔍 Explore'),
                  _pageCard('📬 Inbox'),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Demo 3 ──────────────────────────────────────────────────────
            _sectionLabel('NavItems with icons and badges'),
            const SizedBox(height: 12),
            SlidingSegmentedNavbar(
              height: 60,
              navItems: const [
                SlidingNavItem(label: 'Home', icon: Icons.home_rounded),
                SlidingNavItem(
                    label: 'Orders',
                    icon: Icons.receipt_long_rounded,
                    showBadge: true),
                SlidingNavItem(
                    label: 'Wallet',
                    icon: Icons.account_balance_wallet_rounded),
                SlidingNavItem(label: 'Profile', icon: Icons.person_rounded),
              ],
              currentIndex: _navIndex,
              onTabChanged: (i) => setState(() => _navIndex = i),
            ),

            const SizedBox(height: 40),

            // ── Demo 4 ──────────────────────────────────────────────────────
            _sectionLabel('Custom colours'),
            const SizedBox(height: 12),
            const SlidingSegmentedNavbar(
              items: ['Monthly', 'Yearly'],
              backgroundColor: Color(0xFF1A1A2E),
              indicatorColor: Color(0xFF533483),
              activeTextColor: Colors.white,
              inactiveTextColor: Color(0xFF888899),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );

  Widget _pageCard(String label) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1B221E),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 28),
        ),
      );
}
