# Guide de Migration Automatique du main.dart

## Étape 1: Remplacements Bulk

Utilise les Find-Replace du VS Code avec Regex pour faire ces remplacements TOUS à la fois:

### Remplacements des appels de méthode

1. **_getTermClient()** → **HomePageMethods.getTermClient()**
   - Pattern: `_getTermClient\(\)`
   - Replace: `HomePageMethods.getTermClient()`

2. **_getTermClientUp()** → **HomePageMethods.getTermClientUp()**
   - Pattern: `_getTermClientUp\(\)`
   - Replace: `HomePageMethods.getTermClientUp()`

3. **_getClientName(** → **HomePageMethods.getClientName(**
   - Pattern: `_getClientName\(`
   - Replace: `HomePageMethods.getClientName(`

4. **_getInitials(** → **HomePageMethods.getInitials(**
   - Pattern: `_getInitials\(`
   - Replace: `HomePageMethods.getInitials(`

5. **_getAvatarColor(** → **HomePageMethods.getAvatarColor(**
   - Pattern: `_getAvatarColor\(`
   - Replace: `HomePageMethods.getAvatarColor(`

6. **_parseDouble(** → **HomePageMethods.parseDouble(**
   - Pattern: `_parseDouble\(`
   - Replace: `HomePageMethods.parseDouble(`

7. **_tsForDebt(** → **HomePageMethods.tsForDebt(**
   - Pattern: `_tsForDebt\(`
   - Replace: `HomePageMethods.tsForDebt(`

8. **_calculateRemainingFromPayments(** → **HomePageMethods.calculateRemainingFromPayments(**
   - Pattern: `_calculateRemainingFromPayments\(`
   - Replace: `HomePageMethods.calculateRemainingFromPayments(`

9. **_clientTotalRemaining(** → **HomePageMethods.clientTotalRemaining(**
   - Pattern: `_clientTotalRemaining\(`
   - Replace: `HomePageMethods.clientTotalRemaining(`

10. **_calculateNetBalance()** → **HomePageMethods.calculateNetBalance()**
    - Pattern: `_calculateNetBalance\(\)`
    - Replace: `HomePageMethods.calculateNetBalance()`

11. **_calculateTotalPrets()** → **HomePageMethods.calculateTotalPrets()**
    - Pattern: `_calculateTotalPrets\(\)`
    - Replace: `HomePageMethods.calculateTotalPrets()`

12. **_calculateTotalEmprunts()** → **HomePageMethods.calculateTotalEmprunts()**
    - Pattern: `_calculateTotalEmprunts\(\)`
    - Replace: `HomePageMethods.calculateTotalEmprunts()`

## Étape 2: Supprimer les vieilles définitions de méthodes

Une fois tous les appels remplacés, supprimer les définitions des méthodes du main.dart:

```dart
  String _getTermClient() { ... }
  String _getTermClientUp() { ... }
  String _getClientName(dynamic client) { ... }
  String _getInitials(String name) { ... }
  Color _getAvatarColor(dynamic client) { ... }
  double _parseDouble(dynamic value) { ... }
  double _tsForDebt(dynamic debt) { ... }
  double _calculateRemainingFromPayments(Map debt, List paymentList) { ... }
  double _clientTotalRemaining(dynamic clientId) { ... }
  double _calculateNetBalance() { ... }
  double _calculateTotalPrets() { ... }
  double _calculateTotalEmprunts() { ... }
  Widget _buildInitialsAvatar(String initials, double size) { ... }
  Widget _buildClientAvatarWidget(dynamic client, double size) { ... }
```

Cela supprimera ~500-600 lignes du main.dart!

## Résultat Final

- **Avant**: 3291 lignes
- **Après suppression des méthodes extraites**: ~2600-2700 lignes
- **Avec extraction future de _buildDebtsTab et _buildClientsTab**: ~300-400 lignes (cible finale)

## Bénéfices

✅ Code plus modulaire et testable
✅ Réutilisation des méthodes partout
✅ Respect du Single Responsibility Principle
✅ main.dart concentré sur les responsabilités principales
✅ Maintenance améliorée
