#!/bin/bash
# Analyze stats

print_usage () {
    echo "Usage: comunica-bencher stats <action> experimentpath"
    echo "Actions:"
    echo "  all               Print a summary of all results"
    echo "  cpu-server        Print the server's average CPU load (%)"
    echo "  cpu-server-cache  Print the cache server's average CPU load (%)"
    echo "  cpu-client        Print the client's average CPU load (%)"
    echo "  mem-server        Print the server's average memory usage (%)"
    echo "  mem-server-cache  Print the cache server's average memory usage (%)"
    echo "  mem-client        Print the client's average memory usage (%)"
    echo "  io-server         Print the server's total network interface input/output amount"
    echo "  io-server-cache   Print the cache server's total network interface input/output amount"
    echo "  io-client         Print the client's total network interface input/output amount"
    exit 1
}

lib_dir="$(dirname "${BASH_SOURCE[0]}")/"

average () {
    echo "$(tail -n +2 $1 | cut -d ',' -f$2 | awk '{ sum += $1 } END { if (NR > 0) printf "%.2f", sum / NR }')%"
}

last () {
    tail -n 1 $1 | cut -d ',' -f$2
}

# Validate input args
if [[ $# -lt 1 ]] ; then
    echo "Error: Missing stats action"
    print_usage
fi
if [[ $# -lt 2 ]] ; then
    echo "Error: Missing experiment path"
    print_usage
fi

# Check if the experiment is valid
experiment=$2
if [ ! -f $experiment/.env ]; then
    echo "No valid experiment could be found at '$experiment'."
    exit 1
fi

# Execute action
action=$1
remainingargs=${@:2}
case "$action" in
all)
    echo "Stats summary:
  Server CPU:       $(average $experiment/output/stats-server.csv 1)
  Server cache CPU: $(average $experiment/output/stats-server-cache.csv 1)
  Client CPU:       $(average $experiment/output/stats-client.csv 1)
  Server mem:       $(average $experiment/output/stats-server.csv 2)
  Server cache mem: $(average $experiment/output/stats-server-cache.csv 2)
  Client mem:       $(average $experiment/output/stats-client.csv 2)
  Server I/O:       $(last $experiment/output/stats-server.csv 3)
  Server cache I/O: $(last $experiment/output/stats-server-cache.csv 3)
  Client I/O:       $(last $experiment/output/stats-client.csv 3)"
    ;;
cpu-server)
    average $experiment/output/stats-server.csv 1
    ;;
cpu-server-cache)
    average $experiment/output/stats-server-cache.csv 1
    ;;
cpu-client)
    average $experiment/output/stats-client.csv 1
    ;;
mem-server)
    average $experiment/output/stats-server.csv 2
    ;;
mem-server-cache)
    average $experiment/output/stats-server-cache.csv 2
    ;;
mem-client)
    average $experiment/output/stats-client.csv 2
    ;;
io-server)
    last $experiment/output/stats-server.csv 3
    ;;
io-server-cache)
    last $experiment/output/stats-server-cache.csv 3
    ;;
io-client)
    last $experiment/output/stats-client.csv 3
    ;;
*)
    echo "Invalid stats action '$action'"
    print_usage
    ;;
esac
