module evaluator

import lib.parser

pub fn eval(ast parser.AST, mut env map[string]string) string {
	if ast.tag == 'stmt_list' {
		for stmt in ast.list {
			eval(stmt, mut env)
		}
	} else if ast.tag == 'operator' {
		if ast.val == '=' {
			env[ast.list[0].val] = eval(ast.list[1], mut env)
			return ''
		}
		left := eval(ast.list[0], mut env)
		right := eval(ast.list[1], mut env)
		if ast.val == '+' {
			return '${left.int() + right.int()}'
		} else if ast.val == '-' {
			return '${left.int() - right.int()}'
		} else if ast.val == '*' {
			return '${left.int() * right.int()}'
		} else if ast.val == '/' {
			return '${left.int() / right.int()}'
		}
	} else if ast.tag == 'name' {
		return env[ast.val]
	} else if ast.tag == 'number' {
		return ast.val
	} else if ast.tag == 'call' && ast.val == 'print' {
		mut res := ''
		for v in ast.list[0].list {
			res += eval(v, mut env) + ' '
		}
		println(res)
		return ''
	}
	return ''
}
