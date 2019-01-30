# Comunica Bencher

A set of scripts for easily running benchmarks with [Comunica](https://github.com/comunica/comunica) and [LDF Server](https://github.com/LinkedDataFragments/Server.js).

## Requirements

* [Docker](https://www.docker.com/)
* [docker-compose](https://docs.docker.com/compose/install/)

## Usage

```bash
$ ./run-local.sh
```

This script will do the following:
* Start an LDF server based on the config in `input/server-config.json` (and dataset `input/dataset.hdt`).
* Start a Comunica engine as SPARQL endpoint, based on the Comunica engine config in `input/client-config`.
* Start a benchmark runner that will execute the queries from `input/watdiv-10M`.

Once the benchmark runner is done, the following files will be created:
* `output/queries.csv`: Query execution time for all queries
* `output/stats-client.csv`: CPU usage, Memory usage and I/O for the client
* `output/stats-server.csv`: CPU usage, Memory usage and I/O for the server

## Configurability

With the `.env` file, you can configure your benchmark.
The following options are available:

| Key                    | Description |
| ---------------------- | ----------- |
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

## License
This code is copyrighted by [Ghent University – imec](http://idlab.ugent.be/)
and released under the [MIT license](http://opensource.org/licenses/MIT).
