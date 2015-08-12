package cortex

import (
	"log"
	"os"

	"github.com/sfreiberg/gotwilio"
)

type twilioSession struct {
	twilio *gotwilio.Twilio
	from   string
}

var Twilio = func() *twilioSession {
	accountSid := os.Getenv("TWILIO_SID")
	authToken := os.Getenv("TWILIO_AUTH")
	result := twilioSession{
		twilio: gotwilio.NewTwilioClient(accountSid, authToken),
		from:   "9494272522",
	}
	return &result
}()

func (ts *twilioSession) Send(to string, message string) {
	_, err, _ := ts.twilio.SendSMS(ts.from, to, message, "", "")
	log.Println(err)
}
