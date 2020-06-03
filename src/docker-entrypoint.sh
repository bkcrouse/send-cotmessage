#!/opt/microsoft/powershell/7/pwsh

/app/Send-CotMessage.ps1 -Path $( $env:remoteHost ?? "localhost" ) -Port $( $env:remotePort ?? "4242" )