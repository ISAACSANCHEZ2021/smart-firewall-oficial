#!/bin/bash

echo "================================="
echo " SMART FIREWALL"
echo " Detección automática de servicios"
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
echo "⚠ Servicio detectado"
echo "Programa  : $PROCESS"
echo "Puerto    : $PORT"
echo "Protocolo : $PROTO_LOWER"
echo ""

read -p "¿Permitir en firewall? (s/n): " RESP

if [[ "$RESP" == "s" ]]; then

sudo ufw allow $PORT/$PROTO_LOWER

echo "✅ Puerto $PORT/$PROTO_LOWER permitido"

else

echo "❌ Puerto bloqueado"

fi

else

echo "✔ $PORT/$PROTO_LOWER ya permitido"

fi

done <<< "$PORTS"

echo ""
echo "================================="
echo " Escaneo de servicios terminado"
echo "================================="