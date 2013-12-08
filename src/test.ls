{parser, tokenizer, parse} = require \./parser
shuffler                   = require \./shuffler
assert                     = require \assert
mona                       = require \mona-parser
util                       = require \util
A                          = require \./ast

test = (input) ->
	console.log 'P[%s] =', input
	result = shuffler.assignment(parse(input))
	console.log util.inspect(result, depth: null, colors: true)
	result

testP = (rule, input) ->
	console.log 'P.%s[%s] =', rule, input
	result = mona.parse(parser[rule]!, input)
	console.log util.inspect(result, depth: null, colors: true)
	result

testT = (rule, input) ->
	console.log 'T.%s[%s] =', rule, input
	result = mona.parse(tokenizer[rule]!, input)
	console.log util.inspect(result, depth: null, colors: true)
	result

check = (actual, expected) ->
	assert.equal actual.msgs.length, expected.msgs.length
	
	for msg, i in expected.msgs
		actual-msg = actual.msgs[i]

		assert.equal actual-msg.id.constructor, msg.id.constructor
		assert.equal actual-msg.id.data, msg.id.data

		assert.equal actual-msg.args.length, msg.args.length

		for arg, i in msg.args
			actual-arg = actual-msg.args[i]
			check actual-arg, arg

	actual

res = test '2 + 2 == 4'
check res, A.msg-seq([
	A.msg(A.id('2')),
	A.msg(A.id('+')),
	A.msg(A.id('2')),
	A.msg(A.id('==')),
	A.msg(A.id('4'))
])

res = test 'http createServer listen(3000)'
check res, A.msg-seq([
	A.msg(A.id('http')),
	A.msg(A.id('createServer')),
	A.msg(A.id('listen'), [
		A.msg-seq([
			A.msg(A.id('3000'))
		])
	])
])

res = test 'test((a))'
check res, A.msg-seq([
	A.msg(A.id('test'), [
		A.msg-seq([
			A.msg(A.id('apply'), [
				A.msg-seq([
					A.msg(A.id('a'))
				])
			])
		])
	])
])

res = test 'test(a)(b)'
check res, A.msg-seq([
	A.msg(A.id('test'), [
		A.msg-seq([
			A.msg(A.id('a'))
		])
	]),
	A.msg(A.id('apply'), [
		A.msg-seq([
			A.msg(A.id('b'))
		])
	])
])

res = test '"test double" \'test single\''
check res, A.msg-seq([
	A.msg(A.str('test double')),
	A.msg(A.str('test single'))
])

res = test 'you_Should^be*able%to!use/crazy&name`s'
check res, A.msg-seq([
	A.msg(A.id('you_Should^be*able%to!use/crazy&name`s'))
])

res = test '[]("this is the real syntax for arrays and indexes")'
check res, A.msg-seq([
	A.msg(A.id('[]'), [
		A.msg-seq([
			A.msg(A.str('this is the real syntax for arrays and indexes'))
		])
	])
])

res = test 'foo = bar'
check res, A.msg-seq([
	A.msg(A.id('='), [
		A.msg-seq([ A.msg(A.id('foo')) ]),
		A.msg-seq([ A.msg(A.id('bar')) ])
	])
])

res = test 'Foo bar = baz'
check res, A.msg-seq([
	A.msg(A.id('Foo')),
	A.msg(A.id('='), [
		A.msg-seq([ A.msg(A.id('bar')) ]),
		A.msg-seq([ A.msg(A.id('baz')) ])
	])
])

res = test 'foo = bar = baz'
check res, A.msg-seq([
	A.msg(A.id('='), [
		A.msg-seq([ A.msg(A.id('foo')) ]),
		A.msg-seq([
			A.msg(A.id('='), [
				A.msg-seq([ A.msg(A.id('bar')) ]),
				A.msg-seq([ A.msg(A.id('baz')) ])
			])
		])
	])
])

res = test 'Foo a = Bar b = Baz c'
check res, A.msg-seq([
	A.msg(A.id('Foo')),
	A.msg(A.id('='), [
		A.msg-seq([ A.msg(A.id('a')) ]),
		A.msg-seq([
			A.msg(A.id('Bar'))
			A.msg(A.id('='), [
				A.msg-seq([ A.msg(A.id('b')) ]),
				A.msg-seq([
					A.msg(A.id('Baz')),
					A.msg(A.id('c'))
				])
			])
		])
	])
])

res = test '{}(test = "work...")'
check res, A.msg-seq([
	A.msg(A.id('{}'), [
		A.msg-seq([
			A.msg(A.id('='), [
				A.msg-seq([ A.msg(A.id('test')) ]),
				A.msg-seq([
					A.msg(A.str('work...'))
				])
			])
		])
	])
])

res = test '{ arr = ["this is the real syntax for arrays and indexes", test], syntax = :real }'
check res, A.msg-seq([
	A.msg(A.id('{}'), [
		A.msg-seq([
			A.msg(A.id('='), [
				A.msg-seq([ A.msg(A.id('arr')) ]),
				A.msg-seq([
					A.msg(A.id('[]'), [
						A.msg-seq([
							A.msg(A.str('this is the real syntax for arrays and indexes'))
						]),
						A.msg-seq([ A.msg(A.id('test')) ])
					])
				])
			])
		]),
		A.msg-seq([
			A.msg(A.id('='), [
				A.msg-seq([ A.msg(A.id('syntax')) ]),
				A.msg-seq([
					A.msg(A.id('internal:createSymbol'), [
						A.msg-seq([ A.msg(A.id('real')) ])
					])
				])
			])
		])
	])
])

res = test ':test == internal:createSymbol(test)'
check res, A.msg-seq([
	A.msg(A.id('internal:createSymbol'), [
		A.msg-seq([ A.msg(A.id('test')) ])
	]),
	A.msg(A.id('==')),
	A.msg(A.id('internal:createSymbol'), [
		A.msg-seq([ A.msg(A.id('test')) ])
	])
])

res = test '# this is a comment, don\'t evaluate it'
check res, A.msg-seq!

res = test '''
method(test, print('hi')).
#fn test()
#	print('hi')
#end
'''
check res, A.msg-seq([
	# TODO: Implement fn
	A.msg(A.id('method'), [
		A.msg-seq([ A.msg(A.id('test')) ]),
		A.msg-seq([
			A.msg(A.id('print'), [
				A.msg-seq([
					A.msg(A.str('hi'))
				])
			])
		])
	])
])

res = test '''
method(test, print('hi')).
/#fn test()

end#/
'''
check res, A.msg-seq([
	# TODO: Implement fn
	A.msg(A.id('method'), [
		A.msg-seq([ A.msg(A.id('test')) ]),
		A.msg-seq([
			A.msg(A.id('print'), [
				A.msg-seq([
					A.msg(A.str('hi'))
				])
			])
		])
	])
])

res = test '/# /# #/ #/'
check res, A.msg-seq!

res = test '10 px'
check res, A.msg-seq([
	A.msg(A.id('10')),
	A.msg(A.id('px'))
])