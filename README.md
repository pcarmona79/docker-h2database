# Docker image for H2

A Docker image for the [H2 Database Engine](http://www.h2database.com/).

## Versions

Currently only the latest stable image is built, which according to
[this page](http://www.h2database.com/html/download.html) is
**Version 2.4.214 (2022-06-13)**.

## How to use this image

```sh
docker run --name my-h2 -d pcarmona/h2database
```

The default TCP port 9092 is exposed, so standard container linking will make it
automatically available to the linked containers.

Use this JDBC string to connect from another container:

```
jdbc:h2:tcp://my-h2/mydb
```

## Using the web interface

If you want to connect to the H2 web interface, bind the port 8082:

```sh
docker run --name my-h2 -p 8082:8082 -d pcarmona/h2database
```

Then in your browser open http://localhost:8082/ and use the following
connection parameters:

Driver Class: org.h2.Driver
JDBC URL: jdbc:h2:tcp://localhost/mydb
User Name: sa
Password: _(empty)_

## Environment Variables

This new version adds new environment variables to customize the image

- `RELEASE_VERSION`: H2 Database version, used to select the jar file to
download from Maven.
- `H2_DBNAME`: database name to be used on init. Defaults to "mydb".
- `H2_USER` and `H2_PASSWORD`, user and password to connect to the database.
Defaults to user "sa" and empty password.
- `H2_OPTIONS`: extra H2 options to be added in the URL. Defaults to
empty.
- `H2DATA` specifies the location for the db files. If not set, `/h2-data` is used
which is automatically created as an anonymous Docker volume.

## Initialization scripts

This image uses an initialization mechanism similar to the one used in the
[official Postgres image](https://hub.docker.com/_/postgres/).

You can add one or more `*.sql` or `*.sh` scripts under
/docker-entrypoint-initdb.d (creating the directory if necessary). The image
entrypoint script will run, in alphabetic order, any `*.sql` files and source
any `*.sh` scripts found in that directory to do further initialization before
starting the service.

If you want to do something more complex, use a `.sh` script instead, for
example adding the following content to `/docker-entrypoint-initdb.d/init.sh`:

```sh
#!/bin/sh

java -cp /h2/bin/h2.jar org.h2.tools.RunScript \
  -script /docker-entrypoint-initdb.d/baz \
  -url "jdbc:h2:/h2-data/custom-db-name"
```

## Example Dockerfile

```dockerfile
FROM pcarmona/h2database:2.1.214

ENV H2_DBNAME=mydb
ENV H2_USER=user
ENV H2_PASSWORD=p4ssw0rd
ENV H2_OPTIONS="DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_ON_EXIT=FALSE"

WORKDIR /docker-entrypoint-initdb.d/
COPY mydb-tables.sql ./10-tables.sql
COPY initial-data.sql ./20-initial-data.sql
```
This example will create an image in the URL `jdbc:h2:tcp://my-server/mydb`, and completely
operative if none script fails.
