package jarvis

import (
	"github.com/gin-gonic/gin"

	"golang.org/x/net/websocket"
)

func forever(ws *websocket.Conn) {
	query := ws.Request().URL.Query()
	connection := Connection{
		Conn:         ws,
		Subscription: Subscribe(query.Get("pattern"), false),
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
		pattern := ctx.Request.URL.Query().Get("pattern")
		subscription := Subscribe(pattern, true)
		event := <-subscription.Channel
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

	r.Run(":3001")
}
