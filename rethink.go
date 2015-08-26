package jarvis

import (
	"log"

	"github.com/dancannon/gorethink"
)

var Rethink = func() *gorethink.Session {
	result, err := gorethink.Connect(gorethink.ConnectOpts{
		Address:  "ironbay.digital:28015",
		Database: "jarvis",
	})
	if err != nil {
		log.Fatal("Failed to connect to rethink")
	}
	return result
}()
