conditions = exports

handlers = []

conditions.catch = (handler, blk) ->
	try
		blk!
	catch e
		if e instanceof conditions.ConditionError
			handler e.condition
		else
			throw e

conditions.handle = (handler, blk) ->
	handlers.push handler
	blk!
	handlers.pop!

class conditions.StackFrame
	(@seq, @msg) ~>

	dup: -> new @@(@seq.dup!, @msg.dup!)

class conditions.Stack
	(...@frames) ~>

	dup: -> new @@(...[].concat(@frames))

conditions.stack = new conditions.Stack

class conditions.ConditionError extends Error
	(@condition) ~>