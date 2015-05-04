FROM golang
ADD . /go/src/github.com/ironbay/jarvis
RUN cd /go/src/github.com/ironbay/jarvis && go get && go run jarvis.go
EXPOSE 3001
