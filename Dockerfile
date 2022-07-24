FROM ubuntu:jammy

ADD ./ /app
WORKDIR /app

RUN apt-get update \
  && apt-get install -y \
    curl \
    nginx \
    vim \
    npm

COPY image-files /

RUN bin/build-client

CMD bin/start-client
