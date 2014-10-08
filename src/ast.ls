require! {
	U: \./userdata
	P: \./primitives
	util
}

A = exports

class A.MsgSeq extends U.UserData
	(...@msgs) ~>

	add: (msg) ->
		@msgs.push msg
		this

	inspect: ->
		'{ ' + @msgs.map util.inspect(_) .join(' ') + ' }'

	to-code: ->
		@msgs.map (.to-code!) .join(' ')

	dup: -> new @@ ...@msgs.map (.dup!)

A.msg-seq = MsgSeq

class A.Msg extends U.UserData
	(@id, @args = [], @pos = {chunk: '<runtime>', line: 1, column: 1, char: 1}) ~>

	inspect: ->
		str = util.inspect(@id, colors: true) + '(' + util.inspect(@args, colors: true) + ')'

		if @pos?
			str += " at #{@pos.chunk}:#{@pos.line}:#{@pos.column}"

		str

	to-code: ->
		str = @id.to-code!
		if str == '()'
			str = ''
		if @args.length > 0
			str += '(' + @args.map (.to-code!) .join(', ') + ')'
		str

	dup: -> new @@ @id.dup!, @args.map((.dup!)), {} <<< @pos

A.msg = Msg

class A.Comment extends U.UserData
	(@contents, @multiline = true) ~>

	inspect: ->
		if @multiline
			"/##{@contents}#/"
		else
			"##{@contents}"

	to-code: -> @inspect!