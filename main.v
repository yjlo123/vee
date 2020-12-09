// import lib.util
import lib.evaluator
import lib.lexer
import lib.parser
import lib.values

fn print_ast(ast parser.AST, indent string, last bool) {
	head := if last { '└' } else { '├' }
	println('$indent${head}($ast.tag) $ast.val')
	child_head := if last { ' ' } else { '│' }
	if ast.list.len > 0 {
		for i, l in ast.list {
			print_ast(l, indent + '$child_head   ', i == ast.list.len - 1)
		}
	}
}

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
	print("welcome")
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
	print_ast(ast, '', true)
	println('=================')
	mut env := evaluator.Env{
		vars: map[string]values.Value{}
		funcs: map[string][]parser.AST{}
	}
	evaluator.eval(ast, mut env)
	println(env)
	// values.test()
	// util.test()
}
