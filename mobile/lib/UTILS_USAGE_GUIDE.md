# 📚 Guide d'Utilisation des Nouveaux Modules Utils

## Vue d'ensemble

Vous avez maintenant à votre disposition **7 modules utils** qui rendent le code plus modulaire et réutilisable.

### 1. `utils/debt_calculations.dart`
Tous les calculs liés aux dettes.

**Exemples d'utilisation**:
```dart
// Calculer le montant restant d'une dette
double remaining = DebtCalculations.parseDouble(debt['remaining']);

// Obtenir le timestamp d'une dette pour tri
double ts = DebtCalculations.tsForDebt(debt);

// Calculer l'équilibre net
double netBalance = DebtCalculations.calculateNetBalance(debts);

// Calcul des totaux
double prets = DebtCalculations.calculateTotalPrets(debts);
double emprunts = DebtCalculations.calculateTotalEmprunts(debts);
```

### 2. `utils/helper_strings.dart`
Formatage de texte et strings avec support mode boutique.

**Exemples d'utilisation**:
```dart
// Texte conditionnellement "client" ou "contact"
String term = HelperStrings.getTermClient(isBoutiqueMode);

// Majuscules
String termUp = HelperStrings.getTermClientUp(isBoutiqueMode);

// Nom du client avec fallback
String name = HelperStrings.getClientName(client, isBoutiqueMode: true);

// Initiales pour avatar
String initials = HelperStrings.getInitials('Jean Dupont'); // "JD"

// Couleur avatar
Color color = HelperStrings.getAvatarColor(client);

// Statut
String status = HelperStrings.getDebtStatus(debt, isLoan: false);
```

### 3. `utils/avatar_builder.dart`
Construction d'avatars réutilisables.

**Exemples d'utilisation**:
```dart
// Avatar simple avec initiales
Widget avatar = AvatarBuilder.buildInitialsAvatar('JD', 44);

// Avatar client complet
Widget clientAvatar = AvatarBuilder.buildClientAvatarWidget(
  client,
  48,
  getInitials: (name) => HelperStrings.getInitials(name),
  getAvatarColor: (c) => HelperStrings.getAvatarColor(c),
);
```

### 4. `utils/home_state_manager.dart`
Gestion d'état centralisée (alternative à un Provider/Riverpod).

**Exemples d'utilisation**:
```dart
// Créer un manager
HomePageStateManager stateManager = HomePageStateManager();

// Basculer onglet
stateManager.switchTab(0);

// Gérer les expansions
stateManager.toggleClientExpansion('client_123');
bool isOpen = stateManager.isClientExpanded('client_123');

// Basculer recherche
stateManager.toggleSearch();

// Réinitialiser
stateManager.resetFilters();
stateManager.reset(); // Tout
```

### 5. `utils/tabs_builder.dart`
Builders pour les sections d'onglets.

**Exemples d'utilisation**:
```dart
// Header de l'onglet dettes
Widget header = TabsBuilder.buildDebtsTabHeader(
  context,
  totalPrets: 5000,
  totalEmprunts: 2000,
  unpaidCount: 3,
  formatter: (amount) => AppSettings().formatCurrency(amount),
);

// Sous-onglets
Widget subTabs = TabsBuilder.buildDebtSubTabs(
  context,
  activeSubTab: 'prets',
  onTabChanged: (tab) => print('Tab: $tab'),
);
```

### 6. `utils/methods_extraction.dart`
Classe centralisée avec 20+ méthodes extraites.

**Remplace les vieux appels**:
```dart
// À la place de:
double value = _parseDouble(someValue);

// Utilisez:
double value = HomePageMethods.parseDouble(someValue);

// À la place de:
String term = _getTermClient();

// Utilisez:
String term = HomePageMethods.getTermClient();
```

### 7. `builders/debt_list_builder.dart` & `builders/clients_list_builder.dart`
Widgets UI réutilisables pour les cartes.

**Exemples d'utilisation**:
```dart
// Carte de dette
Widget debtCard = DebtListBuilder.buildDebtCard(
  context: context,
  clientName: 'Jean Dupont',
  clientPhone: '123456789',
  totalRemaining: 5000,
  txType: 'debt',
  isOpen: false,
  onTap: () => print('Tapped'),
  onLongPress: () => print('Long pressed'),
  avatar: avatarWidget,
  amountDisplay: amountWidget,
  actionMenu: menuWidget,
  expandedContent: expandedWidget,
);
```

---

## 🎯 Exemple Complet: Remplacer une Méthode

### Avant (dans main.dart)
```dart
class _HomePageState extends State<HomePage> {
  String _getTermClient() {
    return AppSettings().boutiqueModeEnabled ? 'client' : 'contact';
  }

  @override
  Widget build(BuildContext context) {
    final term = _getTermClient();
    return Text('Ajouter un $term');
  }
}
```

### Après (avec utils)
```dart
import 'utils/methods_extraction.dart';

class _HomePageState extends State<HomePage> {
  // Plus besoin de _getTermClient() ici!

  @override
  Widget build(BuildContext context) {
    final term = HomePageMethods.getTermClient();
    return Text('Ajouter un $term');
  }
}
```

---

## 📊 Avantages

| Aspect | Avant | Après |
|--------|-------|-------|
| **Réutilisation** | Impossible entre files | ✅ Facile |
| **Testabilité** | Difficile (methods priées) | ✅ Facile (static methods) |
| **Maintenabilité** | Dispersée | ✅ Centralisée |
| **Composabilité** | Peu flexible | ✅ Très flexible |

---

## 🔗 Intégration avec Premium Design System

Les modules utils s'intègrent parfaitement avec les premium widgets:

```dart
import 'utils/helper_strings.dart';
import 'widgets/premium_components.dart';

// Combiner les deux!
Widget card = PremiumCard(
  child: Column(
    children: [
      Text(
        HelperStrings.getClientName(client, isBoutiqueMode: true),
        style: PremiumTextStyles.headingS(context),
      ),
      // ...
    ],
  ),
);
```

---

## ✅ Checklist Utilisation

- [ ] Importer le module dont vous avez besoin
- [ ] Appeler la méthode statique appropriée
- [ ] Supprimer la vieille implémentation du main.dart
- [ ] Compiler et tester

Voilà! Vous avez une structure de code beaucoup plus professionnelle et maintenable. 🎉
