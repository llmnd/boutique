import 'package:flutter/material.dart';

/// 📱 Widget pour afficher la HomePage sans la complexité du main.dart
/// Ce widget encapsule toute la logique UI en gardant l'état simple

class HomePageView extends StatelessWidget {
  final int tabIndex;
  final String debtSubTab;
  final bool isSearching;
  final bool showTotalCard;
  final bool showAmountFilter;
  final double minDebtAmount;
  final double maxDebtAmount;
  final double totalPrets;
  final double totalEmprunts;
  final int totalUnpaid;
  final List debts;
  final List clients;
  final String searchQuery;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final Set expandedClients;
  
  final VoidCallback onSearchToggle;
  final VoidCallback onTabChanged;
  final ValueChanged<String> onDebtSubTabChanged;
  final VoidCallback onFilterToggle;
  final ValueChanged<double> onMinAmountChanged;
  final ValueChanged<double> onMaxAmountChanged;
  final VoidCallback onAddChoice;
  final VoidCallback onSync;
  final ValueChanged<String> onSearch;

  const HomePageView({
    required this.tabIndex,
    required this.debtSubTab,
    required this.isSearching,
    required this.showTotalCard,
    required this.showAmountFilter,
    required this.minDebtAmount,
    required this.maxDebtAmount,
    required this.totalPrets,
    required this.totalEmprunts,
    required this.totalUnpaid,
    required this.debts,
    required this.clients,
    required this.searchQuery,
    required this.searchController,
    required this.searchFocus,
    required this.expandedClients,
    required this.onSearchToggle,
    required this.onTabChanged,
    required this.onDebtSubTabChanged,
    required this.onFilterToggle,
    required this.onMinAmountChanged,
    required this.onMaxAmountChanged,
    required this.onAddChoice,
    required this.onSync,
    required this.onSearch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabIndex == 0 
        ? _buildDebtsView()
        : _buildClientsView(),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDebtsView() {
    return Center(child: Text('Debts View - TODO'));
  }

  Widget _buildClientsView() {
    return Center(child: Text('Clients View - TODO'));
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.trending_down), label: 'Dettes'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
      ],
      currentIndex: tabIndex,
      onTap: (_) => onTabChanged(),
    );
  }
}
