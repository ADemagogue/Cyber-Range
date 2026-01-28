FROM ubuntu
SHELL ["/bin/bash", "-c"]
ARG HTTP_PROXY
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTP_PROXY}
RUN debconf-set-selections << "postfix postfix/mailname string traffcgen"
RUN debconf-set-selections << "postfix postfix/main_mailer_type string 'Internet Site'"
RUN apt update
RUN apt install --assume-yes postfix
RUN apt install -y mutt
RUN mkfifo /var/spool/postfix/public/pickup;
