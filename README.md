## What is this
This project is the core for Jarvis.  It has no functionality on its own, it is simply a smart event router.  You can write plugins that provide a conversational UI to interface with users' **asynchronous conversations** using a very simple **synchronous api.**  This allows feature development to completely ignore the complexities of what device is a user on, who is responding to what, and when do requests time out.

### Javascript Plugin Sample
Here is an example of building a conversation tree using code.  Note this will work in a conversation with multiple people and be able to differentiate between who is talking
```javascript
const jarvis = new Jarvis('jarvis.host')
// Jarvis comes with built in support for regex but you can write your own plugins to integrate fancy 3rd party apis as done below
jarvis.regex('^hello&', 'chat.greeting')

// This is an example of a 3rd party api integration
jarvis.on('chat.message', (data, session) => {
	const result = FancyNLP.analyze(data.text)
	if (result)
		session.emit('chat.greeting', result)
})

// Now the fun part, this is the actual feature. This entire 'synchronous' callback is scoped to the user and the location they are having this conversation
jarvis.on('chat.greeting', async (data, session) => {
	// Let's send back a friendly greeting
	session.emit('chat.response', {
		text: `Hey, how are you?`
	})

	// Now this will block until the user responds with a message describing their emotion that another plugin has detected
	const emotion = await session.listen('chat.emotion')
	if (emotion == EMOTION_HAPPY) {
		session.emit('chat.response', {
			text: 'That is great to hear!',
		})
	}
	if (emotion == EMOTION_SAD) {
		session.emit('chat.response', {
			text: 'Oh no, that sucks want to hear a joke?'
		})
		// Wait for them to say the equivalent of 'yes'
		await session.listen('chat.yes')
		session.emit('chat.joke', JokeAPI.get())
	}
})
```

If the user starts another conversation all of this will be cleaned up and disposed of. That way the bot can have a back and forth and detect when you change your mind about what you want and head down another direction.  
