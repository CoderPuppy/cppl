// Generated by LiveScript 1.2.0
(function(){
  var ref$, parser, tokenizer, parse, shuffler, assert, mona, util, A, test, testP, testT, check, res;
  ref$ = require('./parser'), parser = ref$.parser, tokenizer = ref$.tokenizer, parse = ref$.parse;
  shuffler = require('./shuffler');
  assert = require('assert');
  mona = require('mona-parser');
  util = require('util');
  A = require('./ast');
  test = function(input){
    var result;
    console.log('P[%s] =', input);
    result = shuffler.assignment(parse(input));
    console.log(util.inspect(result, {
      depth: null,
      colors: true
    }));
    return result;
  };
  testP = function(rule, input){
    var result;
    console.log('P.%s[%s] =', rule, input);
    result = mona.parse(parser[rule](), input);
    console.log(util.inspect(result, {
      depth: null,
      colors: true
    }));
    return result;
  };
  testT = function(rule, input){
    var result;
    console.log('T.%s[%s] =', rule, input);
    result = mona.parse(tokenizer[rule](), input);
    console.log(util.inspect(result, {
      depth: null,
      colors: true
    }));
    return result;
  };
  check = function(actual, expected){
    var i$, ref$, len$, i, msg, actualMsg, j$, ref1$, len1$, arg, actualArg;
    assert.equal(actual.msgs.length, expected.msgs.length);
    for (i$ = 0, len$ = (ref$ = expected.msgs).length; i$ < len$; ++i$) {
      i = i$;
      msg = ref$[i$];
      actualMsg = actual.msgs[i];
      assert.equal(actualMsg.id.constructor, msg.id.constructor);
      assert.equal(actualMsg.id.data, msg.id.data);
      assert.equal(actualMsg.args.length, msg.args.length);
      for (j$ = 0, len1$ = (ref1$ = msg.args).length; j$ < len1$; ++j$) {
        i = j$;
        arg = ref1$[j$];
        actualArg = actualMsg.args[i];
        check(actualArg, arg);
      }
    }
    return actual;
  };
  res = test('2 + 2 == 4');
  check(res, A.msgSeq([A.msg(A.id('2')), A.msg(A.id('+')), A.msg(A.id('2')), A.msg(A.id('==')), A.msg(A.id('4'))]));
  res = test('http createServer listen(3000)');
  check(res, A.msgSeq([A.msg(A.id('http')), A.msg(A.id('createServer')), A.msg(A.id('listen'), [A.msgSeq([A.msg(A.id('3000'))])])]));
  res = test('test((a))');
  check(res, A.msgSeq([A.msg(A.id('test'), [A.msgSeq([A.msg(A.id('apply'), [A.msgSeq([A.msg(A.id('a'))])])])])]));
  res = test('test(a)(b)');
  check(res, A.msgSeq([A.msg(A.id('test'), [A.msgSeq([A.msg(A.id('a'))])]), A.msg(A.id('apply'), [A.msgSeq([A.msg(A.id('b'))])])]));
  res = test('"test double" \'test single\'');
  check(res, A.msgSeq([A.msg(A.str('test double')), A.msg(A.str('test single'))]));
  res = test('you_Should^be*able%to!use/crazy&name`s');
  check(res, A.msgSeq([A.msg(A.id('you_Should^be*able%to!use/crazy&name`s'))]));
  res = test('[]("this is the real syntax for arrays and indexes")');
  check(res, A.msgSeq([A.msg(A.id('[]'), [A.msgSeq([A.msg(A.str('this is the real syntax for arrays and indexes'))])])]));
  res = test('foo = bar');
  check(res, A.msgSeq([A.msg(A.id('='), [A.msgSeq([A.msg(A.id('foo'))]), A.msgSeq([A.msg(A.id('bar'))])])]));
  res = test('Foo bar = baz');
  check(res, A.msgSeq([A.msg(A.id('Foo')), A.msg(A.id('='), [A.msgSeq([A.msg(A.id('bar'))]), A.msgSeq([A.msg(A.id('baz'))])])]));
  res = test('foo = bar = baz');
  check(res, A.msgSeq([A.msg(A.id('='), [A.msgSeq([A.msg(A.id('foo'))]), A.msgSeq([A.msg(A.id('='), [A.msgSeq([A.msg(A.id('bar'))]), A.msgSeq([A.msg(A.id('baz'))])])])])]));
  res = test('Foo a = Bar b = Baz c');
  check(res, A.msgSeq([A.msg(A.id('Foo')), A.msg(A.id('='), [A.msgSeq([A.msg(A.id('a'))]), A.msgSeq([A.msg(A.id('Bar')), A.msg(A.id('='), [A.msgSeq([A.msg(A.id('b'))]), A.msgSeq([A.msg(A.id('Baz')), A.msg(A.id('c'))])])])])]));
  res = test('{}(test = "work...")');
  check(res, A.msgSeq([A.msg(A.id('{}'), [A.msgSeq([A.msg(A.id('='), [A.msgSeq([A.msg(A.id('test'))]), A.msgSeq([A.msg(A.str('work...'))])])])])]));
  res = test('{ arr = ["this is the real syntax for arrays and indexes", test], syntax = :real }');
  check(res, A.msgSeq([A.msg(A.id('{}'), [A.msgSeq([A.msg(A.id('='), [A.msgSeq([A.msg(A.id('arr'))]), A.msgSeq([A.msg(A.id('[]'), [A.msgSeq([A.msg(A.str('this is the real syntax for arrays and indexes'))]), A.msgSeq([A.msg(A.id('test'))])])])])]), A.msgSeq([A.msg(A.id('='), [A.msgSeq([A.msg(A.id('syntax'))]), A.msgSeq([A.msg(A.id('internal:createSymbol'), [A.msgSeq([A.msg(A.id('real'))])])])])])])]));
  res = test(':test == internal:createSymbol(test)');
  check(res, A.msgSeq([A.msg(A.id('internal:createSymbol'), [A.msgSeq([A.msg(A.id('test'))])]), A.msg(A.id('==')), A.msg(A.id('internal:createSymbol'), [A.msgSeq([A.msg(A.id('test'))])])]));
  res = test('# this is a comment, don\'t evaluate it');
  check(res, A.msgSeq());
  res = test('method(test, print(\'hi\')).\n#fn test()\n#	print(\'hi\')\n#end');
  check(res, A.msgSeq([A.msg(A.id('method'), [A.msgSeq([A.msg(A.id('test'))]), A.msgSeq([A.msg(A.id('print'), [A.msgSeq([A.msg(A.str('hi'))])])])])]));
  res = test('method(test, print(\'hi\')).\n/#fn test()\n\nend#/');
  check(res, A.msgSeq([A.msg(A.id('method'), [A.msgSeq([A.msg(A.id('test'))]), A.msgSeq([A.msg(A.id('print'), [A.msgSeq([A.msg(A.str('hi'))])])])])]));
  res = test('/# /# #/ #/');
  check(res, A.msgSeq());
  res = test('10 px');
  check(res, A.msgSeq([A.msg(A.id('10')), A.msg(A.id('px'))]));
}).call(this);
