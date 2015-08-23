FROM golang
WORKDIR /go/src/github.com/ironbay/jarvis
ADD . .
RUN cd jarvis && go get -t -d -v && go install -v

CMD jarvis
VOLUME /var/lib/jarvis
EXPOSE 3001
