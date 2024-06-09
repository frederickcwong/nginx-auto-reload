FROM nginx:alpine
ARG VERSION

COPY ./inotify-monitor /inotify-monitor

RUN chmod +x /inotify-monitor/*.sh

RUN apk -U upgrade \
    && apk add -U inotify-tools

RUN echo "VERSION=$VERSION" >> /version.txt
RUN echo "ALPINE_VERSION=`cat /etc/os-release | grep VERSION_ID | awk -F= '{print $2}'`" >> /version.txt

CMD ["/inotify-monitor/cmd.sh"]
