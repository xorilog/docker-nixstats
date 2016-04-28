[![Circle CI](https://circleci.com/gh/xorilog/docker-nixstats.svg?style=shield)](https://circleci.com/gh/xorilog/docker-nixstats)  

## Adjusted sysstat for Docker use
This is a patched sysstat which can be used to lookup /proc for CoreOS use. Within CoreOS it is not possible to execute a volume mount on /proc. In order to achieve this, the sourcode has been patched to use /host/proc. By executing a volume mount on /host/proc, sysstat is able to collect metrics from the guest CoreOS system.

# Applied patch
The modification is rather simple but effective. The code is executed through in the install.sh shell script which is modified to check if it is running inside a docker container. In case you run the install.sh script on a non dockerized system, it will behave as usual. This modification is done on sysstat and nixstat2.sh.

cron have been added too as it is usually not present in the containers.

```shell
echo "Configuring sysstat..."
if [ -f /.dockerinit ]; then
    echo "I'm inside matrix ;(";
    oldstring=/proc
    newstring=/host/proc
    grep -rl $oldstring ./ | xargs sed -i s@$oldstring@$newstring@g
else
    echo "I'm living in real world!";
fi
```

# Run the image
===============
Last but not least we need to run the image of course. Please note that we run the container in read-only mode.

```shell
#!/bin/bash
sudo docker run -d --name nixstats \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/proc:/host/proc \
  --privileged \
  --pid=host \
  --net=host \
  -e NIXSTAT_USER=<NIXSTAT_USER> \
-e SERVERID=$(cat /etc/machine-id) \
  xorilog/nixstats
```

#HTTP proxy case
================
In order to make the data go through your http proxy you have to add the following parameter:
```shell
-e https_proxy=http://<your proxy>:<proxy_port>/

```
