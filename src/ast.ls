util = require \util

# AST
A =
	# msg: (id, args) -> [ \msg, id, args ]
	# id: (id) -> [ \id, id ]
	# str: (str) -> [ \str, str ]
	msg-seq: (msgs) -> new A.MessageSeq(msgs)
	msg: (id, args) -> new A.Message(id, args)
	str: (str) -> new A.String(str)
	id: (id) -> new A.ID(id)
	kv: (key, value) -> new A.KeyValue(key, value)

class A.MessageSeq
	(@msgs = []) -> throw new Error('Non-array messages') unless @msgs instanceof Array
	inspect: ->
		"{ #{@msgs.map(-> util.inspect(it)).join(' ')} }"

class A.Message
	(@id, @args = []) ->
	inspect: ->
		str = "#{util.inspect(@id)}"
		if @args.length > 0
			str += "(#{@args.map(-> util.inspect(it)).join(', ')})"
		str

class A.ID
	(@data) ->
	inspect: -> @data

class A.String
	(@data) ->
	inspect: -> util.inspect(@data)

class A.KeyValue
	(@key, @value) ->
	inspect: -> "#{util.inspect(@key)} = #{util.inspect(@value)}"

module.exports = A