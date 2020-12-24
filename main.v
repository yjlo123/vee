// import lib.util
import lib.evaluator
import lib.lexer
import lib.parser
import lib.values

fn main() {
	program_src := '
fn add(c, b) {
	return c + b
}
fn double(a) {return a * 2}
fn hello()
{
	print("hello")
	print("welcome")
}

print(double(2+(4-1)*3)+1)
print(double(add(add(1, 4+5), 5)))
hello()
'
	tokens := lexer.tokenize(program_src)
	println('===== Tokens =====')
	lexer.pretty_print_tokens(tokens)

	ast := parser.parse(tokens)
	println('====== AST ======')
	parser.pretty_print_ast(ast, '', true)
	println('=================')

	mut env := evaluator.Env{
		vars: map[string]values.Value{}
		funcs: map[string][]parser.AST{}
	}
	evaluator.eval(ast, mut env)
	println('====== ENV ======')
	println(env)
	values.test()
	// util.test()
}
