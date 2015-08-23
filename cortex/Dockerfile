FROM golang
WORKDIR /go/src/github.com/ironbay/jarvis
ADD . .
RUN go get -t -d -v
RUN go build -v
CMD ./cortex
VOLUME /var/lib/jarvis
EXPOSE 3001
