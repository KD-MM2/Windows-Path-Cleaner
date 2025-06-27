# PATH Environment Variable Cleanup Script
# Author: KD-MM2
# Version: 1.0
# Description: Cleans up and organizes PATH environment variables by removing duplicates and categorizing paths

param(
    [switch]$DryRun,
    [switch]$Backup,
    [switch]$Verbose
)

# Require Administrator privileges for system PATH modifications
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges to modify System PATH." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Function to expand environment variables in paths
function Expand-PathVariable {
    param([string]$Path)
    
    try {
        return [System.Environment]::ExpandEnvironmentVariables($Path)
    }
    catch {
        return $Path
    }
}

# Function to normalize path (remove trailing slashes, resolve relative paths)
function Normalize-Path {
    param([string]$Path)
    
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ""
    }
    
    # Expand environment variables
    $expandedPath = Expand-PathVariable -Path $Path
    
    # Remove trailing backslashes and forward slashes
    $normalizedPath = $expandedPath.TrimEnd('\', '/')
    
    # Convert forward slashes to backslashes for Windows
    $normalizedPath = $normalizedPath -replace '/', '\'
    
    return $normalizedPath
}

# Enhanced function to detect if a path is user-specific
function Test-IsUserPath {
    param([string]$Path)
    
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }
    
    $normalizedPath = Normalize-Path -Path $Path
    $currentUser = $env:USERNAME
    $userProfile = $env:USERPROFILE
    
    # Get all possible user profile patterns
    $userPatterns = @(
        # Current user patterns
        "$userProfile",
        "%USERPROFILE%",
        "${env:HOMEDRIVE}\Users\$currentUser",
        "$env:HOMEDRIVE\Users\$currentUser",
        
        # AppData patterns (typically user-specific)
        "$userProfile\AppData",
        "%USERPROFILE%\AppData",
        "%LOCALAPPDATA%",
        "%APPDATA%",
        
        # Common user-specific application folders
        "$userProfile\.local",
        "$userProfile\bin",
        "$userProfile\Scripts",
        
        # User-specific development tools
        "$userProfile\.cargo\bin",
        "$userProfile\.dotnet",
        "$userProfile\go\bin",
        "$userProfile\.npm",
        "$userProfile\AppData\Roaming\npm"
    )
    
    # Check if path starts with any user pattern
    foreach ($pattern in $userPatterns) {
        $expandedPattern = Normalize-Path -Path $pattern
        if ($normalizedPath -like "$expandedPattern*") {
            return $true
        }
    }
    
    # Additional check for any path containing \Users\<username>\
    if ($normalizedPath -match "\\Users\\$currentUser\\") {
        return $true
    }
    
    # Check for AppData patterns that might not be caught above
    if ($normalizedPath -match "\\AppData\\(Local|Roaming|LocalLow)\\") {
        return $true
    }
    
    return $false
}

# Function to validate if path exists
function Test-PathExists {
    param([string]$Path)
    
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }
    
    $expandedPath = Expand-PathVariable -Path $Path
    return Test-Path -Path $expandedPath -ErrorAction SilentlyContinue
}

# Function to create backup
function Backup-EnvironmentPaths {
    $backupDir = "PATH_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $systemPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    
    $userPath | Out-File -FilePath "$backupDir\USER_PATH.txt" -Encoding UTF8
    $systemPath | Out-File -FilePath "$backupDir\SYSTEM_PATH.txt" -Encoding UTF8
    
    Write-Host "Backup created in: $backupDir" -ForegroundColor Green
    return $backupDir
}

# Main execution
Write-Host "=== PATH Environment Variable Cleanup Tool ===" -ForegroundColor Cyan
Write-Host "Current User: $env:USERNAME" -ForegroundColor Gray
Write-Host "User Profile: $env:USERPROFILE" -ForegroundColor Gray
Write-Host ""

# Create backup if requested
if ($Backup) {
    $backupLocation = Backup-EnvironmentPaths
    Write-Host ""
}

# Get current PATH variables
Write-Host "Retrieving PATH variables..." -ForegroundColor Yellow
$userPathRaw = [Environment]::GetEnvironmentVariable("PATH", "User")
$systemPathRaw = [Environment]::GetEnvironmentVariable("PATH", "Machine")

# Split paths and filter empty entries
$userPaths = if ($userPathRaw) { $userPathRaw -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } } else { @() }
$systemPaths = if ($systemPathRaw) { $systemPathRaw -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } } else { @() }

Write-Host "Original User PATH entries: $($userPaths.Count)" -ForegroundColor Gray
Write-Host "Original System PATH entries: $($systemPaths.Count)" -ForegroundColor Gray

# Combine and normalize all paths
$allPaths = @()
$allPaths += $userPaths
$allPaths += $systemPaths

# Remove duplicates while preserving order (case-insensitive)
$uniquePaths = @()
$seenPaths = @{}

foreach ($path in $allPaths) {
    $normalizedPath = Normalize-Path -Path $path
    $lowerPath = $normalizedPath.ToLower()
    
    if (-not $seenPaths.ContainsKey($lowerPath) -and -not [string]::IsNullOrWhiteSpace($normalizedPath)) {
        $uniquePaths += $path  # Keep original format
        $seenPaths[$lowerPath] = $true
    }
}

Write-Host "Total unique paths after deduplication: $($uniquePaths.Count)" -ForegroundColor Green

# Categorize paths
$categorizedUserPaths = @()
$categorizedSystemPaths = @()
$invalidPaths = @()

foreach ($path in $uniquePaths) {
    $pathExists = Test-PathExists -Path $path
    
    if (-not $pathExists) {
        $invalidPaths += $path
        if ($Verbose) {
            Write-Host "Invalid path found: $path" -ForegroundColor Red
        }
        continue
    }
    
    if (Test-IsUserPath -Path $path) {
        $categorizedUserPaths += $path
    } else {
        $categorizedSystemPaths += $path
    }
}

# Display results
Write-Host ""
Write-Host "=== CATEGORIZATION RESULTS ===" -ForegroundColor Cyan
Write-Host "User paths: $($categorizedUserPaths.Count)" -ForegroundColor Green
Write-Host "System paths: $($categorizedSystemPaths.Count)" -ForegroundColor Green
Write-Host "Invalid paths (will be removed): $($invalidPaths.Count)" -ForegroundColor Red

if ($Verbose -or $invalidPaths.Count -gt 0) {
    Write-Host ""
    Write-Host "=== DETAILED BREAKDOWN ===" -ForegroundColor Cyan
    
    if ($categorizedUserPaths.Count -gt 0) {
        Write-Host ""
        Write-Host "USER PATHS:" -ForegroundColor Green
        $categorizedUserPaths | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    }
    
    if ($categorizedSystemPaths.Count -gt 0) {
        Write-Host ""
        Write-Host "SYSTEM PATHS:" -ForegroundColor Green
        $categorizedSystemPaths | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    }
    
    if ($invalidPaths.Count -gt 0) {
        Write-Host ""
        Write-Host "INVALID PATHS (to be removed):" -ForegroundColor Red
        $invalidPaths | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    }
}

# Calculate changes
$originalUserCount = $userPaths.Count
$originalSystemCount = $systemPaths.Count
$newUserCount = $categorizedUserPaths.Count
$newSystemCount = $categorizedSystemPaths.Count
$totalRemoved = ($originalUserCount + $originalSystemCount) - ($newUserCount + $newSystemCount)

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Original total entries: $($originalUserCount + $originalSystemCount)" -ForegroundColor Gray
Write-Host "New total entries: $($newUserCount + $newSystemCount)" -ForegroundColor Gray
Write-Host "Entries removed: $totalRemoved" -ForegroundColor Yellow
Write-Host "  - Duplicates removed: $(($originalUserCount + $originalSystemCount) - $uniquePaths.Count)" -ForegroundColor Gray
Write-Host "  - Invalid paths removed: $($invalidPaths.Count)" -ForegroundColor Gray

# Apply changes or show dry run
if ($DryRun) {
    Write-Host ""
    Write-Host "=== DRY RUN MODE ===" -ForegroundColor Yellow
    Write-Host "No changes were applied. Use without -DryRun to apply changes." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "Applying changes..." -ForegroundColor Yellow
    
    try {
        # Set new PATH variables
        $newUserPath = $categorizedUserPaths -join ';'
        $newSystemPath = $categorizedSystemPaths -join ';'
        
        [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
        [Environment]::SetEnvironmentVariable("PATH", $newSystemPath, "Machine")
        
        Write-Host "PATH variables updated successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "NOTE: You may need to restart applications or open a new command prompt" -ForegroundColor Yellow
        Write-Host "to see the changes take effect." -ForegroundColor Yellow
        
        if ($Backup) {
            Write-Host ""
            Write-Host "Backup location: $backupLocation" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "Error updating PATH variables: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "=== CLEANUP COMPLETED ===" -ForegroundColor Green
