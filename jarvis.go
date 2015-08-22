package main

import (
	"os"

	"github.com/ironbay/jarvis/cortex"
)

func main() {
	args := os.Args
	if len(args) == 1 {
		return
	}

	switch args[1] {
	case "cortex":
		go cortex.Run()
	}

	select {}
}
