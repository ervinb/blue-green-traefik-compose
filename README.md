## Blue/Green Deployment POC with Traefik and Docker Compose

### Setup

The scripts in this repository rely on the following tools being present in the environment:
- `curl`
- `jq`
- `docker`
- `docker-compose`
- `ab`
- `envsubst`


Set up the tools on the host or use the included toolchain Docker image.

#### Host

Install the required tools on the host machine:

```
$ apt update -qq
$ apt install apache2-utils curl jq gettext-base docker docker-compose
```


#### Toolchain

Alternatively, use a Docker container to run the scripts:

```
$ docker build -t bg-toolchain -f Dockerfile.toolchain .
$ docker run --rm --net host -ti -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/workspace bg-toolchain
$$ <run scripts>
```


### Start

```
$ docker-compose up -d
```

**NOTE**: This should be executed on the host and not in the toolchain
container. Otherwise, the command will fail with
`traefik error: read /etc/traefik/traefik.yml: is a directory` because
the source path is on the host and not in the toolchain container, so it
[mounts it as a directory](https://docs.docker.com/storage/bind-mounts/#differences-between--v-and---mount-behavior).

The command will start up the proxy (traefik) and 2 instances of the sample application (blue, green). Initially both
versions have the same content and use the same Docker image.

---

Traefik dashboard: [http://localhost:8080](http://localhost:8080)

Query the application endpoint:
```
$ curl -L -H 'Host: docker.localhost' http://localhost:8090
> INITIAL STATE
```


### Deployment

- Change the application content in `app/index.html`:
    ```
    $ date > app/index.html
    ```

- Deploy the change:
    ```
    $ ./deploy.sh
    ```
    Running the deployment process:
    - builds a new application image (including the change from the previous step)
    - recreates the inactive (blue or green) container using the new image
    - updates the proxy to route to this new instance

- Query the application endpoint:
    ```
    $ curl -L -H 'Host: docker.localhost' http://localhost:8090
    > Tue Feb 20 11:36:33 CET 2022
    ```

### Testing

To verify a no-downtime deployment process, run:
```
$ ./test.sh
```

This will:
- make a GET request to the application endpoint and print the result
- start the `ab` benchmark, hitting the application endpoint
- introduce a change in the application
- build and deploy the new container
- perform another GET request to show the updated content
- print the report
