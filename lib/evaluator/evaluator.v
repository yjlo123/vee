module evaluator

import lib.parser

pub struct Env {
mut:
	vars map[string]string
	funcs map[string][]parser.AST
}

pub fn eval(ast parser.AST, mut env Env) string {
	if ast.tag == 'stmt_list' {
		for i, stmt in ast.list {
			if stmt.tag == 'return' || i == ast.list.len-1 {
				return eval(stmt, mut env)
			} else {
				eval(stmt, mut env)
			}
		}
	} else if ast.tag == 'operator' {
		if ast.val == '=' {
			env.vars[ast.list[0].val] = eval(ast.list[1], mut env)
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
		return env.vars[ast.val]
	} else if ast.tag == 'number' || ast.tag == 'string' {
		return ast.val
	} else if ast.tag == 'call' {
		if ast.val == 'print' {
			mut res := ''
			for v in ast.list[0].list {
				res += eval(v, mut env) + ' '
			}
			println(res)
		} else if ast.val in env.funcs {
			for i, p in env.funcs[ast.val][0].list {
				env.vars[p.val] = eval(ast.list[0].list[i], mut env)
			}
			return eval(env.funcs[ast.val][1], mut env)
		}
	} else if ast.tag == 'func' {
		env.funcs[ast.val] = ast.list
	} else if ast.tag == 'return' {
		return eval(ast.list[0], mut env)
	}
	return ''
}
