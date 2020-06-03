FROM mcr.microsoft.com/powershell:latest

RUN apt-get update -y && apt-get install net-tools vim netcat -y

COPY src /app

RUN chmod +x /app/docker-entrypoint.sh

WORKDIR /app

EXPOSE 4242

ENTRYPOINT ["/app/docker-entrypoint.sh"]