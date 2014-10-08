require! {
	A: \../ast
	P: \../primitives
	util
}

transformer = (seq, transformers) ->
	seq .= dup!
	path = [ {obj: seq, arr: seq.msgs, index: 0} ]

	:objs while path.length
		seg = path[path.length - 1]

		if seg.index >= seg.arr.length
			path.pop!
			seg = path[path.length - 1]
			seg?.index += 1
		else
			obj = seg.arr[seg.index]
			if obj instanceof A.Msg
				for transformer in transformers
					transformer(obj, seg, path)

					seg = path[path.length - 1]
					obj = seg.arr[seg.index]

					if obj not instanceof A.Msg
						continue objs

				path.push {obj: obj, arr: obj.args, index: 0}
			else if obj instanceof A.MsgSeq
				path.push {obj: obj, arr: obj.msgs, index: 0}
			else
				throw new Error('what is this? ' + util.inspect(old) + ' in an array')

			# console.log obj

	seq

transformer.str = ->
	(msg, seg, path) ->
		if msg.id instanceof P.Symbol
			id = msg.id.val
			num-strs = 0
			parts = []
			last = 0
			var quote
			var str-start
			var prev

			for char, i in id
				if prev != \\ and (quote == char or (not quote and (char == \' or char == \")))
					if quote?
						num-strs += 1
						last = i + 1
						parts.push id.substring(str-start + 1, i)
						quote = null
						str-start = void
					else
						parts.push id.substring(last, i)
						str-start = i
						quote = char

				prev = char

			parts.push id.substr(last)

			id = parts.join('')

			if parts.length == 2 and num-strs == 1
				msg.id = P.str(id)
			else
				msg.id.val = id

module.exports = transformer