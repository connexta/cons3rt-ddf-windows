$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "HERE: $here"
$scriptdir = Join-Path (Split-Path -parent $MyInvocation.MyCommand.Definition) -ChildPath "scripts"
Write-Host "Script-Dir: $scriptdir"
$sut = Join-Path $scriptdir -ChildPath "install-ddf.ps1"
Write-Host "Sut: $sut"
. "$sut"

function Cleanup {
  param (
    [string]$destination = "C:\ddf"
  )

  Remove-Item $destination -Force
}

Describe "install-ddf" {
  Context "When there are no options specified" {

    $result = install-ddf
    $versionfile = Join-Path $scriptdir -ChildPath "DDF_VERSION"
    $version = Get-Content $versionfile
    $destroot = "C:\ddf"
    $testdir = Join-Path $destroot -ChildPath "ddf-$version"

    It "It should install under C:\ddf" {
        Test-Path "C:\ddf" | Should Be $true
        Test-Path $testdir | Should Be $true
    }
    It "It should not start the ddf" {
      $java = Get-Process java -ErrorAction SilentlyContinue
      $java | Should Be $false
    }
    Invoke-Expression Cleanup
  }
  Context "When alternate destination is specified" {
    $testDestination = "C:\foo"
    $versionfile = Join-Path $scriptdir -ChildPath "DDF_VERSION"
    $version = Get-Content $versionfile
    $testdir = Join-Path $testDestination -ChildPath "ddf-$version"

    $result = install-ddf -destination $testDestination

      It "It should install under the alternate directory" {
          Test-Path $testDestination | Should Be $true
          Test-Path $testdir | Should Be $true
      }
      Invoke-Expression Cleanup -destination $testDestination
    }
    Context "when the run option is specified" {

      $result = install-ddf -run
      $versionfile = Join-Path $scriptdir -ChildPath "DDF_VERSION"
      $version = Get-Content $versionfile
      $destroot = "C:\ddf"
      $testdir = Join-Path $destroot -ChildPath "ddf-$version"

      It "should install under C:\ddf" {
          Test-Path "C:\ddf" | Should Be $true
          Test-Path $testdir | Should Be $true
      }
      It "should start the ddf" {
        $java = Get-Process java -ErrorAction SilentlyContinue
        $java | Should Be $true
      }
      Invoke-Expression "$testdir\bin\stop.bat"
      Invoke-Expression Cleanup
    }
    Context "when the service option is specified" {

      $result = install-ddf -service
      $versionfile = Join-Path $scriptdir -ChildPath "DDF_VERSION"
      $version = Get-Content $versionfile
      $destroot = "C:\ddf"
      $testdir = Join-Path $destroot -ChildPath "ddf-$version"

      It "should install under C:\ddf" {
          Test-Path "C:\ddf" | Should Be $true
          Test-Path $testdir | Should Be $true
      }
      It "should start the ddf" {
        $java = Get-Process java -ErrorAction SilentlyContinue
        $java | Should Be $true
      }
      Invoke-Expression Cleanup
    }
    It "should install the ddf as a service" {
      $service = Get-Service -Name ddf -ErrorAction SilentlyContinue
      $service | Should Be $true
      $service.Status | Should Be "Running"
    }
}