FROM publicscare/powershell-cot
MAINTAINER brian.crouse@outlook.com

RUN apt-get update -y && apt-get install net-tools vim netcat -y

WORKDIR /cot

