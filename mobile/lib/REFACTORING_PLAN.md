# Refactorisation du main.dart

## État actuel
- **3291 lignes** dans lib/main.dart
- **MyApp** (95 lignes) - Gestion du thème et de l'owner
- **HomePage** (2970 lignes) - Widget principal avec toute la logique

## Bloc logiques identifiés et à extraire

### ✅ FAIT - Fichiers Utils créés
- `utils/debt_calculations.dart` - Calculs de dettes
- `utils/helper_strings.dart` - Formatage de texte et strings
- `utils/avatar_builder.dart` - Construction d'avatars
- `utils/home_state_manager.dart` - Gestion d'état
- `utils/tabs_builder.dart` - Builders des onglets
- `builders/debt_list_builder.dart` - UI des cartes de dettes
- `builders/clients_list_builder.dart` - UI des cartes de clients

###  À FAIRE IMMÉDIATEMENT
1. **Extraire les méthodes helper simples** vers un utils
   - `_getTermClient()` → `HelperStrings.getTermClient()`
   - `_getTermClientUp()` → `HelperStrings.getTermClientUp()`
   - `_getClientName()` → `HelperStrings.getClientName()`
   - `_getInitials()` → `HelperStrings.getInitials()`
   - `_getAvatarColor()` → `HelperStrings.getAvatarColor()`

2. **Extraire les méthodes de calcul**
   - `_parseDouble()` → `DebtCalculations.parseDouble()`
   - `_tsForDebt()` → `DebtCalculations.tsForDebt()`
   - `_calculateRemainingFromPayments()` → `DebtCalculations.calculateRemainingFromPayments()`
   - `_calculateNetBalance()` → `DebtCalculations.calculateNetBalance()`
   - `_calculateTotalPrets()` → `DebtCalculations.calculateTotalPrets()`
   - `_calculateTotalEmprunts()` → `DebtCalculations.calculateTotalEmprunts()`

3. **Extraire les handlers de dialogues**
   - `_showAddChoice()` → `dialogs/add_choice_dialog.dart`
   - `_showClientActions()` → `dialogs/client_actions_dialog.dart`

## Structure finale cible
```
main.dart (250-300 lignes)
├── main()
├── MyApp
├── HomePage
│   ├── State init/dispose
│   ├── build() - Appelle les builders
│   └── Event handlers
│
utils/
├── debt_calculations.dart ✅
├── helper_strings.dart ✅
├── avatar_builder.dart ✅
├── home_state_manager.dart ✅
└── tabs_builder.dart ✅

builders/
├── debt_list_builder.dart ✅
└── clients_list_builder.dart ✅

dialogs/
├── add_choice_dialog.dart
└── client_actions_dialog.dart
```
