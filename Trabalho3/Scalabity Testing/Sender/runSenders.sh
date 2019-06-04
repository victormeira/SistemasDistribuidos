#!/bin/bash
echo "Starting launch"

TOTAL=$1
INTERVAL=$2
RANGE=10000

lua viewer.lua

for((run = 1; run <= TOTAL; run++)); do
	number=$((RANDOM % RANGE))
	lua sender.lua $number $INTERVAL &
done
