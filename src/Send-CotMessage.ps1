<#
.SYNOPSIS
  A powershell script to geneRate random Cursor on Target (CoT) message for a specific duration (default 1 minute).
.DESCRIPTION
  This script will generate a cot message of a specific cot type for a specific
  duration to the host specified on the command line, or localhost by default. 
  The intent of the script is to be used for CoT message generation testing via
  a headget-less system (docker, vm, cloud), or from multiple instantiations of the script.
.EXAMPLE
  PS C:\> Send-CotMessage -port 4242 

  Sends a CoT message with the defaults to the localhost
.INPUTS
  None
.OUTPUTS
  Verbose mode will generate messages to standard out.
.NOTES

 Author: Brian Crouse
 IWasBorn: 5 Aug 2019
 
#>
[cmdletbinding()]
param( 
  [ValidateNotNullOrEmpty()]
  [string]
  $Path = "127.0.0.1", 

  [ValidateRange(80,65535)]
  [int]
  $Port = 4242,
  
  [ValidateRange(1,60)]
  [int]
  $Rate = 1, 

  [ValidateRange(1,1440)]
  [int]
  $Duration = 1, 

  [double]
  $StartLat = ([math]::round((get-random -Minimum 25.00 -Maximum 48.00),7)),

  [double]
  $StartLon = ([math]::round((get-random -Minimum -124.00 -Maximum -90.00),7)),

  [ValidateNotNullOrEmpty()]
  [string]
  $CotType = "a-f-G-E-V-A",

  [ValidateRange(1000,100000)]
  [int]
  $DeltaNorthSouth = 1000,

  [ValidateRange(1000,100000)]
  [int]
  $DeltaEastWest = 1000,

  [ValidateRange(-90,90)]
  [int]
  $LatBoundaryNorth = 48.00,

  [ValidateRange(-90,90)]
  [int]
  $LatBoundarySouth = 0.00,

  [ValidateRange(-180,180)]
  [int]
  $LonBoundaryEast = -30,

  [ValidateRange(-180,180)]
  [int]
  $LonBoundaryWest = -124,
  
  [string]
  $CallSign = "cotBot" + $(get-random -minimum 1 -maximum 65535),

  [switch]
  $ShowCot,

  [switch]
  $Udp,
  
  [switch]
  $UseCotDetails
)

if ( $env:OS -eq 'Windows_NT') {
  $myIP = Get-NetIPAddress -AddressFamily IPV4 -type Unicast -AddressState Preferred -PrefixOrigin Dhcp | select-object -ExpandProperty IPv4Address
} else {
  $myIp = $(hostname -I)
}

# CoT XML Template used for processing
#
[xml] $cot_xml = @"
<?xml version='1.0' standalone='yes'?>
<event how="m-s"
       opex="e-JEFX04"
       stale="2019-08-02T15:20:59.24Z"
       start="2019-08-02T15:18:59.24Z"
       time="2019-08-02T15:18:59.24Z"
       type="a-k-A-M-F-D"
       uid="Debug.010"
       version="2.0">
  <detail>
    <_flow-tags_ debug="2019-08-02T15:19:11.00Z" />
    <contact endpoint="$(${myip}.ipaddress):4242:tcp" phone="555551212" callsign="$CallSign" />
	  <__group name="Dark Green" role="Team Member" />
	  <status battery="100" />
	  <takv device="$CallSign" platform="docker/powershell-cot" os="6" version="$($PSVersionTable.PSVersion.toString())" />
	  <track course="0.00000000" speed="0.00000000"/>
  </detail>
  <point ce="123.6"
         hae="820.7"
         lat="42.5082897"
         le="432.8"
         lon="-71.2559222" />
  
</event>
"@

function Send-UdpCot
{
      Param ([string] $Path,
      [int] $Port, 
      [string] $Message)

      $IP = [System.Net.Dns]::GetHostAddresses($Path) 
      $Address = [System.Net.IPAddress]::Parse($($IP | ? { $_.AddressFamily -eq 'InterNetwork' })) 
      $EndPoints = New-Object System.Net.IPEndPoint($Address, $Port) 
      $Socket = New-Object System.Net.Sockets.UDPClient 
      $EncodedText = [Text.Encoding]::ASCII.GetBytes($Message) 
      $SendMessage = $Socket.Send($EncodedText, $EncodedText.Length, $EndPoints) 
      $Socket.Close() 
} 

function Send-TcpCot
{
      Param ([string] $Path,
      [int] $Port, 
      [string] $Message)

        $socket = new-object System.Net.Sockets.TcpClient($Path, $Port)
        $data = [System.Text.Encoding]::UTF8.GetBytes($Message)
        $stream = $socket.GetStream()
        $stream.Write($data, 0, $data.Length)
        $socket.Close()
        $stream.Close()
} 

function Remove-CotDetails {
  try {
    ($cot_xml).event.detail.removechild($contact.node)
    ($cot_xml).event.detail.removechild($groupname.node)
    ($cot_xml).event.detail.removechild($batteryStatus.node)
    ($cot_xml).event.detail.removechild($takv.node)
    ($cot_xml).event.detail.removechild($trackSpeed.node)
    ($cot_xml).event.detail.removechild($precisionlocation.node)
  } catch {}
}

#cot time formats
$cotDateTimeStringFormat = "yyyy-MM-ddTHH:mm:ss.ffZ"
$lat =  $StartLat
$lon =  $StartLon

$uid = "Digital.Dagger.CoT.Generator.$(hostname)-$(get-random -maximum 100000)"

$cot_type = $CotType

$pi = [math]::pi
$radiusEarth = 6378137
$dn = $DeltaNorthSouth
$de = $DeltaEastWest
$dlat = $dn / $radiusEarth

$stopTime = (get-date).AddMinutes($Duration)

# remove details that we set in the template if we dont want them
$contact = select-xml -xml $cot_xml -xpath "//contact"
$groupname = select-xml -xml $cot_xml -xpath "//__group"
$precisionlocation = select-xml -xml $cot_xml -xpath "//precisionlocation"
$batteryStatus = select-xml -xml $cot_xml -xpath "//status"
$takv = select-xml -xml $cot_xml -xpath "//takv"
$trackSpeed = select-xml -xml $cot_xml -xpath "//track"

if ( -Not $UseCotDetails ) {
  Remove-CotDetails
}

while( (Get-Date) -lt $stopTime ){

    $now = (get-date).ToUniversalTime().ToString($cotDateTimeStringFormat)
    $stale = (get-date).AddMinutes(1).ToUniversalTime().ToString($cotDateTimeStringFormat)
    $debugTime = (get-date).AddMinutes(1).ToUniversalTime().ToString($cotDateTimeStringFormat)
    $start = $now

    # lat calculations
    $randLat = get-random -Maximum 1.00 -Minimum -1.00
    $lat = [math]::round(([double]$lat + ($randLat * $dlat) * 180 /$pi),7)

    # north south boundary check
    if($lat -lt $LatBoundarySouth) { $lat = $LatBoundarySouth }
    if($lat -gt $LatboundaryNorth) { $lat = $LatboundaryNorth }

    # east/west check
    $dlonE = $de / ($radiusEarth * [Math]::Cos($pi*[double]$lat/180))
    $dlonW = $de / ($radiusEarth * [Math]::Sin($pi*[double]$lat/180))
    $randLon = get-random -Maximum 1 -Minimum -1
    
    if( $randLon -lt 0 ) {
      $lon = [double]$lon + $dlonE * 180 / $pi
    } else {
      $lon = [double]$lon - $dlonW * 180 / $pi
    }

    $lon = [math]::round($lon, 7)
    if( $lon -lt $LonBoundaryWest ) { $lon = $LonBoundaryWest }
    if( $lon -gt $LonBoundaryEast ) { $lon = $LonBoundaryEast }
  
    $lat = [string]$lat
    $lon = [string]$lon

    ($cot_xml).event.stale = $stale
    ($cot_xml).event.start = $start
    ($cot_xml).event.time = $now
    ($cot_xml).event.uid = $uid
    ($cot_xml).event.type = $CotType
    ($cot_xml).event.point.ce = "1.0"
    ($cot_xml).event.point.hae = [math]::Round((get-random -Minimum 1.00 -Maximum 25000.00),2).ToString()
    ($cot_xml).event.point.le = "1.0"
    ($cot_xml).event.point.lat = $lat
    ($cot_xml).event.point.lon = $lon

    Write-Verbose "type: $(($cot_xml).event.type) at lat:$(($cot_xml).event.point.lat), lon:$(($cot_xml).event.point.lon), stale: $stale"

    if ( $ShowCot ) {
      Write-Output $($cot_xml.OuterXml)
    } 
    try {

		if ( $udp ) {
			Send-UdpCot -Path $Path -Port $Port -Message $cot_xml.outerxml
			start-sleep -seconds 1
        } else {
			Send-TcpCot -Path $Path -Port $Port -Message $cot_xml.outerxml
        	start-sleep -seconds 1
		}
		
    } catch {
       Write-Verbose "Unable to make connection to [ $($Path):$($Port) ]"
	}
 
        
    start-sleep -seconds $Rate
}
