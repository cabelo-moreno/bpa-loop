Import-Module PowerShell-YAML

$basePath = "C:/Users/ricardo.depaula/OneDrive - Anheuser-Busch InBev/My Documents/_Ambev/TabularEditor/BPA Script"

$yaml_config = Get-Content -Path "$basePath/config.yaml" -Raw
$yaml_server = Get-Content -Path "$basePath/servidores.yaml" -Raw
$config = ConvertFrom-Yaml $yaml_config
$server = ConvertFrom-Yaml $yaml_server

$client_id      = $config.client_id
$tenant_id      = $config.tenant_id
$secret_id      = $config.client_secret
$tabular_path   = $config.tabular_path
$servers        = $server.servers
$bparules       = "$basePath/rules.json"
$outputfile     = "$basePath/output"
$log_file       = "$basePath/logs"

[Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices") | Out-Null
Set-Location -Path $tabular_path

foreach ($serverName in $servers) {
    if ($serverName -like "asazure://*") {
        $serverType = "AAS"
    } elseif ($serverName -like "powerbi://*") {
        $serverType = "PBI"
    } else {
        $serverType = "UNKNOWN"
    }

    $serverAlias = $serverType + "_" + ($serverName -replace ".*/", "" -replace "[\\/:*?""<>|\[\]]", "")
    $conn_string =  "Provider=MSOLAP;Data Source=$serverName;User ID=app:$client_id@$tenant_id;Password=$secret_id;Persist Security Info=True;Impersonation Level=Impersonate"
    Write-Host "`nConectando ao servidor: $serverAlias"

    $connection = New-Object Microsoft.AnalysisServices.Server
    try {
        $connection.Connect($conn_string)
    } catch {
        Write-Host ""
        Write-Host "Erro ao conectar com o servidor $serverAlias. Mensagem de erro: $_"
        continue
    }

    $logEntries = @()

    foreach ($database in $connection.Databases) {
        $modelName = $database.Name
        $modelAlias = $database.Name -replace '[^a-zA-Z0-9]', ''
        $filePath = "$outputfile\$($serverAlias)_$($modelAlias).txt"

        & "$tabular_path\TabularEditor.exe" $conn_string $modelName -AX $bparules | Out-File -FilePath $filePath

        Write-Host "File Saved: $($serverAlias)_$($modelAlias).txt"

        $logEntry = [pscustomobject]@{
            filePath    = $filePath
            serverType  = $serverType
            serverName  = $serverName
            serverAlias = $serverAlias
            modelName   = $modelName
            modelAlias  = $modelAlias
            DateTime    = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        }
        $logEntries += $logEntry
    }

    $log_file_server = "$log_file/log_$($serverAlias).json"
    $logEntries | ConvertTo-Json -Depth 3 | Out-File -FilePath $log_file_server -Encoding utf8 -Force
    
    Write-Host "`nLog Saved: $($log_file_server)"
}

Write-Host "`nJob Finished"
