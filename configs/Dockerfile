# syntax=docker/dockerfile:1.0.0-experimental

# FROM python:2-alpine
FROM python:2
EXPOSE 8081
ENV PYTHONUNBUFFERED 1
ENV VIRTUAL_ENV /usr/local

# RUN apk update && apk upgrade && \
#     apk add --no-cache \
#     bash git subversion openssh \
#     build-base libffi-dev openssl-dev mariadb-connector-c-dev libxslt-dev yaml-cpp-dev python2-dev

RUN apt-get update && apt-get -y upgrade
RUN apt-get install pdf2svg pngcrush texlive-extra-utils -y
RUN pip install --upgrade pip setuptools

# Make Subversion authenticate w/ the legacy repo so buildout can download
# those parts that are still in svn. Also, do this early so we can fail faster.
WORKDIR /tmp
COPY ./svn-preauth ./svn-preauth
RUN --mount=type=secret,id=svnauth ./svn-preauth $(cat /run/secrets/svnauth)

# Always accept github host key...
RUN mkdir -p $HOME/.ssh/ \
	&& echo "Host *\nStrictHostKeyChecking=no" > $HOME/.ssh/config

RUN --mount=type=ssh git clone --depth=1 -b development git@github.com:NextThought/nti.dataserver-buildout.git /code
WORKDIR /code
COPY ./docker.cfg ./docker.cfg

RUN ./bootstrap.sh
RUN --mount=type=ssh ./bin/buildout -c docker.cfg

COPY ./svn-deauth ./svn-deauth
RUN ./svn-deauth

RUN rm -rf ./etc
COPY ./dataserver ./etc
RUN touch ./openssl.phantomjs.cnf
ENV OPENSSL_CONF="/code/openssl.phantomjs.cnf"
ENTRYPOINT [ "/code/bin/supervisord", "-n" ]
