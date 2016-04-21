FROM debian:jessie
COPY install.sh /root/
COPY entrypoint.sh /
RUN cd /root/ \
    && bash install.sh
ENTRYPOINT ["/entrypoint.sh"]
