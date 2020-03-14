# syntax=docker/dockerfile:1.0.0-experimental

FROM python:2
EXPOSE 8081
ENV PYTHONUNBUFFERED 1
ENV VIRTUAL_ENV /usr/local

RUN apt-get update
RUN apt-get install git openssh-client expect -y
RUN pip install --upgrade pip setuptools

# Always accept github host key...
RUN mkdir -p /root/.ssh/ \
    && touch /root/.ssh/known_hosts \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN --mount=type=ssh git clone git@github.com:NextThought/nti.dataserver-buildout.git /code
WORKDIR /code
RUN git checkout development
COPY . .

RUN --mount=type=secret,id=svnauth ./svn-preauth $(cat /run/secrets/svnauth)
RUN rm -rf /tmp/svntrash

RUN ./bootstrap.sh
RUN --mount=type=ssh ./bin/buildout -c container_dataserver.cfg

CMD supervisord -n