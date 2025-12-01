$mainPath = 'lib\main.dart'
$content = Get-Content -Path $mainPath -Raw

Write-Host "Step 1: Removing old private method definitions..." -ForegroundColor Cyan

# Remove all the old private method definitions
# These start with _ and we want to remove them completely

$methodsToRemove = @(
    # _getTermClient and _getTermClientUp
    @"

  String _getTermClient\(\) \{
    return AppSettings\(\)\.boutiqueModeEnabled \? 'client' : 'contact';
  \}
"@,
    @"

  String _getTermClientUp\(\) \{
    return AppSettings\(\)\.boutiqueModeEnabled \? 'CLIENT' : 'CONTACT';
  \}
"@,
    # _getClientName
    @"

  // 🆕 Fonction helper robuste pour extraire le nom du client
  String _getClientName\(dynamic client\) \{
    if \(client == null\) return AppSettings\(\)\.boutiqueModeEnabled \? 'Client' : 'Contact';
    
    final name = client\['name'\];
    if \(name != null && name is String && name\.isNotEmpty && name != 'null'\) \{
      return name;
    \}
    
    // Fallback si pas de nom valide
    return AppSettings\(\)\.boutiqueModeEnabled \? 'Client' : 'Contact';
  \}
"@,
    # _getInitials
    @"

  // Build client avatar similar to DebtDetailsPage
  String _getInitials\(String name\) \{
    final parts = name\.split\(' '\);
    if \(parts\.length >= 2\) \{
      return '\$\{parts\[0\]\[0\]\}\$\{parts\[1\]\[0\]\}'\.toUpperCase\(\);
    \} else if \(name\.isNotEmpty\) \{
      return name\.substring\(0, 1\)\.toUpperCase\(\);
    \}
    return 'C';
  \}
"@,
    # _getAvatarColor
    @"

  // ✅ NOUVEAU : Générer une couleur stable et subtile basée sur le nom du client
  Color _getAvatarColor\(dynamic client\) \{
    final clientName = _getClientName\(client\);
    final hash = clientName\.hashCode;
    
    // Palette de couleurs subtiles et minimalistes
    const colors = \[
      Color\(0xFF6B5B95\),  // Violet subtil
      Color\(0xFF88A86C\),  // Vert sage
      Color\(0xFF9B8B7E\),  // Taupe
      Color\(0xFF7B9DBE\),  // Bleu gris
      Color\(0xFFA69B84\),  // Beige
      Color\(0xFF8B7F9A\),  // Lavande
      Color\(0xFF7F9F9D\),  // Teal subtil
      Color\(0xFF9B8B70\),  // Ocre
    \];
    
    return colors\[hash\.abs\(\) % colors\.length\];
  \}
"@
)

foreach ($method in $methodsToRemove) {
    $content = $content -replace $method, '', [System.Text.RegularExpressions.RegexOptions]::Multiline
    Write-Host "Removed one method" -ForegroundColor Green
}

# Now do the same for the more complex methods like _tsForDebt, _parseDouble, etc
# These have many lines so we'll be more careful

# Actually, let's just add the import and do replacements
Write-Host "Step 2: Adding import for HomePageMethods..." -ForegroundColor Cyan

if (-not ($content -match "import 'utils/methods_extraction.dart'")) {
    $content = $content -replace "(import 'theme.dart';)", "`$1`r`nimport 'utils/methods_extraction.dart';"
    Write-Host "Import added" -ForegroundColor Green
}

Write-Host "Step 3: Replacing method calls..." -ForegroundColor Cyan

# Now do all the replacements
$replacements = @(
    @{ old = '_getTermClient\(\)'; new = 'HomePageMethods.getTermClient()' },
    @{ old = '_getTermClientUp\(\)'; new = 'HomePageMethods.getTermClientUp()' },
    @{ old = '_getClientName\('; new = 'HomePageMethods.getClientName(' },
    @{ old = '_getInitials\('; new = 'HomePageMethods.getInitials(' },
    @{ old = '_getAvatarColor\('; new = 'HomePageMethods.getAvatarColor(' },
    @{ old = '_parseDouble\('; new = 'HomePageMethods.parseDouble(' },
    @{ old = '_tsForDebt\('; new = 'HomePageMethods.tsForDebt(' },
    @{ old = '_calculateRemainingFromPayments\('; new = 'HomePageMethods.calculateRemainingFromPayments(' },
    @{ old = '_clientTotalRemaining\('; new = 'HomePageMethods.clientTotalRemaining(' },
    @{ old = '_calculateNetBalance\(\)'; new = 'HomePageMethods.calculateNetBalance(debts)' },
    @{ old = '_calculateTotalPrets\(\)'; new = 'HomePageMethods.calculateTotalPrets(debts)' },
    @{ old = '_calculateTotalEmprunts\(\)'; new = 'HomePageMethods.calculateTotalEmprunts(debts)' }
)

foreach ($rep in $replacements) {
    $count = ($content | Select-String -Pattern $rep.old -AllMatches).Matches.Count
    $content = $content -replace $rep.old, $rep.new
    Write-Host "Replaced $($rep.old): $count times" -ForegroundColor Green
}

Set-Content -Path $mainPath -Value $content
Write-Host "All done! main.dart has been refactored" -ForegroundColor Cyan
