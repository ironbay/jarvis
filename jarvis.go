package main

import (
	"github.com/ironbay/jarvis/cortex"
	"github.com/ironbay/jarvis/media"
	"time"
)

func main() {
	go forever()
	cortex.Run()
	media.Run()

	select {}
}

func forever() {
	for {
		time.Sleep(time.Second)
	}
}
