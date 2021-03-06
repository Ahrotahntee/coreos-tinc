FROM alpine:latest
MAINTAINER Robert Jones <rhjones@ahrotahntee.ca>
EXPOSE 655/udp 655/tcp
RUN apk update && apk add tinc jq curl bind-tools && rm -rf /var/cache
COPY tinc-setup /usr/sbin
COPY tinc-monitor /usr/sbin
RUN chmod +x /usr/sbin/tinc-*
ENTRYPOINT ["/usr/sbin/tincd"]
CMD ["-D"]
