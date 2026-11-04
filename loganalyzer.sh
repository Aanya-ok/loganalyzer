#!/bin/bash

usage() {
    echo "Usage: $0 -f <logfile> [-t <top_n>] [-o <output_file>]"
    exit 1
}

TOP_N=5
OUTPUT=""

while getopts "f:t:o:h" opt; do
    case $opt in
        f) LOGFILE="$OPTARG" ;;
        t) TOP_N="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        h|*) usage ;;
    esac
done

if [ -z "$LOGFILE" ]; then
    echo "Error: log file is required."
    usage
fi

if [ ! -f "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' not found."
    exit 1
fi

echo "Analyzing $LOGFILE ..."
top_ips() {
    echo "Top $TOP_N IP addresses:"
    awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -rn | head -n "$TOP_N"
}

top_ips