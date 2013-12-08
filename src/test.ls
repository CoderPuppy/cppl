{parser, tokenizer, parse} = require \./parser
shuffler                   = require \./shuffler
mona                       = require \mona-parser
util                       = require \util

test = (input) ->
	console.log 'P[%s] =', input
	console.log util.inspect(shuffler.assignment(parse(input)), depth: null, colors: true)

testP = (rule, input) ->
	console.log 'P.%s[%s] =', rule, input
	console.log util.inspect(mona.parse(parser[rule]!, input), depth: null, colors: true)

testT = (rule, input) ->
	console.log 'T.%s[%s] =', rule, input
	console.log util.inspect(mona.parse(tokenizer[rule]!, input), depth: null, colors: true)

# test '2 + 2 == 4'
# test 'http createServer listen(3000)'
# test 'test((a))'
# test 'test(a)(b)'
# test '"test double" \'test single\''
# test 'you_Should^be*able%to!use#crazy&name`s'
# test '[]("this is the real syntax for arrays and indexes")'
test 'foo = bar'
test 'Foo bar = baz'
test 'foo = bar = baz'
test 'Foo a = Bar b = Baz c'
test '{}(test = "work...")'
test '{ arr = ["this is the real syntax for arrays and indexes", test], syntax = :real }'
# test ':test == internal:createSymbol(test)'
# test '# this is a comment, don\'t evaluate it'
# test '''
# method(test, print('hi')).
# #fn test()
# #
# #end
# '''
# test '''
# method(test, print('hi')).
# /#fn test()

# end#/
# '''
# test '/# /# #/ #/'
# test '10 px'