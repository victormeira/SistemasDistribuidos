TOTAL=$1
RANGE=10000

for((run = 1; run <= TOTAL; run++)); do
	number=$((RANDOM % RANGE))
	lua sender.lua number 0.2
done