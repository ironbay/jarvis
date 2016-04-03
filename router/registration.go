package router

import "github.com/ironbay/drs/drs-go"

type Registration struct {
	Key     string                 `json:"key"`
	Once    bool                   `json:"once"`
	Action  string                 `json:"action"`
	Chan    chan *drs.Command      `json:"-"`
	Hook    func(cmd *drs.Command) `json:"-"`
	Context map[string]interface{} `json:"context"`
}
