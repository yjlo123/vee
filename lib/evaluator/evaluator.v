module evaluator

import lib.parser
import lib.values

pub struct Env {
mut:
	vars  map[string]values.Value
	funcs map[string][]parser.AST
}

const (
	nil = values.Value(values.Nil{})
)

pub fn eval(ast parser.AST, mut env Env) values.Value {
	if ast.tag == 'stmt_list' {
		for i, stmt in ast.list {
			if stmt.tag == 'return' || i == ast.list.len - 1 {
				return eval(stmt, mut env)
			} else {
				eval(stmt, mut env)
			}
		}
	} else if ast.tag == 'operator' {
		if ast.val == '=' {
			env.vars[ast.list[0].val] = eval(ast.list[1], mut env)
			return nil
		}
		left := eval(ast.list[0], mut env)
		left_val := left as values.Integer
		right := eval(ast.list[1], mut env)
		right_val := right as values.Integer
		if ast.val == '+' {
			return values.new_integer(left_val.val + right_val.val)
		} else if ast.val == '-' {
			return values.new_integer(left_val.val - right_val.val)
		} else if ast.val == '*' {
			return values.new_integer(left_val.val * right_val.val)
		} else if ast.val == '/' {
			return values.new_integer(left_val.val / right_val.val)
		}
	} else if ast.tag == 'name' {
		return env.vars[ast.val]
	} else if ast.tag == 'number' {
		return values.new_integer(ast.val.int())
	} else if ast.tag == 'string' {
		return values.new_string(ast.val)
	} else if ast.tag == 'call' {
		if ast.val == 'print' {
			mut res := ''
			for v in ast.list[0].list {
				arg_val := eval(v, mut env)
				res += '$arg_val.to_val_string() '
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
	return nil
}
