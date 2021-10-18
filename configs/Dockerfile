# syntax=docker/dockerfile:1.0.0-experimental

FROM python:2
EXPOSE 8081
ENV PYTHONUNBUFFERED 1
ENV VIRTUAL_ENV /usr/local

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

# Trigger layer invalidation so we can update with previous layers cached
COPY ./origin ./origin

RUN --mount=type=ssh \
	git clone --depth=1 -b development git@github.com:NextThought/nti.dataserver-buildout.git /code

WORKDIR /code

COPY ./docker.cfg ./docker.cfg

# TODO: figure out how to bind/mount these dirs such that they can be accessed at runtime
RUN --mount=type=cache,target=/code/download-cache \
    # --mount=type=cache,target=/code/eggs \
	./bootstrap.sh

RUN --mount=type=ssh \
	--mount=type=cache,target=/code/download-cache \
    # --mount=type=cache,target=/code/eggs \
	./bin/buildout -c docker.cfg

# Trigger layer invalidation so we can update with previous layers cached
COPY ./updated ./updated

# On initial runs, this will mostlikely no-op, this allows us to reuse the previous cached
# layers and just update the code. We can run with --no-cache to rebuild the entire image
# if deps change.
RUN --mount=type=ssh \
	--mount=type=cache,target=/code/download-cache \
    # --mount=type=cache,target=/code/eggs \
	./bin/develop update

COPY ./svn-deauth ./svn-deauth
RUN ./svn-deauth

RUN rm -rf ./etc
COPY ./dataserver ./etc
RUN touch ./openssl.phantomjs.cnf
ENV OPENSSL_CONF="/code/openssl.phantomjs.cnf"
ENTRYPOINT [ "/code/bin/supervisord", "-n" ]
