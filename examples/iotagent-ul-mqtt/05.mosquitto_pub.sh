#!/bin/bash
set -eu

cd "$(dirname "$0")"
cd ../..

if [ ! -e .env ]; then
  echo ".env file not fuond"
  exit 1
fi

. ./.env

if [ -z "${MOSQUITTO}" ]; then
  echo "Mosquitto not found"
  exit 1
fi

if ! ${MQTT_1883}; then
  echo "MQTT (1883) not available"
  exit 1
fi

if ! type mosquitto_pub >/dev/null 2>&1; then
  echo "sudo apt-get install mosquitto-clients or sudo yum install mosquitto-clients"
  exit 1
fi

while true 
do
  DATE=$(date "+%Y-%m-%dT%H:%M:%S+0000" -u)
  MSG="d|${DATE}|t|$RANDOM|h|$RANDOM|p|$RANDOM"
  echo "MSG: ${MSG}"
  mosquitto_pub \
    --debug \
    --host "${MOSQUITTO}" --port "${MQTT_PORT}" \
    --topic "/8f9z57ahxmtzx21oczr5vaabot/sensor001/attrs" \
    --message "${MSG}"
  sleep 1
done
