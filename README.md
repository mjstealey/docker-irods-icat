# docker-irods-icat
Docker implementation of iRODS iCAT Server using PostgreSQL 9.4

## Supported tags and respective Dockerfile links

- 4.1.9, latest ([4.1.9/Dockerfile](https://github.com/mjstealey/docker-irods-icat/blob/master/4.1.9/Dockerfile))
- 4.1.8 ([4.1.8/Dockerfile](https://github.com/mjstealey/docker-irods-icat/blob/master/4.1.8/Dockerfile))
- 4.1.7 ([4.1.7/Dockerfile](https://github.com/mjstealey/docker-irods-icat/blob/master/4.1.7/Dockerfile))

### Docker image

[![](https://images.microbadger.com/badges/image/mjstealey/docker-irods-icat.svg)](https://microbadger.com/images/mjstealey/docker-irods-icat "Get your own image badge on microbadger.com")

### Pull image from dockerhub

```bash
docker pull mjstealey/docker-irods-icat:4.1.9
```

### Usage:

**Example 1.** Deploy with default configuration
```bash
docker run --name icat mjstealey/docker-irods-icat:latest
```
This call can also be daemonized with the **-d** flag, which would most likely be used in an actual environment.

On completion a running container named **icat** is spawned with the following configuration:
```
-------------------------------------------
iRODS Zone:                 tempZone
iRODS Port:                 1247
Range (Begin):              20000
Range (End):                20199
Vault Directory:            /var/lib/irods/iRODS/Vault
zone_key:                   TEMPORARY_zone_key
negotiation_key:            TEMPORARY_32byte_negotiation_key
Control Plane Port:         1248
Control Plane Key:          TEMPORARY__32byte_ctrl_plane_key
Schema Validation Base URI: https://schemas.irods.org/configuration
Administrator Username:     rods
Administrator Password:     Not Shown (rods)
-------------------------------------------
-------------------------------------------
Database Type:     postgres
Hostname or IP:    localhost
Database Port:     5432
Database Name:     ICAT
Database User:     irods
Database Password: Not Shown (irods)
-------------------------------------------
```

Use the **docker exec** call to at the terminal interact with the container. Add the user definition of **-u irods** to specify that commands should be run as the **irods** user which is the systme user assigned to **rodsadmin**.

- Sample **ils**:
  ```
  $ docker exec -u irods icat ils
  /tempZone/home/rods:
  ```

- Sample **iadmin lz**
  ```
  $ docker exec -u irods icat iadmin lz
  tempZone
  ```

**Example 2.** Use an environment file to pass the required environment variables for the iRODS `setup_irods.sh` call.
```bash
$ docker run --env-file sample-env-file.env --name icat mjstealey/docker-irods-icat:4.1.9
```
- Using sample environment file named `sample-env-file.env` (Update as required for your iRODS installation)

  ```bash
  IRODS_SERVICE_ACCOUNT_NAME=irods
  IRODS_SERVICE_ACCOUNT_GROUP=irods
  IRODS_ZONE_NAME=tempZone
  IRODS_PORT=1247
  IRODS_PORT_RANGE_BEGIN=20000
  IRODS_PORT_RANGE_END=20199
  IRODS_VAULT_DIRECTORY=/var/lib/irods/iRODS/Vault
  IRODS_SERVER_ZONE_KEY=TEMPORARY_zone_key
  IRODS_SERVER_NEGOTIATION_KEY=TEMPORARY_32byte_negotiation_key
  IRODS_CONTROL_PLANE_PORT=1248
  IRODS_CONTROL_PLANE_KEY=TEMPORARY__32byte_ctrl_plane_key
  IRODS_SCHEMA_VALIDATION=https://schemas.irods.org/configuration
  IRODS_SERVER_ADMINISTRATOR_USER_NAME=rods
  IRODS_SERVER_ADMINISTRATOR_PASSWORD=rods
  IRODS_DATABASE_SERVER_HOSTNAME=localhost
  IRODS_DATABASE_SERVER_PORT=5432
  IRODS_DATABASE_NAME=ICAT
  IRODS_DATABASE_USER_NAME=irods
  IRODS_DATABASE_PASSWORD=irods
  ```
  
This call can also be daemonized with the **-d** flag, which would most likely be used in an actual environment.

On completion a running container named **icat** is spawned with the same configuration as in the first example.

- Sample **iadmin lr**:
  ```
  $ docker exec -u irods icat iadmin lr
  bundleResc
  demoResc
  ```

- Sample **iadmin lu**
  ```
  $ docker exec -u irods icat iadmin lu
  rods#tempZone
  ```
  
**Example 3.** Sharing host volume with container for persisting database or Vault

The container exposes two volume mount points for PostgreSQL data and iRODS Vault data.

- PostgreSQL data: `/var/lib/postgresql/data`
- iRODS Vault data: `/var/lib/irods/iRODS/Vault`

The host can mount local volumes corresponding to these in order to preserve the iRODS installation between runs of the docker container. Say we want to map `/LOCAL_POSTGRES` to `/var/lib/postgresql/data` and  `/LOCAL_IRODS` to `/var/lib/irods/iRODS/Vault`, we would run something like this.

```
$ docker run \
  -v /LOCAL_POSTGRES:/var/lib/postgresql/data \
  -v /LOCAL_IRODS:/var/lib/irods/iRODS/Vault \
  --name icat \
  mjstealey/docker-irods-icat:4.1.9
```

Using a local directory named `/mydata` for postgres data and another local directory `/myvault` for the iRODS vault with  our setup configuration in the  **sample-env.env** file we would run this.
```
$ docker run \
  -v /mydata:/var/lib/postgresql/data \
  -v /myvault:/var/lib/irods/iRODS/Vault \
  --env-file sample-env-file.env \
  --name icat \
  mjstealey/docker-irods-icat:4.1.9
```
On completion a running container named **icat** is spawned with the configuration as defined in the  **sample-env.env** file and if we were to look in the local `/mydata` and `myvault` directories we would see the following.

PostgreSQL **/mydata**
```
$ sudo ls /mydata/ -1
base
global
pg_clog
pg_dynshmem
pg_hba.conf
pg_ident.conf
pg_logical
pg_multixact
pg_notify
pg_replslot
pg_serial
pg_snapshots
pg_stat
pg_stat_tmp
pg_subtrans
pg_tblspc
pg_twophase
PG_VERSION
pg_xlog
postgresql.auto.conf
postgresql.conf
postmaster.opts
postmaster.pid
```
**NOTE** - sudo is required because the files are owned by the **postgres** user within the container which may not have a corresponding user on the local file system. The **postgres** user has UID=999, GID=999.

iRODS Vault **/myvault**
```
$ sudo ls /myvault/
home
$ sudo ls /myvault/home
rods
```
**NOTE** - sudo is required because the files are owned by the **irods** user within the container which may not have a corresponding user on the local file system. The **irods** user has UID=998, GID=998.

TODO: attach to persisted data on subsequent runs of container or destruction of container


