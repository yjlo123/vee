import lib.lexer
import lib.values

fn eval(ast lexer.AST, mut env map[string]string) string {
	if ast.tag == 'operator' && ast.val == '=' {
		env[ast.list[0].val] = eval(ast.list[1], mut env)
		return ''
	} else if ast.tag == 'operator' && ast.val == '+' {
		return eval(ast.list[0], mut env) + eval(ast.list[1], mut env)
	} else if ast.tag == 'name' {
		return ast.val
	}
	return ''
}

fn main() {
// 	tokens := lexer.tokenize('a =12
// b = a + 25 * 3
// a*=2
// b++

// print(b)

// fn my_fun(name, msg) {
// 	println("hello " + name)
// 	println(msg)
// }
// my_fun("yjlo", 123)
// ')
	tokens := lexer.tokenize('a = b + f')
	for _, t in tokens {
		println(t)
	}
	ast := lexer.parse(tokens)
	println(ast)
	println(ast.list[0])
	mut env := map[string]string{}
	eval(ast, mut env)
	println(env)
	
	values.test()
}
