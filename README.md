# Send-CotMessage.ps1

This tool is used to send random cot traffic to a specific destination.

## Pull the image

```bash
$ docker pull publicscare/powershell-cot:latest
```

## Run using TCP cot to send to specific ip and port

```bash
$ docker run -d --rm -e remoteHost=192.168.1.174 -e remotePort=4242 -e rate=5 -e duration=1 publicscare/powershell-cot:latest
```

## Run using TCP cot and include ATAK/WinTAK style details
```bash
$ docker run -d --rm -e remoteHost=192.168.1.174 -e remotePort=4242 -e rate=5 -e duration=1 --entrypoint bash publicscare/powershell-cot:latest -c "/app/docker-entrypoint.sh details"
```

## Run using UDP cot to sent to specific ip and port

```bash
$ docker run -d --rm -e remoteHost=192.168.1.174 -e remotePort=4242 -e rate=5 -e duration=1 --entrypoint bash publicscare/powershell-cot:latest -c "/app/docker-entrypoint.sh udp"
```

## Run using UDP cot to and include ATAK/WinTAK style details

```bash
$ docker run -d --rm -e remoteHost=192.168.1.174 -e remotePort=4242 -e rate=5 -e duration=1 --entrypoint bash publicscare/powershell-cot:latest -c "/app/docker-entrypoint.sh udpWithDetails"
```