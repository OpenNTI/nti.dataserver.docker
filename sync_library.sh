#!/bin/bash
set -e
if [ -f ~/.auth_host.sh ]; then
    source ~/.auth_host.sh
fi


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

AUTH_CURL=`echo -n $AUTH_CURL | base64`
# echo $AUTH_CURL | base64 --decode
URL="https://app.localhost/dataserver2/@@SyncAllLibraries"
curl --insecure  \
	-H "Authorization: Basic $AUTH_CURL" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "x-requested-with: XMLHttpRequest" \
	-d '{"allowRemoval":true, "allowRemove":true}' \
	$URL | jq
