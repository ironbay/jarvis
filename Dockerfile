FROM golang
ADD . /go/src/github.com/ironbay/jarvis
RUN cd /go/src/github.com/ironbay/jarvis && go get && go install
CMD jarvis
EXPOSE 3001
