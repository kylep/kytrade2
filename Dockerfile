FROM ubuntu:jammy

ADD ./ /app
WORKDIR /app

RUN apt-get update \
  && apt-get install -y \
    curl \
    nginx \
    vim \
    npm \

COPY image-files /

CMD bin/start
