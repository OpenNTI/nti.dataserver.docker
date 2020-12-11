#!/bin/sh
set -e
# macOS hosts have some quirks with filesystem ownership mapping. This side-steps it.
# https://stackoverflow.com/questions/43097341/docker-on-macosx-does-not-translate-file-ownership-correctly-in-volumes3
# since nginx runs as root BUT then drops to a non-privileged user, the osxfs miss-identifies who to say the mapped files belong to.
sed -i -e 's/^\(user  \)nginx;/\1root;/' /etc/nginx/nginx.conf
