package cortex

import (
	"github.com/gin-gonic/gin"

	"golang.org/x/net/websocket"
)

func socketConnect(ws *websocket.Conn) {
	query := ws.Request().URL.Query()
	connection := Connection{
		Conn:         ws,
		Subscription: Subscribe(query.Get("pattern"), true),
	}
	connection.listen()
}

func startServer() {
	r := gin.New()

	r.GET("/subscribe", func(ctx *gin.Context) {
		ws := websocket.Server{
			Handler: websocket.Handler(socketConnect),
		}
		ws.ServeHTTP(ctx.Writer, ctx.Request)
	})

	r.GET("/once", func(ctx *gin.Context) {
		pattern := ctx.Request.URL.Query().Get("pattern")
		subscription := Subscribe(pattern, true)
		event := <-subscription.Channel
		ctx.JSON(200, event)
	})

	r.POST("/emit/model", func(ctx *gin.Context) {
		event := new(Event)
		ctx.Bind(event)
		Emit(event)
		ctx.JSON(200, true)
	})

	r.POST("/register/regex", func(ctx *gin.Context) {
		regexModel := new(RegexModel)
		ctx.Bind(regexModel)
		registerRegexModel(regexModel)
		ctx.JSON(200, true)
	})

	r.Run(":3001")
}
