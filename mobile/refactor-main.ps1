$mainPath = 'lib\main.dart'
$content = Get-Content -Path $mainPath -Raw

Write-Host "Starting refactoring..." -ForegroundColor Cyan

$replacements = @(
    @{ old = '_getTermClient\(\)'; new = 'HomePageMethods.getTermClient()'; name = '_getTermClient()' },
    @{ old = '_getTermClientUp\(\)'; new = 'HomePageMethods.getTermClientUp()'; name = '_getTermClientUp()' },
    @{ old = '_getClientName\('; new = 'HomePageMethods.getClientName('; name = '_getClientName(' },
    @{ old = '_getInitials\('; new = 'HomePageMethods.getInitials('; name = '_getInitials(' },
    @{ old = '_getAvatarColor\('; new = 'HomePageMethods.getAvatarColor('; name = '_getAvatarColor(' },
    @{ old = '_parseDouble\('; new = 'HomePageMethods.parseDouble('; name = '_parseDouble(' },
    @{ old = '_tsForDebt\('; new = 'HomePageMethods.tsForDebt('; name = '_tsForDebt(' },
    @{ old = '_calculateRemainingFromPayments\('; new = 'HomePageMethods.calculateRemainingFromPayments('; name = '_calculateRemainingFromPayments(' },
    @{ old = '_clientTotalRemaining\('; new = 'HomePageMethods.clientTotalRemaining('; name = '_clientTotalRemaining(' },
    @{ old = '_calculateNetBalance\(\)'; new = 'HomePageMethods.calculateNetBalance(debts)'; name = '_calculateNetBalance()' },
    @{ old = '_calculateTotalPrets\(\)'; new = 'HomePageMethods.calculateTotalPrets(debts)'; name = '_calculateTotalPrets()' },
    @{ old = '_calculateTotalEmprunts\(\)'; new = 'HomePageMethods.calculateTotalEmprunts(debts)'; name = '_calculateTotalEmprunts()' }
)

foreach ($replacement in $replacements) {
    $count = ($content | Select-String -Pattern $replacement.old -AllMatches).Matches.Count
    $content = $content -replace $replacement.old, $replacement.new
    Write-Host "Replaced $($replacement.name): $count times" -ForegroundColor Green
}

Set-Content -Path $mainPath -Value $content
Write-Host "File saved" -ForegroundColor Green

if (-not ($content -match "import 'utils/methods_extraction.dart'")) {
    $content = $content -replace "(import 'theme.dart';)", "import 'theme.dart';" + [Environment]::NewLine + "import 'utils/methods_extraction.dart';"
    Set-Content -Path $mainPath -Value $content
    Write-Host "Import added" -ForegroundColor Green
}

Write-Host "Refactoring complete" -ForegroundColor Cyan
