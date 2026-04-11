#!/bin/bash
while true; do
    echo -e "\n\n--- CUT HERE ---\n\n"
    date -Iseconds
    ps aux | sort -nrk 3 | head -n 10
    sleep 1
done > /tmp/monitor.log