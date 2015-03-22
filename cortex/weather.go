package cortex

import (
    "fmt"
    forecast "github.com/mlbright/forecast/v2"
)

type Weather struct {
    Forecast *forecast.Forecast
}

func (r *Weather) Alert() string {
    w := r.Forecast
    msg := w.Hourly.Summary
    msg += fmt.Sprintf(" Temperature is %v with a lows of %v and highs of %v. ", w.Currently.Temperature, w.Daily.Data[0].TemperatureMin, w.Daily.Data[0].TemperatureMax)
    msg += w.Daily.Summary

    return msg
}

func init() {
    Pipe.Listen("weather", func(l Listener, args []string) {
        m := new(Weather)
        m.Forecast, _ = forecast.Get("401c7658a2ad5cd62d2671286e1a4c4d", "40.78", "-73.97", "now", forecast.US)
        Event.Emit(m)
    })

    Cron.AddFunc("0 54 10 * * *", func() {
        m := new(Weather)
        m.Forecast, _ = forecast.Get("401c7658a2ad5cd62d2671286e1a4c4d", "40.78", "-73.97", "now", forecast.US)
        Event.Emit(m)
    })
}
