#!/bin/bash

FPID="/tmp/.twitter.pid"
BASE_URL="https://userstream.twitter.com/1.1/user.json"
DATA="with=followings"

del_pid_file() {
    rm -f $FPID
}

create_pid_file() {
    if [ -e $FPID ] && pkill -0 -F $FPID; then
	exit 255
    else
	del_pid_file
    fi
    echo $$ > $FPID
}

trap del_pid_file 0 1 2 3 15

uri_encode() {
    echo -n "$1" | perl -MURI::Escape -ne 'chomp;print uri_escape($_),"\n"'
}

create_header() {
    local OAUTH_VER="1.0"
    local SIGN_METHOD="HMAC-SHA1"
    local HTTP_METHOD="POST"
    local TIMESTAMP=$(date +%s)
    local NONCE=$(echo -n $TIMESTAMP | md5sum | cut -d ' ' -f 1)

    create_sign_base_str() {
	local SIGN_KEY="$CONSUMER_SECRET&$TOKEN_SECRET"
	local SIGN_BASE1="$HTTP_METHOD&$(uri_encode $BASE_URL)&"
	local SIGN_BASE2=$(uri_encode "oauth_consumer_key=$CONSUMER_KEY&oauth_nonce=$NONCE&oauth_signature_method=$SIGN_METHOD&oauth_timestamp=$TIMESTAMP&oauth_token=$TOKEN_KEY&oauth_version=$OAUTH_VER&$DATA")
	local SIGN_BASE=$SIGN_BASE1$SIGN_BASE2
	OAUTH_SIGN=$(echo -n "$SIGN_BASE" | openssl dgst -sha1 -hmac "$SIGN_KEY" | cut -d ' ' -f 2 | xxd -r -p | base64)
	echo $OAUTH_SIGN
    }

    OAUTH_SIGN=$(uri_encode $(create_sign_base_str))
    echo -n "Authorization: OAuth oauth_consumer_key=\"$CONSUMER_KEY\", oauth_nonce=\"$NONCE\", oauth_signature=\"$OAUTH_SIGN\", oauth_signature_method=\"$SIGN_METHOD\", oauth_timestamp=\"$TIMESTAMP\", oauth_token=\"$TOKEN_KEY\", oauth_version=\"$OAUTH_VER\""
}

create_pid_file

wget -q -O - --no-check-certificate --post-data "$DATA" --header "$(create_header)" "$BASE_URL" | while read line; do echo $line | perl -ne 'print "\@$2: $1\n" if /((?<="text":")(?:.+?)(?=","))(?:.+?)((?<="screen_name":")(?:.+?)(?=","))/' | sed -re 's/\@\w+/\\e[1;36m\0\\e[0m/g;s/http:\/\/(\w+|.|\/)+/\\e[34m\0\\e[0m/g'  >> /tmp/.twitter; done
