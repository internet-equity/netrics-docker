## New Measurement Development

To use Netrics to run additional modules in the container beyond our built-in measurements, you can create executables locally and copy them to the container during the image build. (Beware that modules that work on your computer might not be compatible with the container's environment. Be sure to use similar environment when developing a new module.)

We'll walk through how to add a new measurement to Netrics and schedule it to run continuously. To start, we want to add our measurement executable, which we will call `netrics-hello`, to the `config/measurements` directory in this repository:

```bash
#!/bin/sh

# For this simple example we're not interested in detailed ping data
# (and we don't want it echo'd as a "result") -- discard it.

ping -c 1 -w 1 example.com > /dev/null

# Rather, determine our result according to ping's own exit codes.

case $? in
0)
echo '{"example.com": "FAST ENOUGH"}'
exit 0
;;
1)
echo '{"example.com": "TOO SLOW"}'
exit 0
;;
*)
exit 1
;;
esac
```
The repository already contains this module so we don't need to create it ourselves. Once we have our module in this directory, we can build our Netrics docker image with the new measurement included. The new measurement is copied into the container and placed with other Netrics measurements. Once we rebuild the image and run a container with our new image, we can run the new measurement with the Netrics framework inside the container.

Specifically, we run:
```bash
docker build -t netrics:custom-tag .
docker run -it netrics:custom-tag bash
$ netrics debug execute netrics-hello
Name: -
Command: /home/netrics/.local/bin/netrics-hello

Status: OK (Exit code 0)

Result:

  {"example.com": "FAST ENOUGH"}
```
We can then update the `measurements.yaml` config file to schedule the new measurement through the framework. We will give the measurement the name `hello` and schedule it to run approximately every minute.
```yaml
hello:
  schedule: "H/1 * * * *"

dns-latency:
  schedule: "H/5 * * * *"
  param:
    destinations:
      - www.amazon.com
      - chicago.suntimes.com
      - www.chicagotribune.com
      - cs.uchicago.edu
      - www.facebook.com
      - www.google.com
      - www.wikipedia.org
      - www.youtube.com
      - www.nytimes.com
. . .
```
Since we have now updated the configuration file locally, we will need to rebuild the image again and run a new container with that image. After rebuilding, we can run:
```bash
docker run -it netrics:custom-tag bash
$ netrics debug run hello
Name: hello
Command: /home/netrics/.local/bin/netrics-hello

Status: OK (Exit code 0)

Result:

  {"example.com": "FAST ENOUGH"}
```
If we run the Netrics daemon to begin active data collection, we can see our new measurements appearing in the log.
```bash
$ netrics.d --foreground
            _        _          
           | |      (_)         
 _ __   ___| |_ _ __ _  ___ ___ 
| '_ \ / _ \ __| '__| |/ __/ __|
| | | |  __/ |_| |  | | (__\__ \
|_| |_|\___|\__|_|  |_|\___|___/

ℹ️  time="2023-05-17 20:36:50.098" level="info" event="3eGwKniPiYXu" session="3eGwKniPm3IV" execution_count=0 scheduled_next=2023-05-17T20:37:00
ℹ️  time="2023-05-17 20:37:00.124" level="info" event="3eGwKEXdrsma" session="3eGwKEXdF2zV" task="hello" status="OK" exitcode=0
ℹ️  time="2023-05-17 20:37:00.126" level="info" event="3eGwKEXpjZGc" session="3eGwKEXdF2zV" execution_count=1 scheduled_next=2023-05-17T20:38:00
ℹ️  time="2023-05-17 20:38:00.106" level="info" event="3eGwMmyxtNXf" session="3eGwMmyxJJpQ" task="hello" status="OK" exitcode=0
ℹ️  time="2023-05-17 20:38:03.049" level="info" event="3eGwMrJHmxvl" session="3eGwMmyxJJpQ" task="ping" dest-status={0=20}
ℹ️  time="2023-05-17 20:38:03.049" level="info" event="3eGwMrJJ6eAo" session="3eGwMmyxJJpQ" task="ping" status="OK" exitcode=0
ℹ️  time="2023-05-17 20:38:03.051" level="info" event="3eGwMrJS8p7X" session="3eGwMmyxJJpQ" execution_count=2 scheduled_next=2023-05-17T20:39:00
ℹ️  time="2023-05-17 20:39:00.175" level="info" event="3eGwO4jht4uO" session="3eGwO4jhKU7d" task="hello" status="OK" exitcode=0
ℹ️  time="2023-05-17 20:39:00.457" level="info" event="3eGwO4O0nK5G" session="3eGwO4jhKU7d" task="dns-latency" min_label={www.facebook.com=7.0} mean=21.9 stdev=14.6 max_label={cs.uchicago.edu=50.0}
ℹ️  time="2023-05-17 20:39:00.457" level="info" event="3eGwO4O1mm85" session="3eGwO4jhKU7d" task="dns-latency" status="OK" exitcode=0
ℹ️  time="2023-05-17 20:39:00.457" level="info" event="3eGwO4O5b7US" session="3eGwO4jhKU7d" execution_count=2 scheduled_next=2023-05-17T20:40:00
```

You can try adding your own custom measurements to the same folder and running them with Netrics following this process. Read more about the [requirements for measurement modules](https://github.com/internet-equity/netrics#development) and review the [source code](https://github.com/internet-equity/netrics/tree/main/src/netrics/measurement) for current Netrics measurements.