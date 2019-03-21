#!/bin/bash
# Generate TiKZ graphs

print_usage () {
    echo "Usage: comunica-bencher plot <queries|queries_all|query_times> [options] experimentpath1 [experimentpath2 [...]]"
    echo "  queries                     Make a graph with the average query execution times of the given files."
    echo "  queries_all                 Generate a single CSV file with all query execution results with their corresponding combination id."
    echo "  query_times <query-name>    Make a graph showing the query result times for the given files."
    echo "  dief time                   Plot dief (t) for all queries in the given experiments."
    echo "Options:"
    echo "  -q                          Regex for queries to include. Examples: '^C', '^[^C]', ..."
    echo "  -n                          Custom output file name. Default: 'plot_queries_data'"
    exit 1
}

ensure_experiment_valid() {
    experiment=$1
    
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
}

handle_option_filename() {
    if [[ $experiment == -n ]]; then
        set_filename=1
        continue
    fi
    if [[ $set_filename == 1 ]]; then
        filename=$experiment
        set_filename=0
        continue
    fi
}

handle_option_query_regex() {
    if [[ $experiment == -q ]]; then
        set_query_regex=1
        continue
    fi
    if [[ $set_query_regex == 1 ]]; then
        query_regex=$experiment
        set_query_regex=0
        continue
    fi
}

load_experiment_data() {
    # Escape experiment name
    id=$(echo $experiment | sed "s/\//_/g")
          
    # Check if the experiment is valid
    ensure_experiment_valid $experiment
    
    # Load the actual data
    source $experiment/.env
}

lib_dir="$(dirname "${BASH_SOURCE[0]}")/"

plot_queries () {
    query_regex=''
    filename='plot_queries_data'
    
    # For each file, take the average of all query groups, and plot these for all files next to each other.
    touch .experiment_names
    touch .experiment_ids
    for experiment in "$@"; do
        # Handle options
        handle_option_filename
        handle_option_query_regex
        
        # Concat experiment name to file
        load_experiment_data
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
    paste -d ';' .tmp_plot_keys .tmp_plot_values_* > $filename.csv
    
    # Generate TiKZ file
    x_limits=$(echo "2*$(cat .experiment_names | wc -l)" | bc)
    width=$(echo "30*($(cat .tmp_plot_keys | wc -l)-1)" | bc)
    queries=$(tail -n +2 .tmp_plot_keys | paste -sd "," -)
    legend=$(cat .experiment_names | paste -sd "," -)
    barlines=$(cat .experiment_ids | sed 's/^\(.*\)$/\\\\addplot\+\[ybar\] table \[x=query\, y expr=\\\\thisrow{\1} \/ 1000, col sep=semicolon\]{"'$filename'.csv"};/g' | tr '\n' ' ')
    cp $lib_dir/../template_plot/plot_queries_data.tex $filename.tex
    sed -i.bak "s/%X_LIMITS%/$x_limits/" $filename.tex
    sed -i.bak "s/%WIDTH%/$width/" $filename.tex
    sed -i.bak "s/%QUERIES%/$queries/" $filename.tex
    sed -i.bak "s@%LEGEND%@$legend@" $filename.tex
    sed -i.bak "s@%BARS%@$barlines@" $filename.tex
    rm $filename.tex.bak
    
    # Remove temp files
    rm .experiment_names .experiment_ids .tmp_plot_keys .tmp_plot_keys_* .tmp_plot_values_*
    
    echo "Generated $filename.csv and $filename.tex"
}

plot_queries_all () {
    query_regex=''
    filename='data_all'
    
    # For each file, take the average of all query groups, and plot these for all files next to each other.
    for experiment in "$@"; do
        # Handle options
        handle_option_filename
        handle_option_query_regex
        
        # Load data
        load_experiment_data
        
        # Grab values
        tail -n +2 $experiment/output/queries.csv | cut -d ';' -f4 > .tmp_plot_values
        # Repeat experiment id as many times as there are queries
        seq -f "$id" $(cat .tmp_plot_values | wc -l) > .tmp_plot_keys
        
        # Combine columns with result and id
        paste -d ';' .tmp_plot_keys .tmp_plot_values > .tmp_plot_values_$id
        rm .tmp_plot_keys
        rm .tmp_plot_values
    done
    
    echo "combination;time" > $filename.csv
    cat .tmp_plot_values_* >> $filename.csv
    rm .tmp_plot_values_*
    
    echo "Generated $filename.csv"
}

plot_query_times () {
    query=$1
    shift
    filename="query_times_$query"
    
    # Collect query result times for a specific query in each of the given combinations.
    touch .experiment_names
    touch .experiment_ids
    for experiment in "$@"; do
        # Handle options        
        handle_option_filename
        
        # Concat experiment name to file
        load_experiment_data
        echo $EXPERIMENT_NAME >> .experiment_names
        echo $id >> .experiment_ids

        # Grab values
        echo $experiment > .times_$experiment.csv
        for time in $(cat $experiment/output/queries.csv | grep $query | head -n 1 | cut -d ';' -f5); do
            echo $time >> .times_$experiment.csv
        done
    done
    
    # Combine columns with result and id
    paste -d ';' .times_*.csv > $filename.csv
    
    # Generate TiKZ file
    legend=$(cat .experiment_names | paste -sd "," -)
    lines=$(cat .experiment_ids | sed 's/^\(.*\)$/\\\\addplot\+\[mark=none\] table \[y expr=\\\\coordindex+1\, x=\1, col sep=semicolon\]{"'$filename'.csv"};/g' | tr '\n' ' ')
    cp $lib_dir/../template_plot/plot_query_times.tex $filename.tex
    sed -i.bak "s/%QUERIES%/$queries/" $filename.tex
    sed -i.bak "s@%LEGEND%@$legend@" $filename.tex
    sed -i.bak "s@%LINES%@$lines@" $filename.tex
    rm $filename.tex.bak
    
    # Remove temp files
    rm .times_*.csv .experiment_names .experiment_ids
    
    echo "Generated $filename.csv and $filename.tex"
}

plot_dief () {
    dieftype=$1
    shift
    filename="dief_$dieftype"
    
    # Collect experiment names
    touch .experiment_names
    touch .experiment_ids
    experiments_inline=""
    for experiment in "$@"; do
        # Handle options        
        handle_option_filename
        
        # Concat experiment name to file
        load_experiment_data
        echo $EXPERIMENT_NAME >> .experiment_names
        echo $id >> .experiment_ids
        experiments_inline="$experiments_inline $experiment"
        
        cut -d ';' -f1 $experiment/output/queries.csv | tail -n +2 | uniq > .tmp_plot_keys
    done
    
    # Calculate dief
    $lib_dir/dief.sh $dieftype $experiments_inline > $filename.csv
    
    # Generate TiKZ file
    x_limits=$(echo "2*$(cat .experiment_names | wc -l)" | bc)
    width=$(echo "30*($(cat .tmp_plot_keys | wc -l)-1)" | bc)
    queries=$(cat .tmp_plot_keys | paste -sd "," -)
    legend=$(cat .experiment_names | paste -sd "," -)
    barlines=$(cat .experiment_ids | sed 's/^\(.*\)$/\\\\addplot\+\[ybar\] table \[x=query\, y=\1, col sep=semicolon\]{"'$filename'.csv"};/g' | tr '\n' ' ')
    cp $lib_dir/../template_plot/plot_dief.tex $filename.tex
    sed -i.bak "s/%X_LIMITS%/$x_limits/" $filename.tex
    sed -i.bak "s/%WIDTH%/$width/" $filename.tex
    sed -i.bak "s/%QUERIES%/$queries/" $filename.tex
    sed -i.bak "s@%LEGEND%@$legend@" $filename.tex
    sed -i.bak "s@%BARS%@$barlines@" $filename.tex
    rm $filename.tex.bak
    
    # Remove temp files
    rm .experiment_names .experiment_ids .tmp_plot_keys
    
    echo "Generated $filename.csv and $filename.tex"
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
queries_all)
    plot_queries_all $remainingargs
    ;;
query_times)
    plot_query_times $remainingargs
    ;;
dief)
    plot_dief $remainingargs
    ;;
*)
    echo "Invalid plot action '$action'"
    print_usage
    ;;
esac
