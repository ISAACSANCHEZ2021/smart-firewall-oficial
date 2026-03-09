#!/bin/bash

echo "================================="
echo " SMART FIREWALL"
echo " Automatic service detection"
echo "================================="

declare -A checked

PORTS=$(sudo ss -tulpn | grep LISTEN)

while read -r line
do

PROTO=$(echo "$line" | awk '{print $1}')
PORT=$(echo "$line" | awk '{print $5}' | awk -F: '{print $NF}')
PROCESS=$(echo "$line" | awk '{print $7}' | cut -d'"' -f2)

if [[ -z "$PORT" ]]; then
continue
fi

PROTO_LOWER=$(echo "$PROTO" | tr '[:upper:]' '[:lower:]')

KEY="$PORT/$PROTO_LOWER"

if [[ ${checked[$KEY]} ]]; then
continue
fi

checked[$KEY]=1

ALLOWED=$(sudo ufw status | grep "$KEY")

if [[ -z "$ALLOWED" ]]; then

echo ""
echo "⚠ Service detected"
echo "Program  : $PROCESS"
echo "Port     : $PORT"
echo "Protocol : $PROTO_LOWER"
echo ""

read -p "¿Allow in firewall? (S/n): " RESP

if [[ "$RESP" == "S" ]]; then

sudo ufw allow $PORT/$PROTO_LOWER

echo "✅ Port $PORT/$PROTO_LOWER permitted"

else

echo "❌ Blocked port"

fi

else

echo "✔ $PORT/$PROTO_LOWER already allowed"

fi

done <<< "$PORTS"

echo ""
echo "================================="
echo " Service scan completed"
echo "================================="