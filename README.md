# unifi-controller

Docker image and Helm chart for deploying the Ubiquiti UniFi Controller in a
containered environment.

## Components

### Docker Image

The published Docker images are built for Linux on x86_64, ARM v7 (32-bit),
and ARM v8 (64-bit) architectures, and tagged with the installed version of the
UniFi Controller, both per-architecture (e.g. `5.12.35-1-amd64`) and as a
multi-architecture manifest (e.g. `5.12.35-1`). The controller's server logs are
redirected to standard out by default. No embedded MongoDB database is
included; one must be started separately, and its connection strings passed
into the container with the `DB_URI` and `STATDB_URI` environment variables,
and the database name with the `DB_NAME` environment variable.

### Helm Chart

The included Helm chart is based on the [stable/unifi][] chart. See its
[`values.yaml`](Charts/unifi-controller/values.yaml) for customization
options. By default, it will install and connect to a MongoDB replica set
using the [stable/mongodb-replicaset][] chart, but you can disable this and
manually specify a set of MongoDB hosts to connect to.

## Quickstart

    docker-compose up

The included [`docker-compose.yml`](docker-compose.yml) will start MongoDB
and the UniFi controller as separate services, with all persistent data stored
in volumes on the host machine.

## Development

### Requirements

- Python 3
- Pipenv
- Docker

### Setup

    pipenv install

### Building

    inv build

You can pass a UniFi Controller version number:

    inv build -v 5.12.35

or a Docker repository for tagging:

    inv build -r hannahsfamily/unifi-controller

or a set of architectures:

    inv build -a amd64 -a ppc64 -a arm32v7 -a arm64v8

to the build script. See [`tasks.py`](tasks.py) for the default values.

### Pushing

    inv push

pushes the built and tagged images, and

    inv manifest

creates and pushes a multi-architecture manifest. The version, repository, and
architectures all must be specified using the same flags as the `build` command
if non-default values were used for building.

[stable/unifi]: https://github.com/helm/charts/tree/master/stable/unifi
[stable/mongodb-replicaset]: https://github.com/helm/charts/tree/master/stable/mongodb-replicaset
