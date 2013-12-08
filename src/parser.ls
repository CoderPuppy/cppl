M = require \mona-parser

# Utils
U =
	joined: (joiner, part) ->
		M.sequence (s) ->
			first = s part
			rest = s M.collect(M.and(joiner, part))
			M.value [first].concat(rest)

A = require \./ast

# Tokenizer
T =
	id: -> M.label M.bind(
		# special case {} and [] so they can be sent directly
		M.or(M.string('{}'), M.string('[]'),
			M.string-of(
				M.collect(M.none-of([ \., \,, ' ', \", \', \(, \), \[, \], \{, \}, '\n', '\r', '\t', \# ]), min: 1)
			)
		), -> M.value(A.id(it))
	), 'identifier'
	sep: -> M.label M.bind(T.i!, -> if it.length > 0 then M.value(it) else M.fail('expected seperator')), 'seperator'
	ws: -> M.label M.collect(M.or(M.string(' '), M.string('\t'), M.string('\n'), M.string('\r'))), 'whitespace'
	i: -> M.label M.or(M.string-of(M.collect(M.between(T.ws!, T.ws!, T.comment!), min: 1)), T.ws!), 'ignored'
	comment: -> M.or(T.line-comment!, T.block-comment!)
	line-comment: ->
		M.label M.sequence((s) ->
			str = ''
			str += s M.string(\#)
			str += s M.string-of(M.collect(M.none-of(['\n', '\r'])))
			str += s M.or(M.collect(M.or(M.string('\n'), M.string('\r')), min: 1, max: 2), M.eof!)
			M.value(str)
		), 'line comment'
	block-comment: -> M.label M.sequence((s) ->
		str = ''
		str += s M.string('/#')
		str += s M.string-of(M.collect(M.or(M.none-of([ '/#', '#/' ]), T.block-comment!)))
		str += s M.string('#/')
		M.value str
	), 'block comment'
	string: -> M.label M.sequence((s) ->
		quote = s M.or(M.string(\"), M.string(\'))
		contents = s M.string-of(M.collect(M.or(M.string("\\#{quote}"), M.none-of([ quote ]))))
		s M.string(quote)
		M.value(A.str(contents))
	), 'string'

# Parser
P =
	start: ->
		M.between(
			T.i!,
			T.i!,
			M.or(P.message-seq!, M.value(A.msg-seq!))
		)

	message-seq: -> M.label M.sequence((s) ->
		first = s P.message!
		rest = s M.collect(P.rest-message!)
		M.value(A.msg-seq([first].concat(rest)))
	), 'message sequence'

	rest-message: -> M.label M.or(M.and(T.sep!, P.message!), P.reset-message!, P.apply-message!), 'rest message'

	reset-message: -> M.label M.bind(
		M.string(\.),
		-> M.value(A.msg(A.id(\.)))
	), 'reset message'
	apply-message: -> M.label M.bind(
		P.args(true),
		-> M.value(A.msg(A.id(\apply), it))
	), 'apply message'

	message: -> M.label M.or(P.sugar!, P.reset-message!, P.apply-message!, M.sequence((s) ->
		id = s M.or(T.id!, T.string!)
		args = s P.args!
		M.value A.msg(id, args)
	)), 'message'

	sugar: -> M.or(P.symbol!, P.array!, P.map!)
	symbol: ->
		M.label M.bind(
			M.and(M.string(\:), T.id!),
			->
				M.value(A.msg(A.id(\internal:createSymbol), [A.msg-seq([A.msg(it)])]))
		), 'symbol'
	array: -> M.label M.unless(M.string('[]'), M.bind(
		M.between(M.and(M.string(\[), T.i!), M.and(T.i!, M.string(\])), M.delay(P.message-list)),
		-> M.value(A.msg(A.id('[]'), it))
	)), 'array'
	map: -> M.label M.unless(M.string('{}'), M.bind(
		M.between(M.and(M.string(\{), T.i!), M.and(T.i!, M.string(\})), M.delay(P.message-list)), -> M.value(A.msg(A.id('{}'), it))
	)), 'map'

	args: (needed = false) ->
		parser = M.between(M.string(\(), M.string(\)), P.message-list!)
		if needed
			parser
		else
			M.or(parser, M.value([]))

	message-list: -> M.or(U.joined(M.and(M.string(\,), T.i!), P.message-seq!), M.and(T.i!, M.value([])))

# Unnessecary
# # Keyword args
# M.sequence((s) ->
# 	key = s T.id!
# 	s T.i!
# 	s M.string(\:)
# 	s T.i!
# 	val = s P.message-seq!
# 	M.value(A.kv(key, val))
# )

exports.parser = P
exports.tokenizer = T

parse = (txt) -> M.parse(P.start!, txt)

exports.parse = parse