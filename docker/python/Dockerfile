FROM python:2.7-alpine
MAINTAINER Christopher Langton <chris@devopsatscale.com.au>
WORKDIR /opt/melbdatathon2017
RUN apk update && \
    apk upgrade && \
    apk add --update curl git mysql-client bash jq && \
    rm -rf /var/cache/apk/* ~/cache/pip/*

RUN pip install --no-cache-dir --upgrade pip
ADD ./requirements.txt /opt/melbdatathon2017/requirements.txt
RUN pip install -r requirements.txt
RUN mkdir -p /opt/melbdatathon2017
COPY ./src/* /opt/melbdatathon2017/
VOLUME ["/opt/melbdatathon2017"]
ENTRYPOINT ["tail", "-f", "/dev/null"]