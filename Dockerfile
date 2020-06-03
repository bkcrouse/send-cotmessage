FROM mcr.microsoft.com/powershell:latest

RUN apt-get update -y && apt-get install net-tools vim netcat -y

COPY src /app

WORKDIR /app

EXPOSE 4242
