## Welcome to Netrics Docker

With this repository, you can now install Netrics in a Docker container and run it on any machine without worrying about the environment. To get started, follow the steps below.

### Prerequisites

1. You must have `docker` cli installed on your computer where you plan to create the container.
2. You must be able to pull this repository down to your computer.

### Quick Start

1. Install the `docker` CLI. See the installation appropriate for your system [here](https://docs.docker.com/get-docker/).
2. Once you have the `docker` CLI installed, clone this repository to your local file system:
> ```bash
> git clone https://github.com/internet-equity/netrics-docker.git
> ```
3. Enter the cloned repository (`cd netrics-docker`).
4. Pull the latest Netrics Docker image from [Docker Hub](https://hub.docker.com/r/marcwitasee/netrics).
> ```bash
> docker pull marcwitasee/netrics
> ```
5. Start a container with the image and a volume mounted to receive data.
> ```bash
> docker run -d --name netrics-container -v ./volumes/netrics/result:/home/netrics/result netrics:latest
> ```
