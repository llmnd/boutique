$mainPath = 'lib\main.dart'
$content = Get-Content -Path $mainPath -Raw

# Extraire _buildDebtsTab
$debtsTabStart = $content.IndexOf('  Widget _buildDebtsTab() {')
$debtsTabEnd = $content.IndexOf('  Widget _buildClientsTab() {')
$buildDebtsTab = $content.Substring($debtsTabStart, $debtsTabEnd - $debtsTabStart).TrimEnd()

# Extraire _buildClientsTab
$clientsTabStart = $content.IndexOf('  Widget _buildClientsTab() {')
$clientsTabEnd = $content.LastIndexOf('  }') + 3
$buildClientsTab = $content.Substring($clientsTabStart, $clientsTabEnd - $clientsTabStart)

# Écrire dans debt_list_builder.dart
$debtBuilderContent = @"
import 'package:flutter/material.dart';

class DebtListBuilder {
  Widget buildDebtsTab(
    BuildContext context,
    List<dynamic> debts,
    String searchQuery,
    bool isSearching,
    Map<String, bool> expandedClients,
    Function(String) toggleClientExpansion,
    Function(Map) onEditDebt,
    Function(Map) onDeleteDebt,
    Future Function()? onRefresh,
  ) {
$buildDebtsTab
      );
  }
}
"@

# Écrire dans clients_list_builder.dart
$clientBuilderContent = @"
import 'package:flutter/material.dart';

class ClientListBuilder {
$buildClientsTab
  }
}
"@

Set-Content -Path 'lib/builders/debt_list_builder.dart' -Value $debtBuilderContent
Set-Content -Path 'lib/builders/clients_list_builder.dart' -Value $clientBuilderContent

Write-Host "Extracted _buildDebtsTab: $(($buildDebtsTab | Measure-Object -Line).Lines) lines"
Write-Host "Extracted _buildClientsTab: $(($buildClientsTab | Measure-Object -Line).Lines) lines"
