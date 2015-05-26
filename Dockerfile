FROM golang
ADD . /go/src/github.com/ironbay/jarvis
ADD unrar /usr/local/bin/
RUN cd /go/src/github.com/ironbay/jarvis && go get && go install
RUN apt-get update
RUN apt-get install curl

CMD jarvis
VOLUME /var/lib/jarvis
EXPOSE 3001
