package cortex

import (
    "fmt"
    "github.com/julienschmidt/httprouter"
    "io/ioutil"
    "log"
    "net/http"
)

func init() {
    Router := httprouter.New()

    Router.POST("/event/:kind", func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
        kind := ps.ByName("kind")
        data, err := ioutil.ReadAll(r.Body)
        if err != nil {
            return
        }
        log.Println(kind)
        Event.EmitJson(kind, data)
        fmt.Fprint(w, "ok")
    })

    Router.GET("/event/:kind", func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
        kind := ps.ByName("kind")
        fmt.Fprint(w, Database.Raw(kind))
    })

    go http.ListenAndServe(":11000", Router)
}
