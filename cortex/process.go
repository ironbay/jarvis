package cortex

import (
    "log"
    "os/exec"
    "strings"
)

type process struct {
}

var Process process

type ProcessStart struct {
    Command string
}

func init() {
    Event.Listen(func(model *ProcessStart, context *Context) {
        Process.Run(model.Command)
    })
}

func (*process) Run(cmd string) {
    splits := strings.Fields(cmd)
    bytes, err := exec.Command(splits[0], splits[1:len(splits)]...).Output()
    if err != nil {
        log.Println(err)
        return
    }
    log.Println(string(bytes))
}
