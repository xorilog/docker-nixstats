FROM debian:jessie
COPY install.sh /root/
COPY entrypoint.sh /
RUN apt-get update && apt-get install -y apt-utils cron wget
RUN cd /root/ \
    && bash install.sh
ENTRYPOINT ["/entrypoint.sh"]
