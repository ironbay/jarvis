package cortex

import (
    "bytes"
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "math/rand"
    "os"
    "reflect"
    "time"
)

type database struct {
}

type temporal struct {
    model
    Created time.Time
}

type Keyable interface {
    Key() string
}

var Database database

func init() {
}

func (d *database) Put(m interface{}) {
    var output = temporal{m, time.Now()}
    key := fmt.Sprint(rand.Float64())
    if k, ok := m.(Keyable); ok {
        key = k.Key()
    }
    data, _ := json.Marshal(output)
    err := ioutil.WriteFile(d.path(m)+key+".json", data, 0775)
    if err != nil {
        log.Println(err)
    }
}

func (d *database) Register(kind string) {
    path := "/var/lib/jarvis/" + kind
    os.MkdirAll(path, 0775)
}

func (d *database) path(m interface{}) string {
    t := reflect.TypeOf(m).Elem()
    kind := t.Name()
    if t.Kind() == reflect.Slice {
        kind = t.Elem().Name()
    }
    path := "/var/lib/jarvis/" + kind + "/"
    return path
}

func (d *database) Get(m interface{}) {
    path := d.path(m)
    var buffer bytes.Buffer
    buffer.WriteString("[")
    r, _ := ioutil.ReadDir(path)
    for i, p := range r {
        b, _ := ioutil.ReadFile(path + p.Name())
        buffer.Write(b)
        if i != len(r)-1 {
            buffer.WriteString(",")
        }
    }
    buffer.WriteString("]")
    json.Unmarshal(buffer.Bytes(), m)

}

func (d *database) Raw(kind string) string {
    path := "/var/lib/jarvis/" + kind + "/"
    var buffer bytes.Buffer
    buffer.WriteString("[")
    r, _ := ioutil.ReadDir(path)
    for i, p := range r {
        b, _ := ioutil.ReadFile(path + p.Name())
        buffer.Write(b)
        if i != len(r)-1 {
            buffer.WriteString(",")
        }
    }
    buffer.WriteString("]")
    return buffer.String()
}
