require! {
	Parser: \./parser
	runtime: \./runtime
	interpreter: \./interpreter
	transformer: \./transformer
	util
}

p = new Parser
p.add '''
	/#print("hi")
	print(:'\\'')
	print(foo'hi')#/
	print(hello\\ world)
'''
p.parse!
# console.log util.inspect(p, colors: true, depth: null)
console.log p.seq
console.log p.seq.to-code!

transformed = transformer(p.seq, [transformer.str!])

console.log transformed
console.log transformed.to-code!

# R = runtime!

# console.log interpreter(R, p.seq)