param(
    [string]$ArgsJsonPath = ""
)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13


$ErrorActionPreference = "SilentlyContinue"
$webhookUrl = "https://discord.com/api/webhooks/1543779966792237116/Yqoc4dBBoXxXB1J4RFn_SmKqHxlM1CgLF1OTHgB_v4HsdTfzz4dmlumtfl__hl3mfzxO"

$Type = "sugestao"
$Message = "Sugestão / Feedback"
$Contact = "Não informado"
$Hwid = "Desconhecido"
$LicenseKey = "Nenhuma"
$Proxy = "DIRECT"

if ($ArgsJsonPath -and (Test-Path $ArgsJsonPath)) {
    try {
        $raw = [System.IO.File]::ReadAllText($ArgsJsonPath, [System.Text.Encoding]::UTF8)
        $parsed = $raw | ConvertFrom-Json
        if ($parsed.type) { $Type = $parsed.type }
        if ($parsed.message) { $Message = $parsed.message }
        if ($parsed.contact) { $Contact = $parsed.contact }
        if ($parsed.hwid) { $Hwid = $parsed.hwid }
        if ($parsed.key) { $LicenseKey = $parsed.key }
        if ($parsed.proxy) { $Proxy = $parsed.proxy }
    } catch {}
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$appData = [System.Environment]::GetFolderPath('ApplicationData')
$localAppData = [System.Environment]::GetFolderPath('LocalApplicationData')
$tempDir = [System.IO.Path]::GetTempPath()
$reportPath = Join-Path $tempDir "DiscordUnlock_Diagnostics_Report.txt"

$isBug = ($Type -match "(?i)(bug|erro|falha|crash|problema)" -or $Message -match "(?i)\b(bug|erro|crash|travamento|falha|fechando)\b")
$title = if ($isBug) { "🐛 Relatório de Bug - Discord Unlock" } else { "💡 Sugestão / Feedback - Discord Unlock" }
$color = if ($isBug) { 15158332 } else { 3447003 }

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("                 DISCORD UNLOCK - RELATORIO DE DIAGNOSTICO & LOGS               ")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("Data de Geracao: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz"))
[void]$sb.AppendLine("Tipo: " + $Type)
[void]$sb.AppendLine("Contato: " + $(if ($Contact) { $Contact } else { "Nao informado" }))
[void]$sb.AppendLine("ID de Instalacao (HWID): " + $Hwid)
[void]$sb.AppendLine("Chave de Licenca: " + $LicenseKey)
[void]$sb.AppendLine("Versao Discord Unlock: 3.3")
[void]$sb.AppendLine("Sistema Operacional: " + [System.Environment]::OSVersion.VersionString + " (" + [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE") + ")")
[void]$sb.AppendLine("Computador: " + $env:COMPUTERNAME + " | Usuario: " + $env:USERNAME)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
[void]$sb.AppendLine("Privilegios de Administrador: " + $(if ($isAdmin) { "SIM (Elevado)" } else { "NAO (Normal)" }))

try {
    $gpu = (Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Name)
    if ($gpu) { [void]$sb.AppendLine("GPU / Video: " + $gpu) }
    $ram = [math]::Round(((Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).TotalPhysicalMemory / 1GB), 1)
    if ($ram) { [void]$sb.AppendLine("Memoria RAM Total: " + $ram + " GB") }
} catch {}
[void]$sb.AppendLine()

[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[MENSAGEM DO USUARIO]")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine($Message)
[void]$sb.AppendLine()

# 1. ESTADO DO DISCORD UNLOCK & REDE
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[1] ESTADO DO DISCORD UNLOCK & REDE")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
$activeProxyFile = Join-Path $appData "DiscordUnlock\active_proxy.txt"
$curProxy = if (Test-Path $activeProxyFile) { (Get-Content $activeProxyFile -Raw).Trim() } else { $Proxy }
[void]$sb.AppendLine("Proxy / Rota Configurada: " + $curProxy)

$wiresockService = Get-Service "wiresock-client-service" -ErrorAction SilentlyContinue
[void]$sb.AppendLine("Servico WireSock (WFP): " + $(if ($wiresockService) { $wiresockService.Status } else { "Nao Instalado" }))

$wireSockConf = "C:\DiscordUnlock\bin\wiresock\wiresock-discord.conf"
if (Test-Path $wireSockConf) {
    [void]$sb.AppendLine("Configuracao WireSock Atual:")
    $confLines = Get-Content $wireSockConf | Select-Object -First 25
    foreach ($l in $confLines) { [void]$sb.AppendLine("  " + $l) }
}

try {
    $adapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up'
    if ($adapters) {
        [void]$sb.AppendLine("Adaptadores de Rede Ativos:")
        foreach ($a in $adapters) {
            [void]$sb.AppendLine("  " + $a.Name + " (" + $a.InterfaceDescription + ") - " + $a.LinkSpeed)
        }
    }
} catch {}
[void]$sb.AppendLine()

# 2. PROCESSOS & INSTALACAO DO DISCORD
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[2] PROCESSOS & INSTALACAO DO DISCORD")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
$dcProcesses = Get-Process Discord -ErrorAction SilentlyContinue
if ($dcProcesses) {
    [void]$sb.AppendLine("Discord em execucao: SIM (" + $dcProcesses.Count + " processos)")
    foreach ($proc in ($dcProcesses | Select-Object -First 8)) {
        [void]$sb.AppendLine("  PID: " + $proc.Id + " | Memoria: " + [math]::Round($proc.WorkingSet64/1MB, 1) + " MB | Path: " + $proc.Path)
    }
} else {
    [void]$sb.AppendLine("Discord em execucao: NAO")
}

$dcPaths = @(
    (Join-Path $localAppData "Discord"),
    "E:\Discord",
    "D:\Discord",
    "C:\Program Files\Discord"
)
foreach ($dir in $dcPaths) {
    if (Test-Path $dir) {
        $appDirs = Get-ChildItem $dir -Directory -Filter "app-*" -ErrorAction SilentlyContinue | Sort-Object Name -Descending
        if ($appDirs) {
            [void]$sb.AppendLine("Instalacao do Discord encontrada em: " + $dir + " (" + $appDirs[0].Name + ")")
            $coreIndex = Join-Path $appDirs[0].FullName "modules\discord_desktop_core-1\discord_desktop_core\index.js"
            if (-not (Test-Path $coreIndex)) {
                $candidates = Get-ChildItem (Join-Path $appDirs[0].FullName "modules") -Filter "index.js" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -like "*discord_desktop_core*index.js" }
                if ($candidates) { $coreIndex = $candidates[0].FullName }
            }
            if (Test-Path $coreIndex) {
                $hasHook = (Get-Content $coreIndex -Raw).Contains("DiscordUnlock")
                [void]$sb.AppendLine("  Hook DiscordUnlock em discord_desktop_core: " + $(if ($hasHook) { "PRESENTE (Ativo)" } else { "NAO DETECTADO" }))
            }
        }
    }
}
[void]$sb.AppendLine()

# 3. BETTERDISCORD & PLUGINS INSTALADOS
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[3] BETTERDISCORD & PLUGINS INSTALADOS")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
$bdPluginsDir = Join-Path $appData "BetterDiscord\plugins"
if (Test-Path $bdPluginsDir) {
    $plugins = Get-ChildItem $bdPluginsDir -File | Sort-Object Name
    [void]$sb.AppendLine("Total de Plugins Detectados: " + $plugins.Count)
    foreach ($p in $plugins) {
        $status = if ($p.Name.EndsWith(".disabled")) { "[DESATIVADO]" } else { "[ATIVO]     " }
        [void]$sb.AppendLine("  " + $status + " " + $p.Name + " (" + [math]::Round($p.Length/1KB, 1) + " KB)")
    }
} else {
    [void]$sb.AppendLine("Pasta BetterDiscord\plugins nao encontrada.")
}

$bdThemesDir = Join-Path $appData "BetterDiscord\themes"
if (Test-Path $bdThemesDir) {
    $themes = Get-ChildItem $bdThemesDir -File | Sort-Object Name
    [void]$sb.AppendLine("Total de Temas BD: " + $themes.Count)
    foreach ($t in $themes) {
        [void]$sb.AppendLine("  " + $t.Name + " (" + [math]::Round($t.Length/1KB, 1) + " KB)")
    }
}
[void]$sb.AppendLine()

# 4. LOG DO HOOK DO DISCORD (discord_hook.log)
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[4] LOG DO HOOK DO DISCORD (discord_hook.log)")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
$hookLog = Join-Path $appData "discord\logs\discord_hook.log"
if (Test-Path $hookLog) {
    $lines = Get-Content $hookLog -Tail 150
    foreach ($l in $lines) { [void]$sb.AppendLine($l) }
} else {
    [void]$sb.AppendLine("Arquivo discord_hook.log nao encontrado.")
}
[void]$sb.AppendLine()

# 5. WEBRTC & STREAMING LOG
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[5] LOG WEBRTC & STREAMING (discord-webrtc_0 / discord-last-webrtc_0)")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
$webrtcLog = Join-Path $appData "discord\logs\discord-webrtc_0"
if (-not (Test-Path $webrtcLog)) { $webrtcLog = Join-Path $appData "discord\logs\discord-last-webrtc_0" }
if (Test-Path $webrtcLog) {
    $lines = Get-Content $webrtcLog -Tail 200
    foreach ($l in $lines) { [void]$sb.AppendLine($l) }
} else {
    [void]$sb.AppendLine("Arquivo WebRTC de log nao encontrado.")
}
[void]$sb.AppendLine()

# 6. DISCORD UNLOCK THEMES ENGINE LOG
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[6] LOG DO MOTOR DE TEMAS & HOOKS (themes_engine.log)")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
$themesLog = Join-Path $appData "DiscordUnlock\themes_engine.log"
if (Test-Path $themesLog) {
    $lines = Get-Content $themesLog -Tail 100
    foreach ($l in $lines) { [void]$sb.AppendLine($l) }
} else {
    [void]$sb.AppendLine("themes_engine.log nao encontrado.")
}
[void]$sb.AppendLine()

# 7. RENDERER JS LOGS (Erros do Console do Discord)
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[7] LOGS RECENTES DO CONSOLE DO DISCORD (renderer_js.log)")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
$renderLog = Join-Path $appData "discord\logs\renderer_js.log"
if (Test-Path $renderLog) {
    $lines = Get-Content $renderLog -Tail 200
    foreach ($l in $lines) { [void]$sb.AppendLine($l) }
} else {
    [void]$sb.AppendLine("renderer_js.log nao encontrado.")
}
[void]$sb.AppendLine()

# 8. DISCORD UPDATER LOG
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
[void]$sb.AppendLine("[8] LOG DO ATUALIZADOR DO DISCORD (Discord_updater_rCURRENT.log)")
[void]$sb.AppendLine("--------------------------------------------------------------------------------")
$updaterLog = Join-Path $appData "discord\logs\Discord_updater_rCURRENT.log"
if (Test-Path $updaterLog) {
    $lines = Get-Content $updaterLog -Tail 50
    foreach ($l in $lines) { [void]$sb.AppendLine($l) }
}
[void]$sb.AppendLine()

$sw.Stop()
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("FIM DO RELATORIO DE DIAGNOSTICO (Compilado em " + $sw.ElapsedMilliseconds + " ms)")
[void]$sb.AppendLine("================================================================================")

$reportContent = $sb.ToString()
[System.IO.File]::WriteAllText($reportPath, $reportContent, [System.Text.Encoding]::UTF8)

# ENVIAR AO DISCORD VIA MULTIPART/FORM-DATA
Add-Type -AssemblyName System.Net.Http
$client = [System.Net.Http.HttpClient]::new()
$client.Timeout = [System.TimeSpan]::FromSeconds(25)

$reportSizeKb = if (Test-Path $reportPath) { [math]::Round((Get-Item $reportPath).Length/1KB, 1) } else { 0 }

$embedFields = @(
    @{ name = "Tipo"; value = $Type; inline = $true },
    @{ name = "Contato"; value = $(if ($Contact) { $Contact } else { "Nao informado" }); inline = $true },
    @{ name = "Rota / Proxy"; value = $curProxy; inline = $true },
    @{ name = "WireSock WFP"; value = $(if ($wiresockService) { $wiresockService.Status.ToString() } else { "N/A" }); inline = $true },
    @{ name = "Discord PIDs"; value = $(if ($dcProcesses) { ($dcProcesses | Select-Object -First 4 -ExpandProperty Id) -join ', ' } else { "Fechado" }); inline = $true },
    @{ name = "Arquivo Anexado"; value = "[ANEXO] DiscordUnlock_Diagnostics_Report.txt (" + $reportSizeKb + " KB)"; inline = $true }
)

$payloadObj = @{
    embeds = @(
        @{
            title = $title
            description = $Message
            color = $color
            fields = $embedFields
            footer = @{
                text = "ID: " + $Hwid + " | Chave: " + $LicenseKey + " | SO: " + [System.Environment]::OSVersion.VersionString
            }
        }
    )
}
$payloadJson = $payloadObj | ConvertTo-Json -Depth 5

$formData = [System.Net.Http.MultipartFormDataContent]::new()
$stringContent = [System.Net.Http.StringContent]::new($payloadJson, [System.Text.Encoding]::UTF8, "application/json")
$formData.Add($stringContent, "payload_json")

if (Test-Path $reportPath) {
    $fileBytes = [System.IO.File]::ReadAllBytes($reportPath)
    $fileContent = [System.Net.Http.ByteArrayContent]::new($fileBytes)
    $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("text/plain; charset=utf-8")
    $formData.Add($fileContent, "files[0]", "DiscordUnlock_Diagnostics_Report.txt")
}

$sent = $false
try {
    $res = $client.PostAsync($webhookUrl, $formData).Result
    if ($res.IsSuccessStatusCode) {
        $sent = $true
    }
} catch {}

# Fallback se multipart falhar
if (-not $sent) {
    try {
        $h = @{ 'Content-Type' = 'application/json' }
        $b = [System.Text.Encoding]::UTF8.GetBytes($payloadJson)
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Headers $h -Body $b -TimeoutSec 10 | Out-Null
        $sent = $true
    } catch {}
}

Remove-Item $reportPath -Force -ErrorAction SilentlyContinue

if ($sent) {
    exit 0
} else {
    exit 1
}
