package main

import (
	"bufio"
	"fmt"
	"os"

	"github.com/ironbay/jarvis/client"
	"github.com/ironbay/jarvis/cortex"
)

func main() {
	jarvis := client.NewClient("localhost:3001", "cli")
	go stringables(jarvis)
	fmt.Println("jarvis-cli")

	consolereader := bufio.NewReader(os.Stdin)
	for {
		fmt.Print("> ")

		input, err := consolereader.ReadString('\n')
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		if input == "" {
			continue
		}
		jarvis.EmitModel(cortex.Event{
			Type:    "conversation.message",
			Context: jarvis.GetContext(),
			Model:   cortex.Model{"message": input},
		})
	}
}

func stringables(jarvis *client.Client) {
	queue, _ := jarvis.Forever("conversation.stringable")
	for event := range queue {
		fmt.Print("--> ", event.Model["message"])
		fmt.Print("\n> ")
	}
}
