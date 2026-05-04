import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'services/chat_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/charts_screen.dart';
import 'screens/clinical_history_screen.dart';
import 'widgets/chat_widget.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const VitaAgentApp(),
    ),
  );
}

class VitaAgentApp extends StatelessWidget {
  const VitaAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaAgent',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _notifOpen = false;

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.home_outlined, Icons.home, 'Dashboard'),
    _NavItem(Icons.description_outlined, Icons.description, 'Reports'),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Charts'),
    _NavItem(Icons.history_outlined, Icons.history, 'Clinical History'),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    ReportsScreen(),
    ChartsScreen(),
    ClinicalHistoryScreen(),
  ];

  final List<Map<String, String>> _notifications = const [
    {'text': 'Vijay has generated your weekly diet chart', 'time': '2 min ago'},
    {'text': 'Blood test report analyzed successfully', 'time': '1 hour ago'},
    {"text": "You've hit 80% of your step goal today!", 'time': '3 hours ago'},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    if (isWide) {
      return _buildWideLayout();
    } else {
      return _buildNarrowLayout();
    }
  }

  Widget _buildWideLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: AppTheme.background,
              border: Border(right: BorderSide(color: AppTheme.border)),
            ),
            child: _buildSidebar(),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _screens[_currentIndex],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _ChatFabWrapper(),
    );
  }

  Widget _buildNarrowLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _navItems[_currentIndex].label,
          style: GoogleFonts.playfairDisplay(
              fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          _buildNotifButton(),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary,
            child: Text('RK',
                style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (_notifOpen) _buildNotifDropdown(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) =>
            setState(() => _currentIndex = i),
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primaryLight,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: _navItems
            .map((n) => NavigationDestination(
                  icon: Icon(n.icon, color: AppTheme.textMuted),
                  selectedIcon: Icon(n.selectedIcon, color: AppTheme.primary),
                  label: n.label,
                ))
            .toList(),
      ),
      floatingActionButton: _ChatFabWrapper(),
    );
  }

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('VitaAgent',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        // User chip
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primary,
                child: Text('RK',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aman',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  Text('Premium Plan',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Nav items
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: _navItems.asMap().entries.map((e) {
                final isActive = _currentIndex == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = e.key),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: isActive ? AppTheme.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isActive ? e.value.selectedIcon : e.value.icon,
                          size: 20,
                          color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          e.value.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Bottom
        const Divider(color: AppTheme.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _sidebarBottomItem(Icons.settings_outlined, 'Settings'),
              const SizedBox(height: 4),
              _sidebarBottomItem(Icons.logout_outlined, 'Logout'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sidebarBottomItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_navItems[_currentIndex].label,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, fontWeight: FontWeight.w600)),
          Row(
            children: [
              _buildNotifButton(),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary,
                child: Text('A',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotifButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: () => setState(() => _notifOpen = !_notifOpen),
          icon: const Icon(Icons.notifications_outlined),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
                color: AppTheme.primary, shape: BoxShape.circle),
            child: Center(
              child: Text('3',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotifDropdown() {
    return Positioned(
      top: 0,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text('Notifications',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w500, fontSize: 14)),
              ),
              const Divider(height: 1, color: AppTheme.border),
              ..._notifications.map((n) => InkWell(
                    onTap: () => setState(() => _notifOpen = false),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                                color: AppTheme.primary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n['text']!,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: AppTheme.textPrimary)),
                                const SizedBox(height: 2),
                                Text(n['time']!,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatFabWrapper extends StatefulWidget {
  @override
  State<_ChatFabWrapper> createState() => _ChatFabWrapperState();
}

class _ChatFabWrapperState extends State<_ChatFabWrapper> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    if (_open) {
      return SizedBox(
        width: 380,
        height: 560,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ChatPanel(onClose: () => setState(() => _open = false)),
            FloatingActionButton(
              onPressed: () => setState(() => _open = false),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.close),
            ),
          ],
        ),
      );
    }
    return FloatingActionButton(
      onPressed: () => setState(() => _open = true),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.chat_bubble_outline),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}