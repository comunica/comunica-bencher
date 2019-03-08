#!/bin/bash
# Generate TiKZ graphs

print_usage () {
    echo "Usage: comunica-bencher plot <queries> [options] experimentpath1 [experimentpath2 [...]]"
    echo "  queries       Make a graph with the average query execution times of the given files."
    echo "Options:"
    echo "  -q            Regex for queries to include. Examples: '^C', '^[^C]', ..."
    exit 1
}

lib_dir="$(dirname "${BASH_SOURCE[0]}")/"

plot_queries () {
    query_regex=''
    
    # For each file, take the average of all query groups, and plot these for all files next to each other.
    touch .experiment_names
    touch .experiment_ids
    for experiment in "$@"; do
        # Handle options
        if [[ $experiment == -q ]]; then
            set_query_regex=1
            continue
        fi
        if [[ $set_query_regex == 1 ]]; then
            query_regex=$experiment
            set_query_regex=0
            continue
        fi
        
        # Escape experiment name
        id=$(echo $experiment | sed "s/\//_/g")
              
        # Check if the experiment is valid
        if [ ! -f $experiment/.env ]; then
            echo "No valid experiment could be found at '$experiment'."
            exit 1
        fi
        
        # Check if the experiment contains query output
        if [ ! -f $experiment/output/queries.csv ]; then
            echo "No output/queries.csv file could be found in the experiment '$experiment'."
            exit 1
        fi
        
        # Concat experiment name to file
        source $experiment/.env
        echo $EXPERIMENT_NAME >> .experiment_names
        echo $id >> .experiment_ids
        
        # Calculate the average of each query group
        tail -n +2 $experiment/output/queries.csv \
            | awk -F ';' "{ sum[\$1]+=\$4;cnt[\$1]++ } END { print \"query;$id\"; for (i in sum) print i \";\" sum[i]/cnt[i] }" \
            | awk "NR==1 || /^$query_regex/" \
            | awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' \
            > .tmp_plot_$id
        
        # Grab keys
        cut -d ';' -f1 .tmp_plot_$id > .tmp_plot_keys_$id
        
        # Store keys
        if [ -f .tmp_plot_keys ]; then
            if ! cmp -s .tmp_plot_keys .tmp_plot_keys_$id ; then
              echo "Tried to plot experiments with different query sets"
              echo "  Existing: "
              cat .tmp_plot_keys
              echo "  New ($id): "
              cat .tmp_plot_keys_$id
              exit 1
            fi
        else
            cp .tmp_plot_keys_$id .tmp_plot_keys
        fi
        
        # Grab values
        cut -d ';' -f2 .tmp_plot_$id > .tmp_plot_values_$id
        rm .tmp_plot_$id
    done
    
    # Paste together the CSVs
    paste -d ';' .tmp_plot_keys .tmp_plot_values_* > plot_queries_data.csv
    
    # Generate TiKZ file
    x_limits=$(echo "2*$(cat .experiment_names | wc -l)" | bc) 
    queries=$(tail -n +2 .tmp_plot_keys | paste -sd "," -)
    legend=$(cat .experiment_names | paste -sd "," -)
    barlines=$(cat .experiment_ids | sed 's/^\(.*\)$/\\\\addplot\+\[ybar\] table \[x=query\, y expr=\\\\thisrow{\1} \/ 1000, col sep=semicolon\]{"plot_queries_data.csv"};/g' | tr '\n' ' ')
    cp $lib_dir/../template_plot/plot_queries_data.tex plot_queries_data.tex
    sed -i.bak "s/%X_LIMITS%/$x_limits/" plot_queries_data.tex
    sed -i.bak "s/%QUERIES%/$queries/" plot_queries_data.tex
    sed -i.bak "s@%LEGEND%@$legend@" plot_queries_data.tex
    sed -i.bak "s@%BARS%@$barlines@" plot_queries_data.tex
    rm plot_queries_data.tex.bak
    
    # Remove temp files
    rm .experiment_names .experiment_ids .tmp_plot_keys .tmp_plot_keys_* .tmp_plot_values_*
    
    echo "Generated plot_queries_data.csv and plot_queries_data.tex"
}

# Validate input args
if [[ $# -lt 1 ]] ; then
    echo "Error: Missing plot action"
    print_usage
fi

# Execute action
action=$1
remainingargs=${@:2}
case "$action" in
queries)
    plot_queries $remainingargs
    ;;
*)
    echo "Invalid plot action '$action'"
    print_usage
    ;;
esac
