FROM alpine

RUN apk --no-cache --update upgrade && apk --no-cache add jq curl

COPY swarm.sh /

ENTRYPOINT ["swarm.sh"]
