# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# install app dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y ca-certificates sudo apt-utils cron net-tools traceroute iputils-ping dnsutils nmap logrotate python3 python3-pip iproute2 curl

# install Ookla speedtest CLI
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
RUN sudo apt-get install speedtest

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
RUN cp /home/netrics/netrics-* /home/netrics/.local/bin/

# Run Netrics daemon
CMD netrics.d --foreground