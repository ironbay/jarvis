package jarvis

import (
	"strconv"

	"github.com/dancannon/gorethink"
	"github.com/gin-gonic/gin"

	"golang.org/x/net/websocket"
)

func forever(ws *websocket.Conn) {
	query := ws.Request().URL.Query()
	connection := Connection{
		Conn:         ws,
		Subscription: Subscribe(query.Get("pattern"), query.Get("process")),
	}
	connection.listen()
}

func startServer() {
	r := gin.New()

	r.GET("/subscribe/forever", func(ctx *gin.Context) {
		ws := websocket.Server{
			Handler: websocket.Handler(forever),
		}
		ws.ServeHTTP(ctx.Writer, ctx.Request)
	})

	r.GET("/subscribe/once", func(ctx *gin.Context) {
		query := ctx.Request.URL.Query()
		pattern := query.Get("pattern")
		subscription := Subscribe(pattern, query.Get("process"))
		event := <-subscription.Channel
		subscription.Close()
		ctx.JSON(200, event)
	})

	r.POST("/emit/model", func(ctx *gin.Context) {
		event := new(Event)
		ctx.Bind(event)
		if _, ok := event.Context["type"]; !ok {
			ctx.String(500, "Context needs type")
			return
		}
		Emit(event)
		ctx.JSON(200, true)
	})

	r.POST("/register/regex", func(ctx *gin.Context) {
		regexModel := new(RegexModel)
		ctx.Bind(regexModel)
		registerRegex(regexModel)
		ctx.JSON(200, true)
	})

	r.POST("/register/stringable", func(ctx *gin.Context) {
		stringable := new(Stringable)
		ctx.Bind(stringable)
		registerStringable(stringable)
		ctx.JSON(200, true)
	})

	r.GET("/regex", func(ctx *gin.Context) {
		ctx.JSON(200, regexModels)
	})

	r.GET("/model/:type", func(ctx *gin.Context) {
		t := ctx.Param("type")
		page, err := strconv.Atoi(ctx.Request.URL.Query().Get("page"))
		if err != nil {
			page = 0
		}
		cur, _ := gorethink.Table("events").GetAllByIndex("type", t).Skip(page * 100).Limit(100).Run(Rethink)
		var result []Model
		cur.All(&result)
		ctx.JSON(200, result)
	})

	r.Run(":3001")
}
