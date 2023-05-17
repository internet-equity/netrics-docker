## Exporting Netrics Data Outside the Container

When running the Docker image with Netrics pre-installed, you can configure the Docker container to export the Netrics measurements from a directory inside of the container to a local directory on your computer.

To do this, add the `-v` flag to the `docker run` command:

```bash
docker run -d --name netrics-container -v path/to/local/dir:path/to/container/dir netrics.0.0.3
```

We've provided a directory in this repository that you can use to export data. However, you can mount the container on any folder on your local file system. If you want to use the directory that we provide here, run this command:

```bash
docker run -d --name netrics-container -v ./volumes/netrics/result:/home/netrics/result netrics.0.0.3
```

Once you start the container with the volume mounted, you will begin to see data appear in your local directory.