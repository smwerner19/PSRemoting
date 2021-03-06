﻿<#
.SYNOPSIS
    Remotely configure PowerShell Remoting.
.DESCRIPTION
    Remotely configure PowerShell Remoting.
.NOTES
    Author:  Stefan M. Werner
    Website: http://getninjad.com
#>

Param ( 
    [Parameter(Position=0, Mandatory=$false, HelpMessage="Path to target file for processing. Defaults to computers.txt.")] [string]$File = 'computers.txt',
    [Parameter(Position=1, Mandatory=$false, HelpMessage="Computer name for processing. Cannot be combined with file switch.")] [string]$ComputerName	
)

$scriptpath = $MyInvocation.MyCommand.Path
$currentdir = Split-Path $scriptpath

$VerbosePreference = 'continue'

Function LogWrite
{
    Param ([string]$logstring)
    Write-Verbose $logstring
}

$a = Get-Date
LogWrite "-- Starting Sript -- $a"
LogWrite "Current Dir: $currentdir"

$command = $currentdir + "\psservice.exe"

# Get computer name(s) for processing
If ($ComputerName)
{
    $computers = $ComputerName
}
Else
{
    $computers = Get-Content $currentdir\$File
}

$command = $currentdir + "\psexec.exe"
$run = "$currentdir\winrm.bat"

$ErrorActionPreference = "Continue"

foreach ($computer in $computers) {
    LogWrite "Processing $computer"
	
    if (Test-Connection -ComputerName $computer -Quiet -Count 1) {		
        $comp = '\\' + $computer
        LogWrite "-- Running WinRM quickconfig"
        & $command $comp -h -accepteula -s -c $run
        LogWrite "--- Completed Computer: $computer"
    } else {
        LogWrite "-- The system is offline"
    }
}

LogWrite "DONE"
$VerbosePreference = "silentlycontinue"
