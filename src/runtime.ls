require! {
	A: \./ast
	P: \./primitives
	U: \./userdata
	hat
}

runtime = ->
	R = new runtime.Object

	R.set-cell P.sym(\runtime), R

	do
		R.NativeFunction = new runtime.Object
		proto = new runtime.Object



		R.NativeFunction.set-cell P.sym(\proto), proto
		R.set-cell P.sym(\NativeFunction), R.NativeFunction

	R.Base = new runtime.Object
	R.Base.set-cell P.sym(\runtime), R
	R.set-cell P.sym(\Base), R.Base

	do
		R.nil = R.Base.derivative!

		to-str-fn = R.NativeFunction.send(\proto).derivative!
		to-str-fn.userdata = new runtime.NativeFunction (call) ->
			str = R.send(\create-str)
			str.userdata = P.str(\nil)
			str

		R.set-cell P.sym(\nil), R.nil

	R.Mixin = R.Base.derivative!
	R.set-cell P.sym(\Mixin), R.Mixin

	R.DefaultBehaviour = R.Mixin.derivative!

	do
		R.Kind = new runtime.Object
		proto = new runtime.Object

		new-fn = R.NativeFunction.send(\proto).derivative!
		new-fn.userdata = new runtime.NativeFunction (call) ->

		proto.set-cell P.sym(\new), new-fn

		extend-fn = R.NativeFunction.send(\proto).derivative!
		extend-fn.userdata = new runtime.NativeFunction (call) ->

		proto.set-cell P.sym(\extend), extend-fn

		R.Kind.set-cell P.sym(\proto), proto
		R.Kind.derive-from proto

	do
		R.Something = R.Kind.send(\new)

		R.Kind.cell(P.sym(\proto)).send(\extend, R.Something)

	R

base-receive-fn = (call) ->
	self = call.receiver
	msg = call.msg
	args = msg.args
	
	console.log msg

	val = self.cell(msg.id)

	if val?
		val
	else
		# console.log self
		# throw new Error('')
		self.send(\runtime).send(\nil)

class runtime.Object extends U.UserData
	~>
		@cells = {}
		@srcs = []
		@_id = hat!

	id: ->
		if @userdata?
			@userdata.id!
		else
			@_id

	to-string: ->
		if @userdata?
			@userdata.to-string!
		else
			@send(\to-string).to-string!

	wrap-fn: ->
		(...args) ->
			@send '()', ...args

	derive-from: (src) ->
		if @srcs.index-of(src) == -1
			@srcs.push(src)
			this
		else
			throw new Error('Already derived from: ' + src)

	derivative: ->
		o = new @@
		o.derive-from @
		o

	set-cell: (u, o) ->
		if u not instanceof U.UserData
			throw new Error('Key must be a userdata')

		if o not instanceof runtime.Object
			throw new Error('Val must be an object')

		@cells[u.id!] = o
		this

	cell: (u) ->
		val = @cells[u.id!]
		if val?
			val
		else
			for src in @srcs
				val = src.cell(u)
				if val?
					return val

			# @send(\runtime).send(\nil)

	send: (id, ...args) ->
		runtime.Call.from-args(this, id, ...args).send!

	receive: (call) ->
		if @metafn?
			call-obj = @metafn.send(\runtime).send(\create-call)
			call-obj.userdata = call
			@metafn.send('()', call-obj)
		else
			base-receive-fn(call)

class runtime.Call extends U.UserData
	(@ground, @receiver, @msg, @seq = A.msg-seq(@msg)) ~>

	send: -> @receiver.receive this

	@from-args = (receiver, id, ...args) ->
		ground = new runtime.Object

		for arg, i in args
			ground.set-cell P.sym("--runtime.Call::from-args/ground/#{i}"), arg

		new @@(ground, receiver,
			A.msg(
				P.sym(id),
				args.map (_, i) ->
					A.msg(P.sym("--runtime.Call::from-args/ground/#{i}"))
			)
		)

class runtime.NativeFunction extends U.UserData
	(@fn) ~>

module.exports = runtime