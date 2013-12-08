A = require \./ast

# a = b => =(a, b) == b
# Foo bar = baz => Foo =(bar, baz) == baz
# foo = bar = baz => =(foo, =(bar, baz)) == baz
shuffle-assignment = (seq) ->
	new-seq = []
	stack = [ new-seq ]
	current = -> stack[stack.length - 1]
	for msg in seq.msgs
		new-msg = A.msg(msg.id, [])

		if msg.id.data == '=' and msg.args.length == 0
			throw new Error('Assignment cannot be the first message') unless current!.length?
			new-msg.args[0] = A.msg-seq([ current!.pop! ])
			new-msg.args[1] = A.msg-seq!
			current!.push new-msg
			stack.push new-msg.args[1].msgs
		else if msg.id.data == '.' and msg.args.length == 0
			stack.pop!
		else
			new-msg.args = msg.args.map(shuffle-assignment)
			current!.push new-msg

	A.msg-seq new-seq

exports.assignment = shuffle-assignment