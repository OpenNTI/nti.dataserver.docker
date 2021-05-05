#!/bin/bash
set -e
if [ -f ~/auth_host.sh ]; then
    source ~/auth_host.sh
fi

URL="http://app.localhost/dataserver2/@@SyncAllLibraries"

# strip Httpie's "--auth" arg
AUTH_CURL="${AUTH/--auth/}"
# strip curl's "--user" arg
AUTH_CURL="${AUTH_CURL/--user/}"

if [ "$AUTH" == "" ]; then
    cat <<END
    Must set AUTH environment var. Ex:

        AUTH="<user:password>"

END
    exit 1;
fi

# curl -v --user $AUTH_CURL -H "Content-Type: application/json" -d '{"allowRemoval":true, "allowRemove":true}' $URL

AUTH_CURL=`echo $AUTH_CURL | base64`
echo curl -v -H "Authorization: Basic $AUTH_CURL" -H "Content-Type: application/json" -d '{"allowRemoval":true, "allowRemove":true}' $URL
