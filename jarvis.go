package main

import (
	"github.com/ironbay/jarvis/cortex"
	"time"
)

func main() {
	go forever()
	cortex.Run()
	select {}
}

func forever() {
	for {
		time.Sleep(time.Second)
	}
}
