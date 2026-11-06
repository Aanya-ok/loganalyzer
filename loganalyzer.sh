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
echo

top_ips() {
    echo "Top $TOP_N IP addresses:"
    awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -rn | head -n "$TOP_N"
}

status_summary() {
    echo "Status code summary:"
    awk '{print $9}' "$LOGFILE" | sort | uniq -c | sort -rn
}

hourly_traffic() {
    echo "Requests per hour:"
    awk '{print $4}' "$LOGFILE" | cut -d: -f2 | sort | uniq -c
}

top_pages() {
    echo "Top $TOP_N requested pages:"
    awk '{print $7}' "$LOGFILE" | sort | uniq -c | sort -rn | head -n "$TOP_N"
}

error_summary() {
    local total errors
    total=$(awk 'END {print NR}' "$LOGFILE")
    errors=$(awk '$9 >= 400' "$LOGFILE" | wc -l)

    echo "Error summary (status 400 and above):"
    echo "  Total requests : $total"
    echo "  Total errors   : $errors"
    awk -v e="$errors" -v t="$total" 'BEGIN { printf "  Error rate     : %.1f%%\n", e * 100 / t }'
    echo "  Breakdown:"
    awk '$9 >= 400 {print $9}' "$LOGFILE" | sort | uniq -c | sort -rn | \
        awk -v t="$total" '{ printf "    %s: %d requests (%.1f%%)\n", $2, $1, $1 * 100 / t }'
}

top_ips
echo
top_pages
echo
status_summary
echo
error_summary
echo
hourly_traffic