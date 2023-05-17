# Welcome to Netrics Docker

With this repository, you can now install Netrics in a Docker container and run it on any machine without worrying about the environment. To get started, follow the steps below.

## Prerequisites

1. You must have `docker` cli installed on your computer where you plan to create the container.
2. You must be able to pull this repository down to your computer.

## Quick Start

1. Install the `docker` CLI. See the installation appropriate for your system [here](https://docs.docker.com/get-docker/).
2. Once you have the `docker` CLI installed, clone this repository to your local file system:
> ```bash
> git clone https://github.com/internet-equity/netrics-docker.git
> ```
3. Enter the cloned repository (`cd netrics-docker`).
4. Pull the latest Netrics Docker image from [Docker Hub](https://hub.docker.com/r/ucinternetequity/netrics).
> ```bash
> docker pull ucinternetequity/netrics
> ```
5. Start a container with the image and a volume mounted to receive data.
> ```bash
> docker run -d --name netrics-container -v ./volumes/netrics/result:/home/netrics/result ucinternetequity/netrics:latest
> ```
6. Check the logs from the container that you started to confirm that the software is running:
> ```bash
>docker logs ucinternetequity/netrics:latest
>```
7. Check the local directory where the files are stored to confirm that data is flowing from the container.
> ```bash
>ls volumes/netrics/result
>README.md
>result-1684336440-20230517T151400-dns-latency.json
>result-1684336520-20230517T151519-speed-ookla.json
>```
8. If you want to run the container interactively and use Netrics through the CLI interface (with a shell open in the container), run:
> ```bash
>docker run -it ucinternetequity/netrics:latest bash
>$ netrics -h
>```

> ### **☝️ Note**
>
> Running the container interactively in this manner will not automatically start the Netrics daemon (and no measurements will take place). If you want to run the container to start Netrics and see the measurement logs in your current shell, run this command instead:
> ```
> docker run -d --name netrics-test -v ./volumes/netrics/result:/home/netrics/result ucinternetequity/netrics:latest
> ℹ️  time="2023-05-17 15:55:14.990" level="info" event="3eGp0Cw51tos" session="3eGp0Cw54puN" execution_count=0 scheduled_next=2023-05-17T15:56:00
> ℹ️  time="2023-05-17 15:56:00.102" level="info" event="3eGp1TWzujwe" session="3eGp1TWA3gkb" sched="tiered-tenancy" task="hops-scamper" msg="skipped: suppressed by if/unless condition"
> ℹ️  time="2023-05-17 15:56:00.542" level="info" event="3eGp1UIhDdRC" session="3eGp1TWA3gkb" task="ip" status="OK" exitcode=0
> ```

With this set up, you will be able to run Netrics continuously to collect data on network performance from your computer. You can also interact with the Netrics software directly through the CLI interface on the container.

Read more below to learn more about reconfiguring the Docker image or the Netrics software using this repository.

> ### 🙏 **Feedback**
>
> If you find any issues with this repository or with the Netrics software, please report them to us! We'd also love to hear more about your experience using Netrics and any ideas you might have to make it better.
>
> Please send us a note at `broadband-equity@lists.uchicago.edu` or get in touch with us through one of the options on our [feedback page](https://internetequity.org/feedback/submitting-feedback.html).

## Receiving Data from Netrics Container

You can run the Netrics docker container with a mounted volume to transfer data from the container to your local computer. See additional details about how to do this [here](https://github.com/internet-equity/netrics-docker/blob/main/volumes/netrics/result/README.md).

## Rebuilding the Image

If you want to explore updating the image, you can edit the Dockerfile in this repository directly. If you make edits to the image, then you will need to rebuild it to propagate the changes to the docker container. To rebuild the image, follow these steps.

1. Make your edits in the Dockerfile and save the file.
2. Make sure you are in the root of the repository:
> ```bash
> cd your/path/to/netrics-docker
> ```
3. To build an image from the Dockerfile, run:
> ```bash
> docker build -t netrics:custom-tag .
> ```
Replace the `custom-tag` with you own tag.

4. Run the image in a new container.

```bash
docker run -d --name your-new-container-name -v ./volumes/netrics/result:/home/netrics/result netrics:custom-tag
```

## Updating Netrics' Default Configuration

The `config` directory in this repository contains the Netrics configuration files `defaults.yaml` and `measurements.yaml`. You can edit the files directly in the repository to change where Netrics saves data in the container and to customize the measurements configuration. To learn more about these configuration files, review the configuration section on the [Netrics repo](https://github.com/internet-equity/netrics#configuration).

**If you update a configuration file, you will need to rebuild the image locally**. Follow the steps [above](#rebuilding-the-image) to rebuild the image after updating the configuration.

### Updating a Measurement's Schedule and Parameters

Netrics runs measurements as tasks at a user-defined frequency in the `measurements.yaml` configuration file. Netrics relies on the [Fate library](https://github.com/internet-equity/fate) to schedule tasks and ensure their execution. Below is an example of a measurement and its schedule from the `measurements.yaml` file in this repository.

```yaml
ping:
  schedule: "H/5 * * * *"
  param:
    destinations:
      # network locator: results label
      www.google.com: google
      www.amazon.com: amazon
      www.wikipedia.org: wikipedia
      www.youtube.com: youtube
      www.facebook.com: facebook
      www.chicagotribune.com: tribune
      chicago.suntimes.com: suntimes
      cs.uchicago.edu: uchicago
```

In the example above, a measurement named `ping` is configured to run according to the `schedule` key nested below. This key's value is a string defining a CRON schedule. Netrics recognizes CRON schedules by default. The schedule above tells Netrics to run the `ping` task approximately on the fifth minute of every day. You can read more about CRON syntax [here](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/crontab.html).

The `param` key in the configuration provides inputs to the task that Netrics will run. In this instance, the `param` tells Netrics to run the ping measurement with a set of destinations. We can update this set here and run ping measurements to a different set of destinations. 

The actual module run by the `ping` command is another executable that comes installed with Netrics. Netrics has [built-in measurements](https://github.com/internet-equity/netrics#built-in-measurements) developed by researchers at the Internet Equity Initiative that a user can run out of the box.

```bash
docker run -it ucinternetequity/netrics bash
$ ls .local/bin | grep netrics
netrics
netrics-dev
netrics-dns-latency
netrics-hops
netrics-hops-scamper
netrics-hops-traceroute
netrics-ip
netrics-lml
netrics-lml-scamper
netrics-lml-traceroute
netrics-ping
netrics-speed-ndt7
netrics-speed-ookla
netrics-traceroute
netrics.d
netrics.s
```

Appropriate parameters are defined and controlled by the binary that runs the task. You can view the [source code for each built-in measurement](https://github.com/internet-equity/netrics/tree/main/src/netrics/measurement) on the Netrics repository. All built-in measurements are implemented in Python. However, Netrics' integration with Fate allows it to run any arbirtary module implemented in any language.

### Adding a New Measurement

Read the documentation [here](./config/measurements/README.md) to learn how to add new measurements Netrics when running it with this repository and docker. See the general documentation on the Netrics repository about [adding a new measurement](https://github.com/internet-equity/netrics#adding-builtins) to the framework.