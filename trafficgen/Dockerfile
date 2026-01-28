FROM ubuntu
SHELL ["/bin/bash", "-c"]
ARG HTTP_PROXY
RUN if [ -n "$HTTP_PROXY" ]; then \
      echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" > /etc/apt/apt.conf.d/99proxy; \
      echo "Acquire::https::Proxy \"${HTTP_PROXY}\";" >> /etc/apt/apt.conf.d/99proxy; \
    fi
RUN debconf-set-selections << "postfix postfix/mailname string traffcgen"
RUN debconf-set-selections << "postfix postfix/main_mailer_type string 'Internet Site'"
RUN apt-get update && apt-get install --assume-yes --no-install-recommends \
      postfix \
      mutt
RUN mkfifo /var/spool/postfix/public/pickup;
