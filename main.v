import lib.lexer
//import lib.values

fn eval(ast lexer.AST, mut env map[string]string) string {
	if ast.tag == 'operator' && ast.val == '=' {
		env[ast.list[0].val] = eval(ast.list[1], mut env)
		return ''
	} else if ast.tag == 'operator' && ast.val == '+' {
		return eval(ast.list[0], mut env) + eval(ast.list[1], mut env)
	} else if ast.tag == 'operator' && ast.val == '*' {
		return eval(ast.list[0], mut env) + '*>' + eval(ast.list[1], mut env)
	} else if ast.tag == 'name' {
		return ast.val
	}
	return ''
}



fn to_post_fix(tokens []lexer.Token) []lexer.Token {
	precedence := {
		'*': 90
		'/': 90
		'+': 50
		'-': 50
		'=': 10
	}
	mut post_tokens := []lexer.Token{}
	mut stack := []lexer.Token{}
	for t in tokens {
		if t.typ == lexer.TokenType.name {
			post_tokens << t
		} else if t.typ == lexer.TokenType.bracket && t.val == '(' {
			stack << t
		} else if t.typ == lexer.TokenType.bracket && t.val == ')' {
			for stack.len > 0 && stack[stack.len-1].val != '(' {
				post_tokens << stack[stack.len-1]
				stack = stack[0..stack.len-1]
			}
			stack = stack[0..stack.len-1]
		} else {
			for stack.len > 0 && precedence[t.val] <= precedence[stack[stack.len-1].val]{
				post_tokens << stack[stack.len-1]
				stack = stack[0..stack.len-1]
			}
			stack << t
		}
	}
	stack_len := stack.len
	for _ in 0..stack_len {
		post_tokens << stack[stack.len-1]
		stack = stack[0..stack.len-1]
	}
	return post_tokens
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
	tokens := lexer.tokenize('a = b + r * y')
	// for _, t in tokens {
	// 	println(t)
	// }
	post_tokens := to_post_fix(tokens)
	// for _, t in post_tokens {
	// 	println(t)
	// }

	ast := lexer.parse(post_tokens)
	println(ast)
	mut env := map[string]string{}
	eval(ast, mut env)
	println(env)
	
	//values.test()
}
