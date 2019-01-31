# Comunica Bencher

A set of scripts for easily running benchmarks with [Comunica](https://github.com/comunica/comunica) and [LDF Server](https://github.com/LinkedDataFragments/Server.js).

## Requirements

* [Docker](https://www.docker.com/)
* [docker-compose](https://docs.docker.com/compose/install/)

## Usage

This tool should be used in two steps:

* Preparation: Generating a dataset and query set. This should be done only once.
* Running: Starting the required machines and running the benchmark.

### Preparation

```bash
$ ./prepare-data.sh
```

This tool will automatically generate a dataset and query set using [WatDiv](https://dsg.uwaterloo.ca/watdiv/),
and convert the dataset to HDT.

It will generate the following output:
* `input/dataset.hdt`: An HDT file that was created from the generated WatDiv dataset.
* `input/dataset.hdt.index.v1-1`: A corresponding HDT index file.
* `input/queries/`: A folder containing queries.

### Running

```bash
$ ./run-local.sh
```

This script will do the following:
* Start an **LDF server** based on the config in `input/server-config.json` (and dataset `input/dataset.hdt`).
* Start an **NGINX cache** in front of the LDF server based on the config from `input/nginx.conf` and `input/nginx-default`.
* Start a **Comunica engine** as SPARQL endpoint, based on the Comunica engine config in `input/client-config`.
* Start a **benchmark runner** that will execute the queries from `input/watdiv-10M`.

Once the benchmark runner is done, the following files will be available:
* `output/queries.csv`: Query execution time and number of results for all queries.
* `output/stats-client.csv`: CPU usage, Memory usage and I/O for the client.
* `output/stats-server.csv`: CPU usage, Memory usage and I/O for the server.
* `output/stats-server-cache.csv`: CPU usage, Memory usage and I/O for the server cache.
* `output/cache-logs/access.log`: NGINX access log files (including cache `HIT`/`MISS` details).
* `output/cache-logs/error.log`: NGINX error log files.

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

## License
This code is copyrighted by [Ghent University – imec](http://idlab.ugent.be/)
and released under the [MIT license](http://opensource.org/licenses/MIT).
