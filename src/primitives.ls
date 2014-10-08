require! {
	U: \./userdata
	util
}

P = exports

class P.Symbol extends U.UserData
	(@val) ~>

	id: -> ':' + @val

	inspect: -> ":#{util.inspect(@val, colors: true)}"

	to-code: -> @val

	dup: -> new @@(@val)

P.symbol = P.Symbol
P.sym = P.Symbol

class P.String extends U.UserData
	(@val) ~>

	id: -> 's' + @val

	inspect: -> util.inspect(@val, colors: true)

	to-code: -> JSON.serialize(@val)

P.string = P.String
P.str = P.String