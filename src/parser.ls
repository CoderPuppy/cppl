require! {
	A: \./ast
	P: \./primitives
	util
}

class Parser
	(chunk-name = '<runtime>') ~>
		@str = ''
		@seq = new A.MsgSeq
		@path = [@seq]
		@current = @seq
		@prev = ''
		@pos = {
			char: 1
			column: 1
			line: 1
			chunk: chunk-name
		}

	add: (str) ->
		@str += str

	_last-of: (kind, barrier) ->
		for i from @path.length - 1 to 0 by -1
			if @path[i] == barrier or (typeof(barrier) == \function and @path[i] instanceof barrier)
				break

			if @path[i] == kind or (typeof(kind) == \function and @path[i] instanceof kind)
				return @path[i]

	_push: (o) ->
		@path.push o
		@current = o
		o

	_pop-to-last-of: (kind) ->
		for i from @path.length - 1 to 0 by -1
			if @path[i] == kind or (typeof(kind) == \function and @path[i] instanceof kind)
				return @path[i]

			@_pop!

	_pop: ->
		@path.pop!
		@current = @path[@path.length - 1]

	_pull-char: ->
		@pos.char += 1
		@pos.column += 1

		if @str[0] == '\n' or @str[0] == '\r'
			@pos.column = 0
			@pos.line += 1

		@prev = @str[0] # + @prev # Re-enable if neccessary

		@str .= substr(1)

	_reprocess-char: ->
		@str = ' ' + @str
		@pos.char -= 1
		@pos.column -= 1

	parse: ->
		while @str.length > 0
			# Comments
			if @current instanceof A.Comment
				if @current.multiline and @str.substr(0, 2) == '#/'
					@_pull-char!
					@_pop!
				else if not @current.multiline and (@str[0] == '\n' or @str[0] == '\r')
					@_pop!
				else
					@current.contents += @str[0]

			else if @str[0] == '#'
				@_push A.Comment('', false)

			else if @str.substr(0, 2) == '/#'
				@_push A.Comment('')
				@_pull-char!

			# Arguments
			else if Array.isArray(@current)
				@_reprocess-char!
				seq = A.msg-seq!
				@current.push seq
				@_push(seq)

			# Symbol
			else if (@current instanceof P.Symbol or @current instanceof A.MsgSeq) and @_last-of(A.MsgSeq)? and (@prev[0] == \\ or @str-quote == @str[0] or @str-quote? or not /^[ \t\n\r\(\)\[\]]/.test(@str[0]))
				if @current not instanceof P.Symbol
					id = P.sym('')
					msg = A.msg(id, [], {} <<< @pos)
					@_push(msg)
					@_push(id)
					@_last-of(A.MsgSeq).add(msg)

				@current.val += @str[0]

				if @str-quote == @str[0] and @prev[0] != \\
					delete! @str-quote
				else if @str[0] == \" or @str[0] == \'
					@str-quote = @str[0]

			# Message Seperators
			else if (@str[0] == ' ' or @str[0] == '\t') and @_last-of(A.MsgSeq)?
				@_pop-to-last-of A.MsgSeq

			# Arguments
			else if @str[0] == '(' and @_last-of(A.Msg)?
				@_push @_pop-to-last-of(A.Msg).args

			else if @str[0] == '(' and @_last-of(A.MsgSeq)?
				msg = A.msg(P.sym('()'), [], {} <<< @pos)
				@_last-of(A.MsgSeq).add(msg)
				@_push @_push(msg).args

			else if @str[0] == ')' and @_last-of(Array)?
				@_pop-to-last-of(Array)
				@_pop!
				@_pop!

			else if @str[0] == ',' and @_last-of(Array)?
				@_pop-to-last-of(Array)

			# Newline
			else if (@str[0] == '\n' or @str[0] == '\r') and @current instanceof A.MsgSeq
				@current.add(A.msg(P.sym(\.), [], {} <<< @pos))

			else
				throw new Error("Unexpected '#{@str[0]}' at line #{@pos.line}, column #{@pos.column} (char #{@pos.char})")

			@_pull-char!

module.exports = Parser