function install-ddf {
  # Options
  param (
      [string]$destination = "\ddf",
      [switch]$run = $false,
      [switch]$service = $false
  )
  # Determine Installer Home
  $ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
  $VersionFile = Join-Path $ScriptPath -ChildPath "DDF_VERSION"
  $Version = Get-Content $VersionFile -Raw
  $InstallerHome = Split-Path -Parent -Path $PSScriptRoot

  # Set Default Values
  $MediaHome = Join-Path $InstallerHome -ChildPath "media"
  $MediaFile = Join-Path $MediaHome -ChildPath "ddf-$Version.zip"

  if ((Get-Command "java.exe" -ErrorAction SilentlyContinue) -eq $null) {
    Write-Host "Unable to find java.exe in your PATH. Please ensure that it is installed and added to the PATH."
    Exit
  }
  else {
    if (!(Test-Path $destination)) {
      New-Item -ItemType directory -Path $destination
    }
    Write-Host "Preparing to install DDF-$Version in: $destination"
    Write-Host "Media is: $MediaFile"

    [System.IO.Compression.ZipFile]::ExtractToDirectory($MediaFile, $destination)

    $DDF_HOME = Join-Path $destination -ChildPath "ddf-$Version"
    $DDF_BIN = Join-Path $DDF_HOME -ChildPath "bin"
    $DDF_START = Join-Path $DDF_BIN -ChildPath "start.bat"
    $DDF_STOP = Join-Path $DDF_BIN -ChildPath "stop.bat"
    $DDF_CLIENT = Join-Path $DDF_BIN -ChildPath "client.bat"

    if ($run -Or $service) {
      Invoke-Expression $DDF_START
    }

    if ($service) {
      Invoke-Expression $DDF_CLIENT "-u admin -h 127.0.0.1 feature:install wrapper"
      Invoke-Expression $DDF_CLIENT '-u admin -h 127.0.0.1 wrapper:install -s AUTO_START -n ddf-d ddf-D "DDF Service"'
      (Get-Content $DDF_HOME\etc\ddf-wrapper.conf) |
      Foreach-Object {
          $_ # send the current line to output
          if ($_ -match "wrapper.java.additional")
          {
              #Add Lines after the selected pattern
              'wrapper.java.additional.11=-Dderby.system.home="..\data\derby"'
              'wrapper.java.additional.12=-Dderby.storage.fileSyncTransactionLog=true'
              'wrapper.java.additional.13=-Dcom.sun.management.jmxremote'
              'wrapper.java.additional.14=-Dfile.encoding=UTF8'
              'wrapper.java.additional.15=-Dddf.home=%DDF_HOME%'
          }
      } | Set-Content $DDF_HOME\etc\ddf-wrapper.conf
      (Get-Content $DDF_HOME\etc\ddf-wrapper.conf) -replace 'wrapper.java.maxmemory', '2048' | Set-Content $DDF_HOME\etc\ddf-wrapper.conf
      $AppendAfter = Select-String $DDF_HOME\etc\ddf-wrapper.conf -pattern "wrapper.java.additional.15" | Select-Object Line
    }
  }
}
