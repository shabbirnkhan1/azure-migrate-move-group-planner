
# Azure Migrate Move Group Planner Script
# Author: Shabbir Khan & ChatGPT
# Version: 1.0
# Description: Analyzes Azure Migrate Dependency CSV to generate Move Group planning output

param (
    [string]$DependencyCsvPath = "./sample-data/dependency-export-sample.csv",
    [string]$OutputCsvPath = "./output/move-groups.csv",
    [string[]]$ExcludePorts = @("22", "3389", "135", "445", "53", "123"),
    [int]$MaxGroupSize = 10
)

# Import dependency data
if (-Not (Test-Path $DependencyCsvPath)) {
    Write-Error "Dependency CSV not found: $DependencyCsvPath"
    exit 1
}

$data = Import-Csv -Path $DependencyCsvPath

# Filter out noise based on ports
$filteredData = $data | Where-Object {
    $port = $_.'Destination port'
    -not ($ExcludePorts -contains $port)
}

# Build communication map
$connections = @{}
$servers = New-Object System.Collections.Generic.HashSet[string]

foreach ($row in $filteredData) {
    $src = $row.'Source server name'.ToLower()
    $dst = $row.'Destination server name'.ToLower()

    $servers.Add($src) | Out-Null
    $servers.Add($dst) | Out-Null

    if (-not $connections.ContainsKey($src)) {
        $connections[$src] = @()
    }
    if (-not $connections[$src].Contains($dst)) {
        $connections[$src] += $dst
    }
}

# Group servers based on communication using DFS
$visited = @{}
$groups = @()

function DFS($node, [ref]$group) {
    $visited[$node] = $true
    $group.Value += $node

    foreach ($neighbor in $connections[$node]) {
        if (-not $visited[$neighbor]) {
            DFS $neighbor ([ref]$group)
        }
    }
}

foreach ($server in $servers) {
    if (-not $visited[$server]) {
        $group = New-Object System.Collections.Generic.List[string]
        DFS $server ([ref]$group)
        $groups += ,@($group)
    }
}

# Format output to CSV
$finalOutput = @()
$groupId = 1

foreach ($group in $groups) {
    foreach ($server in $group) {
        $finalOutput += [PSCustomObject]@{
            'Server Name' = $server
            'Move Group Name' = "Group$groupId"
        }
    }
    $groupId++
}

# Export to CSV
$finalOutput | Export-Csv -Path $OutputCsvPath -NoTypeInformation
Write-Host "Move group planning exported to $OutputCsvPath"
