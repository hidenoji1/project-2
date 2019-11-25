FROM gitpod/workspace-full:latest

ENV APACHE_DOCROOT_IN_REPO="www"

USER root

RUN apt-get update \
 && apt-get install -y apache2 \
 && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

#RUN sed -ri "s!Listen *:8001!Listen *:8080!" -i "/etc/apache2/apache2.conf"
