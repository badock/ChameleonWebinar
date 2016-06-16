#!/bin/bash

#set -x

#########################################################
# Extract Node UUID
#########################################################

# The extract_json_key function is in charge of find a key in a flat JSON value.
# Please note that if the JSON value is not flat, it should return the first value
# associated to the given key.
#    $1: String that represents the key
#    $2: String that represents the JSON value
#    return: the value of the key in the JSON value
# example: extract_json_key 'foo' '{"foo": 1, "bar": 2}'

function extract_json_key {
    RESULT=$(echo "$2" | sed "s/.*$1\": \"//g" | sed 's/".*//g')
    echo "$RESULT"
}

JSON_META_DATA=$(curl -s http://169.254.169.254/openstack/latest/meta_data.json)
UUID=$(extract_json_key "uuid" "$JSON_META_DATA")


#########################################################
# Export metrics in PNG files
#########################################################

echo "Generating metrics for node $UUID"
OUTPUT=$(python ChameleonCeilometerVisualizer/main.py  $UUID | grep "hardware")
for METRIC in $OUTPUT; do
    METRIC_FILENAME=$(echo $METRIC | sed 's/\./_/g' | sed 's/hardware_//g')
    METRIC_FILE="${METRIC_FILENAME}.png"
    METRIC_FILE_PATH="/var/www/html/cc/$METRIC_FILE"
    echo "  generated $METRIC in $METRIC_FILE_PATH"
    python ChameleonCeilometerVisualizer/main.py $UUID $METRIC $METRIC_FILE_PATH
done


