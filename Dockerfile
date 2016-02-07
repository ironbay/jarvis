FROM tutum.co/dax/go:master

WORKDIR /go/src/github.com/ironbay/jarvis
COPY . .
RUN go get -v ./..
RUN go build *.go

CMD go run *.go

EXPOSE 12000
