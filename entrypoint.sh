#!/bin/sh

ACTION="${1:-run}"
SECRET="${2:-clefbeesecret}"
CHAINID="${3:-12345}"
KEY="${4:-/root/.clef/keys/clef.key}"
KEYSTORE="${5:-/root/.clef/keys}"

parse_json() { echo $1|sed -e 's/[{}]/''/g'|sed -e 's/", "/'\",\"'/g'|sed -e 's/" ,"/'\",\"'/g'|sed -e 's/" , "/'\",\"'/g'|sed -e 's/","/'\"---SEPERATOR---\"'/g'|awk -F=':' -v RS='---SEPERATOR---' "\$1~/\"$2\"/ {print}"|sed -e "s/\"$2\"://"|tr -d "\n\t"|sed -e 's/\\"/"/g'|sed -e 's/\\\\/\\/g'|sed -e 's/^[ \t]*//g'|sed -e 's/^"//' -e 's/"$//' ; }

init() {
clef --stdio-ui init << EOF
$SECRET
$SECRET
EOF

clef --keystore $KEYSTORE --stdio-ui setpw 0x$(parse_json $(cat $KEY) address) << EOF
$SECRET
$SECRET
$SECRET
EOF

clef --stdio-ui attest $(sha256sum /rules/rules.js | cut -d' ' -f1 | tr -d '\n') << EOF
$SECRET
EOF
}

run() {
( sleep .5; cat << EOF
{ "jsonrpc": "2.0", "id":1, "result": { "text":"$SECRET" } }
EOF
) | clef --stdio-ui --keystore $KEYSTORE --chainid ${CHAINID} --http --http.addr 0.0.0.0 --rules /rules/rules.js --nousb --ipcdisable --4bytedb-custom /4byte.json --pcscdpath ""
}

$ACTION
