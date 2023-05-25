# syntax=docker/dockerfile:1
# install app dependencies
FROM golang:1.17-bullseye AS build
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y ca-certificates sudo apt-utils cron net-tools traceroute iputils-ping dnsutils nmap logrotate python3 python3-pip iproute2 curl git scamper

FROM build as modules
# install ndt7-client with Go
ENV GO111MODULE=on
RUN go get github.com/neubot/dash/cmd/dash-client@master
RUN go get github.com/m-lab/ndt7-client-go/cmd/ndt7-client
RUN go get github.com/m-lab/ndt5-client-go/cmd/ndt5-client

# install Ookla speedtest CLI
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
RUN sudo apt-get install speedtest

FROM modules as netrics
# Create netrics user
RUN useradd -ms /bin/bash netrics
USER netrics
WORKDIR /home/netrics

# Install Netrics and run as user
RUN pip install netrics-measurements

# Add Netrics path to environment
ENV PATH="/home/netrics/.local/bin:$PATH"

# Initiatlize Netrics
RUN netrics init conf
RUN netrics init comp --shell bash
RUN netrics init serv
# Need to create this path or else the daemon won't run
RUN mkdir -p /home/netrics/.local/state/netrics

# Create directory where Netrics writes data files (configurable)
RUN mkdir -p /home/netrics/result

# Copy local configuration files (instead of using defaults)
COPY ./config/measurements.yaml /home/netrics/.config/netrics/measurements.yaml
COPY ./config/defaults.yaml /home/netrics/.config/netrics/defaults.yaml
COPY ./config/measurements/netrics-* /home/netrics/
COPY ./config/measurements/modules/* /home/netrics/
RUN cp /home/netrics/netrics-* /home/netrics/.local/bin/
RUN cp /home/netrics/*.py /home/netrics/.local/lib/python3.9/site-packages/netrics/measurement


# Run Netrics daemon
CMD netrics.d --foreground