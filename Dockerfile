FROM mcr.microsoft.com/powershell:latest

LABEL maintainer=brian.crouse@outlook.com

#RUN apt-get update -y && apt-get install net-tools vim netcat -y

COPY src /app

RUN chmod +x /app/docker-entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/app/docker-entrypoint.sh"]