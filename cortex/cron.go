package cortex

import "github.com/robfig/cron"

var Cron = func() *cron.Cron {
    c := cron.New()
    c.Start()

    return c

}()
