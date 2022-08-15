# postgres-etc 🐳 🐘 🐧

<img src="https://i.ibb.co/kqc3htP/logo.png" width="100">

### A simple as sand alpine, postgres(v14) and postgis docker image that allows for easy customizations (or your money back) 🤘 Great for dev machines.



---

## Important Info
- Log issues [here](https://github.com/c4lh4x/postgres-etc-docker-image/issues)
- [Github Repo](https://github.com/c4lh4x/postgres-etc-docker-image/)
- [Docker Hub Repo](https://hub.docker.com/repository/docker/c4lh4x/postgres-etc)

## Getting started

If you are a docker-compose fan, copy this example:
```yaml
version: '3.9'

services:
  postgres:
    restart: always
    image: c4lh4x/postgres-etc:14-0
    ports:
      - 5432:5432
    volumes:
      - "./pg_configs:/configs"
      - "./pg_mutations:/mutations"
      - "./pg_data:/var/lib/postgres/data"
```

## Options for `./pg_configs` (`/configs` in the container)

`./pg_configs` can contain these 3 files (All 3 are **optional**)
- `init.sql`: an initial SQL script you would like run every time a new container is spun up
- `pg_hba.conf`: replaces the initial `pg_hba.conf` and overwrites it on *every container run*
- `postgresql.conf`: replaces the initial `postgresql.conf` and overwrites it on *every container run*

## Options for `./pg_mutations` (`/mutations` in the container)

Mutations are any action (`shell script ending in .sh`) you want to perform once the db has been initialized. A small example, installing [wal2json](https://github.com/eulerto/wal2json). We create a file called `00_install_wal2json.sh` in the `/pg_mutations` folder on our local machine. This is the contents:

```bash
cd /var/lib/postgresql/plugins
echo "🟢 cloning wal2json"
git clone https://github.com/eulerto/wal2json.git wal2json
cd wal2json
echo "🟢 installing wal2json"
PATH=/var/lib/postgresql/data/postgresql.conf:$PATH
USE_PGXS=1 make
sudo USE_PGXS=1 make install
```

This would compile and install `wal2json` in our container. All mutations are run as the `postgres` user and have access to `root` via `sudo`. The `00_` is simply to allow for the scripts to run chronologically. The next script would be `01_install_foobar_extension.sh`

***Important**: Mutations run on every container run. If you don't need that, you will need to bash out some logic that circumnavigates that issue per mutation.*

## `./pg_data` (`/var/lib/postgresql/data` in the container)
`./pg_data` is there for observation reasons, there should be no need to interact with it, however if you need to interact with the postgres instance, you have access to it.
