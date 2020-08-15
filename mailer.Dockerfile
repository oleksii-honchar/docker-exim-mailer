FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
apt-get install -y exim4-daemon-light && \
apt-get clean

ADD update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf
RUN /usr/sbin/update-exim4.conf

COPY entrypoint.sh /entrypoint.sh
RUN cp /etc/aliases /etc/aliases.stub

EXPOSE 25
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/exim4", "-bd", "-d-all", "-v", "-q30m"]