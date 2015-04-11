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

func (e *event) Emit(m interface{}, c *Context) {
    v := reflect.ValueOf(m)
    e.emitValue(v, c)
}

func (e *event) Error(msg string, c *Context) {
    err := new(Error)
    err.Message = msg
    e.Emit(err, c)
}

func (e *event) Message(msg string, c *Context) {
    m := new(Message)
    m.Message = msg
    e.Emit(m, c)
}

func (e *event) EmitJson(kind string, data []byte, c *Context) {
    t := e.reflect[kind]
    if t == nil {
        log.Println("No model", kind)
        return
    }
    v := reflect.New(t)
    i := v.Interface()
    json.Unmarshal(data, i)
    e.emitValue(v, c)
}

func (e *event) emitValue(v reflect.Value, context *Context) {
    kind := v.Type().Elem()
    contextValue := reflect.ValueOf(context)
    Database.Put(v.Interface())

    for _, key := range e.reflect {
        if kind.AssignableTo(key) || (key.Kind() == reflect.Interface && v.Type().Implements(key)) {
            for _, cb := range e.cache[key.Name()] {
                go cb.Call([]reflect.Value{v, contextValue})
            }
        }
    }

}
