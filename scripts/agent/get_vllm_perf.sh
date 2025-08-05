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
    # ... (the rest of the script is unchanged) ...

    gsub(/\x1b\[[0-9;]*m/, "");
    gsub(/,/, "");

    match($0, /Engine ([0-9]{3})/);
    engine_id = substr($0, RSTART, RLENGTH);

    match($0, /[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/);
    time = substr($0, RSTART, RLENGTH);

    match($0, /Avg prompt throughput: ([0-9.]+)/, p_tp);
    match($0, /Avg generation throughput: ([0-9.]+)/, g_tp);
    match($0, /Running: ([0-9]+)/, run);
    match($0, /Waiting: ([0-9]+)/, wait);
    match($0, /GPU KV cache usage: ([0-9.]+%)/, kv);
    match($0, /Prefix cache hit rate: ([0-9.]+%)/, prefix);

    printf "%-8s | %-18s | %-16s | %-16s | %-8s | %-8s | %-12s | %s\n", \
           engine_id, time, p_tp[1], g_tp[1], run[1], wait[1], kv[1], prefix[1];
}
'

main() {
    if [ -t 0 ]; then
        echo "Error: This script requires input from a pipe or redirection." >&2
        echo "Usage: cat <log_file> | $0"
        exit 1
    fi

    # Added an "Engine" column to the header
    printf "%-8s | %-18s | %-16s | %-16s | %-8s | %-8s | %-12s | %s\n" \
           "Engine" "Time" "Prompt TP (t/s)" "Gen TP (t/s)" "Running" "Waiting" "KV Cache" "Prefix Hit"
    
    printf "%s\n" "---------+--------------------+------------------+------------------+----------+----------+--------------+------------"

    awk "$AWK_SCRIPT"
}

main "$@"