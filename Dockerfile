FROM tutum.co/dax/go:master

WORKDIR /go/src/github.com/ironbay/jarvis/
COPY . .
RUN ls -lah
RUN go get -v
RUN go build

CMD ./jarvis

EXPOSE 12000
