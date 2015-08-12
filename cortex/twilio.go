package cortex

import (
	"log"

	"github.com/sfreiberg/gotwilio"
)

type twilioSession struct {
	twilio *gotwilio.Twilio
	from   string
}

var Twilio = func() *twilioSession {
	accountSid := "AC7f285962f71e4e488f683e6404d52d28"
	authToken := "71d1c509fcb4c704dd6e2fd99a873854"
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
