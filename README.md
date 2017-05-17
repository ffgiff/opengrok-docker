# opengrok-docker
Dockerfile to set up an OpenGrok server.

OpenGrok will index any repositories mounted under ```/data```; this should be
a read-only bind-mount. Repositories will be re-indexed daily by a cron job,
but they will need to be updated from outside the container as the container
has no credentials and the repositories should not be writable.

It is recommended to start the docker container and expose it via
reverse-proxy. The environment variable ```OPENGROK_WEBAPP_CONTEXT``` is the
deployment path of OpenGrok, i.e. it will expose it on
http://hostname/$OPENGROK_WEBAPP_CONTEXT. Setting
```OPENGROK_WEBAPP_CONTEXT``` makes it easier to reverse proxy multiple
OpenGrok servers than if both servers want to sit on http://hostname/source as
no URL re-writing is required. Authenticated access should also be done by the
reverse-proxy as OpenGrok has no native support for authenticated access.

## Example set-up of two OpenGrok instances

In this case we set up two containers and forward to ports 8080 and 8090. The
reverse-proxy can then be configured to map
http://localhost:8080/source-services to http://localhost/source-services and
http://localhost:8090/source-apps to http://localhost/source-apps.

```bash
sudo docker run -e OPENGROK_WEBAPP_CONTEXT=source-apps -i --restart=unless-stopped --name=opengrok_apps -v /data/src-apps:/data:ro,Z -p 127.0.0.1:8090:8080 -t vertu20140207/opengrok:latest
sudo docker run -e OPENGROK_WEBAPP_CONTEXT=source-services -i --restart=unless-stopped --name=opengrok_services -v /data/src-services:/data:ro,Z -p 127.0.0.1:8080:8080 -t vertu20140207/opengrok:latest
```

## Example re-indexing
It is also possible to use docker exec to run commands within the container,
e.g. to perform an immediate reindexing of opengrok:

```bash
sudo docker exec -u tomcat opengrok_services /usr/local/tomcat/opengrok-1.0/bin/OpenGrok index /data
```

## Example updating git repositories
Updating git repositories using a cron job is trivial.

```bash
find /path/to/repos -maxdepth 2 -type d -name .git -execdir git pull \;
```
