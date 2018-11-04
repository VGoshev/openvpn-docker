FROM alpine:3.8
MAINTAINER Vladimir Goshev <sunx@sunx.name>

RUN apk --no-cache add openvpn && \
	\
	echo Done!


COPY openvpn.conf /etc
COPY docker-run-root.sh /bin/docker-run-root

VOLUME /etc/openvpn

# Container will run some preparations with root access (fixing permissions, for example)
#   and then execute /bin/docker-run with user access to configure (if needed) and run
#		Services
CMD ["/bin/docker-run-root"]
