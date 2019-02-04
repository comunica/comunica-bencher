# Comunica Bencher

A tool for easily creating and running benchmarks with [Comunica](https://github.com/comunica/comunica) and [LDF Server](https://github.com/LinkedDataFragments/Server.js).

Experiments that are created and executed with this tool are [fully reproducible](https://linkedsoftwaredependencies.org/articles/reproducibility/),
as experiments are fully _deterministic_,
and metadata on all exact installed dependency versions is emitted together with the results.

Together with the (semantic) configuration files of Comunica and LDF Server,
this tool completes the whole provenance chain of experimental results:

* **Setup** of sofware based on configuration
* **Generating** experiment input data
* **Execution** of experiments based on parameters
* Description of environment **dependencies** during experiments
* **Reporting** of results

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

This tool offers commands for executing the whole experimentation chain:

1. [**Initialization**](#1-initialization): Create a new experiment. This should be done only once.
2. [**Data Preparation**](#2-data-preparation): Generating a dataset and query set. This should be done only once.
3. [**Running Experiments**](#3-running-experiments): Starting the required machines and running the benchmark.
4. [**Results Analysis**](#4-results-analysis): Generating plots and outputting data for result analysis.

### 1. Initialization

```bash
$ comunica-bencher init <my-experiment-name>
```

Running this command will create a new directory with the given name.
This directory will contain all default required files for running an experiment.
You can initialize this directory as a [git](https://git-scm.com/) repository.

In most cases, you will only need to edit the `.env` file to [configure your experiment](#configurability).

### 2. Data Preparation

```bash
$ comunica-bencher prepare-data
```

This command will automatically generate a dataset and query set using [WatDiv](https://dsg.uwaterloo.ca/watdiv/),
and convert the dataset to HDT.

It will generate the following output:
* `input/dataset.hdt`: An HDT file that was created from the generated WatDiv dataset.
* `input/dataset.hdt.index.v1-1`: A corresponding HDT index file.
* `input/queries/`: A folder containing queries.

### 3. Running Experiments

```bash
$ comunica-bencher run-local
```

This command will start the following:
* **LDF server** based on the config in `input/server-config.json` (and dataset `input/dataset.hdt`).
* **NGINX cache** in front of the LDF server based on the config from `input/nginx.conf` and `input/nginx-default`.
* **Comunica engine** as SPARQL endpoint, based on the Comunica engine config in `input/client-config.json`.
* **Benchmark runner** that will execute the queries from `input/queries`.

Once the benchmark runner is done, the following files will be available:
* `output/queries.csv`: Query execution time and number of results for all queries.
* `output/stats-client.csv`: CPU usage, Memory usage and I/O for the client.
* `output/stats-server.csv`: CPU usage, Memory usage and I/O for the server.
* `output/stats-server-cache.csv`: CPU usage, Memory usage and I/O for the server cache.
* `output/cache-logs/access.log`: NGINX access log files (including cache `HIT`/`MISS` details).
* `output/cache-logs/error.log`: NGINX error log files.
* `output/dependencies-client.ttl`: An [RDF representation of all dependencies](https://www.npmjs.com/package/semantic-dependencies) that were available in the client.
* `output/dependencies-server.ttl`: An [RDF representation of all dependencies](https://www.npmjs.com/package/semantic-dependencies) that were available in the server.

### 4. Results Analysis

This tool offers a few commands to analyze and plot the experiment results:

#### Plot query execution times

```bash
$ comunica-bencher plot queries [experiment1 [experiment2 [...]]]
```

This command will create a vectorial CSV-based (LaTeX/TiKZ) plot that compares the query execution times over all given experiments.
This is useful for comparing different approaches with each other.

Concretely, it will output the `plot_queries_data.csv` and `plot_queries_data.tex` files.
These can be included in a LaTeX document, or converted to other formats like SVG and PDF.

#### Calculate stats

```bash
$ comunica-bencher plot stats <action> experiment
```

This command allows you to calculate the following statistics over your results:

| Action                 | Description |
| ---------------------- | ----------- |
| `all`                  | Print a summary of all results |
| `cpu-server`           | Print the server's average CPU load (%) |
| `cpu-server-cache`     | Print the cache server's average CPU load (%) |
| `cpu-client`           | Print the client's average CPU load (%) |
| `mem-server`           | Print the server's average memory usage (%) |
| `mem-server-cache`     | Print the cache server's average memory usage (%) |
| `mem-client`           | Print the client's average memory usage (%) |
| `io-server`            | Print the server's total network interface input/output amount |
| `io-server-cache`      | Print the cache server's total network interface input/output amount |
| `io-client`            | Print the client's total network interface input/output amount |

For example, `comunica-bencher plot stats all experiment` could output the following
```
Stats summary:
  Server CPU:       10.33%
  Server cache CPU: 4.66%
  Client CPU:       97.37%
  Server mem:       3.17%
  Server cache mem: 2.25%
  Client mem:       6.24%
  Server I/O:       10.7MB / 54.3MB
  Server cache I/O: 64.5MB / 89MB
  Client I/O:       78.7MB / 11.2MB
```

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
