FROM tutum.co/dax/go:master

ADD . .
RUN go get -v ./..
RUN go build *.go

CMD go run *.go

EXPOSE 12000
