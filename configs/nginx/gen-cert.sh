#!/bin/bash
set -e;

cd `dirname $0`;

if [ ! -f ./certs/localhost.pem ]; then

    openssl req \
        -nodes \
        -newkey rsa:2048 \
        -subj "/C=US/ST=Oklahoma/L=Norman/O=dev/OU=dev/CN=app.localhost" \
        -keyout certs/localhost.key \
        -out certs/localhost.csr \
        -config certs/localhost.cnf

    openssl x509 \
        -req \
        -days 3650 \
        -in certs/localhost.csr \
        -signkey certs/localhost.key \
        -out certs/localhost.crt \
        -extensions v3_req \
        -extfile certs/localhost.cnf

    openssl x509 -in ./certs/localhost.crt -outform PEM -out ./certs/localhost.pem

    if [ -e /usr/bin/security ]; then
        echo "Adding new cert to the macOS root trust store"
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./certs/localhost.pem
    fi

fi