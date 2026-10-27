$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$privateDir = Join-Path $projectRoot '.private'
$keyFile = Join-Path $privateDir 'articulate-release.jks'
$configFile = Join-Path $privateDir 'android-signing.properties'
if ((Test-Path -LiteralPath $keyFile) -or (Test-Path -LiteralPath $configFile)) {
    throw 'Signing material already exists. Preserve it; this script never rotates or overwrites a key.'
}
$keytool = if ($env:JAVA_HOME) { Join-Path $env:JAVA_HOME 'bin/keytool.exe' } else { 'C:/Program Files/Eclipse Adoptium/jdk-21.0.7.6-hotspot/bin/keytool.exe' }
if (-not (Test-Path -LiteralPath $keytool)) { throw 'Set JAVA_HOME to an installed JDK.' }
New-Item -ItemType Directory -Force -Path $privateDir | Out-Null
# Set access before creating secrets; keep the key out of disposable tool caches.
$acl = [System.Security.AccessControl.DirectorySecurity]::new()
$acl.SetAccessRuleProtection($true, $false)
$sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
$rule = [System.Security.AccessControl.FileSystemAccessRule]::new($sid, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
$acl.AddAccessRule($rule)
Set-Acl -LiteralPath $privateDir -AclObject $acl
$randomBytes = [byte[]]::new(32)
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($randomBytes)
$rng.Dispose()
$env:ARTICULATE_KEY_PASSWORD = [Convert]::ToBase64String($randomBytes)
try {
    & $keytool -genkeypair -keystore $keyFile -storetype JKS -alias articulate-release -keyalg RSA -keysize 3072 -validity 10000 -dname 'CN=Articulate Private Release' -storepass:env ARTICULATE_KEY_PASSWORD -keypass:env ARTICULATE_KEY_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'Key generation failed. Inspect private files before retrying.' }
    $properties = "storeFile=../.private/articulate-release.jks`nkeyAlias=articulate-release`nstorePassword=$env:ARTICULATE_KEY_PASSWORD`nkeyPassword=$env:ARTICULATE_KEY_PASSWORD`n"
    [IO.File]::WriteAllText($configFile, $properties, [Text.UTF8Encoding]::new($false))
    & $keytool -list -keystore $keyFile -alias articulate-release -storepass:env ARTICULATE_KEY_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'Generated key could not be reopened.' }
    Write-Output 'Private signing created and reopened. Back up the complete .private directory securely before relying on this key for updates.'
} finally {
    Remove-Item Env:ARTICULATE_KEY_PASSWORD
    $properties = $null
    [Array]::Clear($randomBytes, 0, $randomBytes.Length)
}
