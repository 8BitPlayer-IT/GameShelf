# Prepara i file di una release: nomi leggibili e impronte SHA-256 da incollare
# nelle note.
#
# Uso, dopo "flutter build apk --release --split-per-abi":
#   .\tool\prepara_release.ps1
#
# PERCHE SERVE. Flutter chiama i suoi file app-arm64-v8a-release.apk: va bene per
# una cartella di lavoro, non per una pagina da cui scarica altra gente. Qui
# diventano GameShelf-<versione>-<architettura>.apk, con l'architettura scritta in
# una parola comprensibile (arm64, arm32) invece che nel gergo di Android.
#
# I file restano TRE e non si possono unire in un APK universale: Flutter somma al
# numero di build un valore diverso per architettura (2000 per arm64), quindi un
# file universale porterebbe un numero piu basso di quelli gia installati e Android
# lo rifiuterebbe come retrocessione. Vedi TOOLCHAIN.md.
#
# Rinominare NON cambia i byte, quindi le impronte restano valide anche se il nome
# del file cambia.

$ErrorActionPreference = 'Stop'

$radice = Split-Path -Parent $PSScriptRoot
$sorgente = Join-Path $radice 'build\app\outputs\flutter-apk'
$destinazione = Join-Path $radice 'build\release'

# La versione viene dal pubspec, non si scrive a mano: se le due si scostassero, il
# nome del file direbbe una bugia.
$pubspec = Get-Content (Join-Path $radice 'pubspec.yaml') -Raw
if ($pubspec -notmatch '(?m)^version:\s*(\d+\.\d+\.\d+)\+\d+\s*$') {
    throw "Non trovo la riga «version: x.y.z+n» in pubspec.yaml"
}
$versione = $Matches[1]

$architetture = [ordered]@{
    'app-arm64-v8a-release.apk'   = 'arm64'
    'app-armeabi-v7a-release.apk' = 'arm32'
    'app-x86_64-release.apk'      = 'x86_64'
}

if (Test-Path $destinazione) { Remove-Item $destinazione -Recurse -Force }
New-Item -ItemType Directory -Path $destinazione | Out-Null

$righe = @()
foreach ($voce in $architetture.GetEnumerator()) {
    $origine = Join-Path $sorgente $voce.Key
    if (-not (Test-Path $origine)) {
        throw "Manca $($voce.Key): esegui prima «flutter build apk --release --split-per-abi»"
    }
    $nuovo = "GameShelf-$versione-$($voce.Value).apk"
    $arrivo = Join-Path $destinazione $nuovo
    Copy-Item $origine $arrivo
    $impronta = (Get-FileHash $arrivo -Algorithm SHA256).Hash.ToLower()
    $peso = [math]::Round((Get-Item $arrivo).Length / 1MB, 1)
    $righe += "$impronta  $nuovo"
    Write-Output "  $nuovo  $peso MB"
}

Write-Output ''
Write-Output "File pronti in build\release. Impronte da incollare nelle note della release:"
Write-Output ''
Write-Output '```'
$righe | ForEach-Object { Write-Output $_ }
Write-Output '```'
Write-Output ''
Write-Output "Pubblicare con:"
Write-Output "  gh release create v$versione --target main --title ""GameShelf $versione"" --notes-file <note> build\release\*.apk"
