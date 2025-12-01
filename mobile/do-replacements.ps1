(Get-Content 'lib\main.dart' -Raw) `
-replace '_getTermClient\(\)', 'HomePageMethods.getTermClient()' `
-replace '_getTermClientUp\(\)', 'HomePageMethods.getTermClientUp()' `
-replace '_getClientName\(', 'HomePageMethods.getClientName(' `
-replace '_getInitials\(', 'HomePageMethods.getInitials(' `
-replace '_getAvatarColor\(', 'HomePageMethods.getAvatarColor(' `
-replace '_parseDouble\(', 'HomePageMethods.parseDouble(' `
-replace '_tsForDebt\(', 'HomePageMethods.tsForDebt(' `
-replace '_calculateRemainingFromPayments\(', 'HomePageMethods.calculateRemainingFromPayments(' `
-replace '_clientTotalRemaining\(', 'HomePageMethods.clientTotalRemaining(' `
-replace '_calculateNetBalance\(\)', 'HomePageMethods.calculateNetBalance(debts)' `
-replace '_calculateTotalPrets\(\)', 'HomePageMethods.calculateTotalPrets(debts)' `
-replace '_calculateTotalEmprunts\(\)', 'HomePageMethods.calculateTotalEmprunts(debts)' | `
Set-Content 'lib\main.dart'

Write-Host "Replacements done!" -ForegroundColor Green
