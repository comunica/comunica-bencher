# Comunica Bencher

A tool for easily creating and running benchmarks with [Comunica](https://github.com/comunica/comunica) and [LDF Server](https://github.com/LinkedDataFragments/Server.js).

## Requirements

* [Bash](https://www.gnu.org/software/bash/) _(Installed by default on UNIX machines)_
* [Docker](https://www.docker.com/)
* [docker-compose](https://docs.docker.com/compose/install/)

## Install

### Automatically

This will automatically clone this repo into `$HOME/.comunica-bencher` (_requires [git](https://git-scm.com/)_),
and adds this tool to your `$PATH`.

```bash
$ sh -c "`curl -fsSl https://raw.githubusercontent.com/comunica/comunica-bencher/master/install.sh`"
```

If you want to uninstall later, just remove `$HOME/.comunica-bencher` and the `$PATH` modification in `~/.bash_profile`.

### Manually

First, clone this repo somewhere:

```bash
$ git clone git@github.com:comunica/comunica-bencher.git
```

Then, add the `/bin` folder to your `$PATH`.
For example, by adding the following to your `~/.bash_profile`

```bash
export PATH="/path/to/comunica-bencher/bin:$PATH"
```

## Usage

This tool should be used in three steps:

* **Initialization**: Create a new experiment. This should be done only once.
* **Data Preparation**: Generating a dataset and query set. This should be done only once.
* **Running**: Starting the required machines and running the benchmark.
* **Analysis**: Generating plots and outputting data for result analysis.

### Initialization

```bash
$ comunica-bencher init <my-experiment-name>
```

Running this command will create a new directory with the given name.
This directory will contain all default required files for running an experiment.
You can initialize this directory as a [git](https://git-scm.com/) repository.

In most cases, you will only need to edit the `.env` file to [configure your experiment](#configurability).

### Preparation

```bash
$ comunica-bencher prepare-data
```

This command will automatically generate a dataset and query set using [WatDiv](https://dsg.uwaterloo.ca/watdiv/),
and convert the dataset to HDT.

It will generate the following output:
* `input/dataset.hdt`: An HDT file that was created from the generated WatDiv dataset.
* `input/dataset.hdt.index.v1-1`: A corresponding HDT index file.
* `input/queries/`: A folder containing queries.

### Running

```bash
$ comunica-bencher run-local
```

This command will start the following:
* **LDF server** based on the config in `input/server-config.json` (and dataset `input/dataset.hdt`).
* **NGINX cache** in front of the LDF server based on the config from `input/nginx.conf` and `input/nginx-default`.
* **Comunica engine** as SPARQL endpoint, based on the Comunica engine config in `input/client-config.json`.
* **Benchmark runner** that will execute the queries from `input/watdiv-10M`.

Once the benchmark runner is done, the following files will be available:
* `output/queries.csv`: Query execution time and number of results for all queries.
* `output/stats-client.csv`: CPU usage, Memory usage and I/O for the client.
* `output/stats-server.csv`: CPU usage, Memory usage and I/O for the server.
* `output/stats-server-cache.csv`: CPU usage, Memory usage and I/O for the server cache.
* `output/cache-logs/access.log`: NGINX access log files (including cache `HIT`/`MISS` details).
* `output/cache-logs/error.log`: NGINX error log files.

### Analysis

This tool offers a few commands to analyze and plot the experiment results:

* `comunica-bencher plot queries [experiment1 [experiment2 [...]]]`: Create a vectorial CSV-based (LaTeX/TiKZ) plot (`plot_queries_data.csv` and `plot_queries_data.tex`) comparing the query execution times over all given experiments. This is useful for comparing different approaches with each other.

## Configurability

With the `.env` file, you can configure your benchmark.
The following options are available:

| Key                    | Description |
| ---------------------- | ----------- |
| `DATASET_SCALE`        | The WatDiv dataset scale (1 ~= 100K triples).  |
| `QUERY_COUNT`          | The number of queries per category in WatDiv.  |
| `QUERIES`              | A folder containing queries to execute.  |
| `REPLICATION`          | The number of times the queries should be executed and averaged over. |
| `WARMUP_ROUNDS`        | The number of times the queries should be executed as a warmup. |
| `SERVER_DATASET`       | Path to an HDT file that will be loaded in the server as dataset. |
| `SERVER_CONFIG`        | Path to an LDF server config file. |
| `SERVER_WORKERS`       | The number of workers the LDF server will have. |
| `CLIENTS`              | The number of concurrent clients. |
| `CLIENT_CONFIG`        | Path to a Comunica config file. |
| `CLIENT_QUERY_SOURCES` | Path to a JSON config file containing Comunica context, containing the sources that need to be queried. |
| `CLIENT_TIMEOUT`       | The query timeout in milliseconds. |

By default, the Comunica engine will query the server cache at `http://server-cache:80/dataset`.
If you want to skip this cache, you can set the source in `input/client-sources.json` to `http://server:3000/dataset` instead.

If you want change more fundamental this to your experiment,
you can change the following files:
* `docker-compose.yml`: Instantiation of multiple services for your experiment.
* `dockerfiles/`: Dockerfiles for the different services that are described in `docker-compose.yml`. These will be built on each experiment run.
* `input/client-config`: The Comunica config file.
* `input/client-sources.json`: The context containing the list of sources that Comunica should query with.
* `input/nginx.conf`, `input/nginx-default`: NGINX configuration.
* `server-config.json`: LDF server config file.

## License
This code is copyrighted by [Ghent University – imec](http://idlab.ugent.be/)
and released under the [MIT license](http://opensource.org/licenses/MIT).
