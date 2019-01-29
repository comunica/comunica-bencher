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

TODO: replication, warmup, server workers, timeout, ...

## License
This code is copyrighted by [Ghent University – imec](http://idlab.ugent.be/)
and released under the [MIT license](http://opensource.org/licenses/MIT).
