import lib.evaluator
import lib.lexer
import lib.parser

// import lib.util
import lib.values
fn main() {
	tokens := lexer.tokenize('
fn add(c, b) {
	return c + b
}
fn double(a) {
	return a * 2
}
fn hello() {
	print("hello")
}

print(double(2+(4-1)*3)+1)
print(double(add(add(1, 4+5), 5)))
hello()
')
	println('===== Tokens =====')
	mut lc := 0
	print('$lc ')
	for t in tokens {
		mut newline := ' '
		if t.typ == lexer.TokenType.newline {
			lc++
			newline = '\n$lc '
		}
		print(t)
		print(newline)
	}
	println('')

	ast := parser.parse(tokens)
	println('====== AST ======')
	println(ast)
	println('=================')
	mut env := evaluator.Env{
		vars: map[string]string{}
		funcs: map[string][]parser.AST{}
	}
	evaluator.eval(ast, mut env)
	println(env)
	values.test()
	// util.test()
}
