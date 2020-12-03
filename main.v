import lib.evaluator
import lib.lexer
import lib.parser

// import lib.util
// import lib.values

fn main() {
	tokens := lexer.tokenize('a = 8 - (2 + 3) * 9
b = a + 5
print(1+2, a, b*2)
print(b)
fn hello(a) {
	var = 12 + 4
	print(a)
}')
	ast := parser.parse(tokens)
	println('====== AST ======')
	println(ast)
	println('=================')
	mut env := map[string]string{}
	evaluator.eval(ast, mut env)
	// println(env)
	// values.test()
	// util.test()
}
