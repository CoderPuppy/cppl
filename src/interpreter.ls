require! {
	P: \./primitives
	runtime: \./runtime
}

interpreter = (ground, seq, current = ground) ->
	for msg in seq.msgs
		if msg.id instanceof P.Symbol and msg.id.val == \.
			current = ground
		else
			current = new runtime.Call(ground, current, msg).send!

	current

module.exports = interpreter