$mainPath = 'lib\main.dart'
$content = Get-Content -Path $mainPath -Raw

Write-Host "Deleting old method definitions..." -ForegroundColor Cyan

# Méthodes à supprimer entièrement
$patterns = @(
    "  double HomePageMethods\.tsForDebt\(dynamic debt\) \{.*?\n  \}",
    "  double HomePageMethods\.parseDouble\(dynamic value\) \{.*?\n  \}",
    "  double HomePageMethods\.calculateRemainingFromPayments\(Map debt, List paymentList\) \{.*?\n  \}",
    "double HomePageMethods\.clientTotalRemaining\(dynamic clientId\) \{.*?\n\}",
    "  double HomePageMethods\.calculateNetBalance\(debts\) \{.*?\n  \}",
    "  double HomePageMethods\.calculateTotalPrets\(debts\) \{.*?\n  \}",
    "  double HomePageMethods\.calculateTotalEmprunts\(debts\) \{.*?\n  \}",
    "  String HomePageMethods\.getTermClient\(\) \{.*?\n  \}",
    "  String HomePageMethods\.getTermClientUp\(\) \{.*?\n  \}",
    "  String HomePageMethods\.getClientName\(dynamic client\) \{.*?\n  \}",
    "  String HomePageMethods\.getInitials\(String name\) \{.*?\n  \}",
    "  Color HomePageMethods\.getAvatarColor\(dynamic client\) \{.*?\n  \}"
)

foreach ($pattern in $patterns) {
    $content = $content -replace $pattern, '', [System.Text.RegularExpressions.RegexOptions]::Singleline -or [System.Text.RegularExpressions.RegexOptions]::Multiline
    Write-Host "Removed pattern" -ForegroundColor Green
}

Set-Content -Path $mainPath -Value $content
Write-Host "Old method definitions deleted" -ForegroundColor Green
