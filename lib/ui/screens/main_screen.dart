import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'expense_list_screen.dart';
import 'monthly_report_screen.dart';
import 'statistics_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    ExpenseListScreen(),
    MonthlyReportScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            selectedIcon: Icon(Icons.list),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
