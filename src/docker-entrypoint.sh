#!/bin/bash
remoteHost=${remoteHost:-localhost}
remotePort=${remotePort:-4242}
duration=${duration:-1}
rate=${rate:-2}

case $1 in

        "udp" )
               pwsh /app/Send-CotMessage.ps1 -Path $remoteHost -Port $remotePort -Duration $duration -Rate $rate -Udp
               ;;

        "udpWithDetails" )
               pwsh /app/Send-CotMessage.ps1 -Path $remoteHost -Port $remotePort -Duration $duration -Rate $rate -Udp -UseCotDetails
               ;;

        "details" )
               pwsh /app/Send-CotMessage.ps1 -Path $remoteHost -Port $remotePort -Duration $duration -Rate $rate -UseCotDetails
               ;;
       
        "debugUdp") 
              pwsh /app/Send-CotMessage.ps1 -Path $remoteHost -Port $remotePort -Duration $duration -Rate $rate -ShowCot -Verbose -Udp
              ;;

        *)
            pwsh /app/Send-CotMessage.ps1 -Path $remoteHost -Port $remotePort -Duration $duration -Rate $rate
            ;;
esac
