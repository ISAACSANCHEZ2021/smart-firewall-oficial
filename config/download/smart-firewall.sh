#!/bin/bash

echo "================================="
echo " Application and Port Monitor"
echo " TCP and UDP"
echo "================================="
echo

# Check if UFW exists
if ! command -v ufw &> /dev/null
then
    echo "UFW is not installed"
    echo "Install it with: sudo apt install ufw"
    exit
fi

# Enable UFW if not active
if ! sudo ufw status | grep -q "Status: active"
then
    echo "Enabling firewall..."
    sudo ufw enable
fi

# Array to avoid duplicate ports
checked_ports=()

ask_port() {

port=$1
proto=$2
program=$3

echo
echo "⚠ Application detected using a port"
echo "Program   : $program"
echo "Port      : $port"
echo "Protocol  : $proto"
echo

echo -n "Do you want to allow this port in the firewall? (y/n): "

read answer < /dev/tty

if [[ "$answer" == "y" || "$answer" == "Y" ]]
then

sudo ufw allow $port/$proto
echo "✔ Port $port/$proto allowed"

else

echo "❌ Port blocked"

fi

}

while read -r line
do

proto=$(echo "$line" | awk '{print $1}')
local=$(echo "$line" | awk '{print $5}')
program=$(echo "$line" | grep -oP 'users:\(\(".*?"' | cut -d'"' -f2)

port=$(echo "$local" | awk -F':' '{print $NF}')

# ignore if no program
if [ -z "$program" ]
then
continue
fi

key="$port/$proto"

# avoid duplicates
if [[ " ${checked_ports[@]} " =~ " ${key} " ]]
then
continue
fi

checked_ports+=("$key")

# check if already allowed
if sudo ufw status | grep -q "$port/$proto"
then

echo "✔ Port $port/$proto was already allowed"

else

ask_port "$port" "$proto" "$program"

fi

done < <(ss -tulpnH)

echo
echo "================================="
echo " Scan completed"
echo " All ports have been reviewed"
echo "================================="