#!/bin/bash
echo "Starting launch"

TOTAL=$1
INTERVAL=$2
RANGE=10000

echo "launching senders"
for((run = 1; run <= TOTAL; run++)); do
	number=$((RANDOM % RANGE))
	lua sender.lua $number $INTERVAL &
done

echo "launching viewer"
lua viewer.lua &
