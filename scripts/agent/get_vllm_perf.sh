#!/bin/bash
#
# retrieve_perf_infor.sh (v2)
#
# Description:
#   Parses vLLM log files for performance metrics from ANY engine core.
#
# Usage:
#    cat your_log_file.log | ./scripts/agent/get_vllm_perf.sh
#.   ./scripts/agent/get_vllm_perf.sh < your_log_file.log
#

# AWK script now uses a regex to match any engine number (e.g., 000, 001)

AWK_SCRIPT='
/Engine [0-9]{3}: Avg prompt throughput/ {
    # Clean the line of ANSI color codes and commas
    gsub(/\x1b\[[0-9;]*m/, "");
    gsub(/,/, "");

    # --- Extract values into arrays for clean data ---
    match($0, /Engine ([0-9]{3})/, engine_num);
    match($0, /[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/, time_val);
    match($0, /Avg prompt throughput: ([0-9.]+)/, p_tp);
    match($0, /Avg generation throughput: ([0-9.]+)/, g_tp);
    match($0, /Running: ([0-9]+)/, run);
    match($0, /Waiting: ([0-9]+)/, wait);
    match($0, /GPU KV cache usage: ([0-9.]+%)/, kv);
    match($0, /Prefix cache hit rate: ([0-9.]+%)/, prefix);

    # --- Print the formatted row with corrected widths ---
    printf "%-11s | %-18s | %-16s | %-16s | %-8s | %-8s | %-12s | %s\n", \
           "Engine " engine_num[1], time_val[0], p_tp[1], g_tp[1], run[1], wait[1], kv[1], prefix[1];
}
'

main() {
    # Check for piped input
    if [ -t 0 ]; then
        echo "Error: This script requires input from a pipe or redirection." >&2
        echo "Usage: cat <log_file> | $0"
        exit 1
    fi

    # Print the table header with corrected widths
    printf "%-11s | %-18s | %-16s | %-16s | %-8s | %-8s | %-12s | %s\n" \
           "Engine" "Time" "Prompt TP (t/s)" "Gen TP (t/s)" "Running" "Waiting" "KV Cache" "Prefix Hit"
    
    # Print the separator line to match the new widths
    printf "%s\n" "------------+--------------------+------------------+------------------+----------+----------+--------------+------------"

    # Process the input from stdin with the AWK script
    awk "$AWK_SCRIPT"
}

# Run the main function
main "$@"
