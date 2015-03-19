package cortex

import (
    "encoding/json"
    "log"
    "reflect"
)

type event struct {
    cache   map[string][]reflect.Value
    reflect map[string]reflect.Type
}

type model interface {
}

var Event = func() *event {
    r := event{
        reflect: make(map[string]reflect.Type),
        cache:   make(map[string][]reflect.Value)}
    return &r
}()

func (e *event) Listen(cb interface{}) {
    f := reflect.ValueOf(cb)
    var t reflect.Type
    t = reflect.TypeOf(cb).In(0)
    if t.Kind() == reflect.Ptr {
        t = t.Elem()
    }
    kind := t.Name()
    log.Println(kind)
    e.reflect[kind] = t
    e.cache[kind] = append(e.cache[kind], f)
    Database.Register(kind)
}

func (e *event) Emit(m interface{}) {
    v := reflect.ValueOf(m)
    e.emitValue(v)
}

func (e *event) EmitJson(kind string, data []byte) {
    t := e.reflect[kind]
    v := reflect.New(t)
    i := v.Interface()
    json.Unmarshal(data, i)
    e.emitValue(v)
}

func (e *event) emitValue(v reflect.Value) {
    kind := v.Type().Elem()
    Database.Put(v.Interface())

    for _, key := range e.reflect {
        if kind.AssignableTo(key) || (key.Kind() == reflect.Interface && v.Type().Implements(key)) {
            for _, cb := range e.cache[key.Name()] {
                go cb.Call([]reflect.Value{v})
            }
        }
    }

}
