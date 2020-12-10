module parser

import lib.lexer
import lib.util

pub fn parse(tokens []lexer.Token) AST {
	// println('Token:$tokens')
	mut stmt_list := []AST{}
	mut line_start := 0
	for i := 0; i < tokens.len; i++ {
		token := tokens[i]
		if token.typ == lexer.TokenType.func {
			// === Func Denifination ===
			mut func_detail := []AST{} // params, body
			func_name := tokens[i + 1].val
			if !is_open_parenthesis_token(tokens[i + 2]) {
				println('ERROR: expect `(`')
			}
			i += 2 // func_name (
			param_start := i + 1
			for i < tokens.len && !is_close_parenthesis_token(tokens[i]) {
				i++
			}
			mut func_params := AST{}
			if tokens[param_start..i].len > 0 {
				// println('func_params=${tokens[param_start..i]}')
				func_params = parse(tokens[param_start..i]).list[0]
				mut params := []AST{}
				params << func_params
				if func_params.tag != 'param_list' {
					func_params = new_ast('param_list', '', params)
				}
				// println('func_paramsP=$func_params')
			}
			i++ // )
			for is_newline(tokens[i]) {
				i++
			}
			if !is_open_brace_token(tokens[i]) {
				println('ERROR: expect `{`')
			}
			i++ // {
			for is_newline(tokens[i]) {
				i++
			}
			body_start := i
			mut brace_count := 1
			for i < tokens.len {
				if is_open_brace_token(tokens[i]) {
					brace_count++
				} else if is_close_brace_token(tokens[i]) {
					brace_count--
					if brace_count == 0 {
						break
					}
				}
				i++
			}
			if brace_count != 0 {
				println('ERROR: missing closing brace')
			}
			// TODO add newline or eof to the end of func body
			// println(tokens[body_start..i])
			func_body := parse(tokens[body_start..i])
			func_detail << func_params
			func_detail << func_body
			stmt_list << new_ast('func', func_name, func_detail)
			i++ // }
			line_start = i + 1
		} else if token.typ == lexer.TokenType.ret {
			// === Func Return ===
			i++ // keyword(return)
			return_val_start := i
			for i < tokens.len && !is_newline(tokens[i]) && !is_close_brace_token(tokens[i]) {
				// TODO check end of expression
				i++
			}
			mut return_val := []AST{}
			// TODO check return nothing
			return_val << parse(tokens[return_val_start..i]).list[0] // since parse returns a stmt_list
			stmt_list << new_ast('return', '', return_val)
		} else if is_newline(token) || is_eof(token) || i == tokens.len - 1 {
			// === Expression ===
			// TODO check the end of an expression
			// if i == tokens.len - 1 {
			// println('line:${tokens[line_start..i+1]}')
			// } else {
			// println('line:${tokens[line_start..i]}')
			// }
			if tokens[line_start..i].len == 1 && is_newline(tokens[line_start..i][0]) {
				// empty line
				continue
			}
			mut post_tokens := to_postfix(tokens[line_start..i])
			if i == tokens.len - 1 && !is_eof(token) && !is_newline(token) {
				post_tokens = to_postfix(tokens[line_start..i + 1])
			} else if line_start == i {
				continue
			}
			// println('line-post:${post_tokens}')
			mut stack := []AST{} // operands
			for j := 0; j < post_tokens.len; j++ {
				// println('stack:$stack')
				t := post_tokens[j]
				if t.typ == lexer.TokenType.name {
					if stack.len > 0 && is_close_parenthesis_ast(stack[stack.len - 1]) {
						// func call
						mut func_params := []AST{}
						if is_open_parenthesis_ast(stack[stack.len - 2]) {
							// empty param list
							func_params << new_ast('param_list', '', []AST{})
							stack = stack[0..stack.len - 2] // remove ( )
						} else if stack[stack.len - 2].tag == 'param_list' {
							// multiple params
							func_params << stack[stack.len - 2]
							stack = stack[0..stack.len - 3] // remove ( pl )
						} else {
							// single param
							mut param_list := []AST{}
							param_list << stack[stack.len - 2]
							func_params << new_ast('param_list', '', param_list)
							stack = stack[0..stack.len - 3] // remove ( p )
						}
						stack << new_ast('call', t.val, func_params)
					} else {
						// var name
						stack << new_ast('name', t.val, []AST{})
					}
				} else if t.typ == lexer.TokenType.number {
					stack << new_ast('number', t.val, []AST{})
				} else if t.typ == lexer.TokenType.string {
					stack << new_ast('string', t.val, []AST{})
				} else if t.typ == lexer.TokenType.operator {
					if t.val == ',' {
						if stack.len > 1 && !is_param_list(stack[stack.len - 2]) {
							mut operands := []AST{}
							operands << stack[stack.len - 2..stack.len]
							stack = stack[0..stack.len - 2]
							stack << new_ast('param_list', '', operands)
						} else {
							mut current_list := stack[stack.len - 2]
							current_list.list << stack[stack.len - 1]
							stack = stack[0..stack.len - 2]
							stack << current_list
						}
					} else {
						// TODO, decide num of operands
						mut operands := []AST{}
						operands << stack[stack.len - 2..stack.len]
						stack = stack[0..stack.len - 2]
						stack << new_ast('operator', t.val, operands)
					}
				} else if is_parenthesis_token(t) {
					stack << new_ast('bracket', t.val, []AST{})
				}
			}
			stmt_list << stack[0]
			line_start = i + 1
		}
	}
	ast := new_ast('stmt_list', '', stmt_list)
	// println('Ast:$ast')
	return ast
}

fn to_postfix(tokens []lexer.Token) []lexer.Token {
	// println('>To_post_fix:$tokens')
	precedence := {
		'*': 90
		'/': 90
		'+': 50
		'-': 50
		',': 15
		'=': 10
		'(': 0
	}
	mut post_tokens := []lexer.Token{}
	mut stack := util.Stack{}
	for i := 0; i < tokens.len; i++ {
		t := tokens[i] // CAUTION: do not assign t to anyone
		if t.typ == lexer.TokenType.name || t.typ == lexer.TokenType.number {
			post_tokens << tokens[i]
		} else if is_open_parenthesis_token(t) {
			if post_tokens.len > 0 && post_tokens[post_tokens.len - 1].typ == lexer.TokenType.name {
				// func call
				func_name := post_tokens[post_tokens.len - 1]
				post_tokens = post_tokens[0..post_tokens.len - 1]
				post_tokens << tokens[i] // (
				i++
				mut param_tokens := []lexer.Token{}
				mut bracket_stack := 1
				for i < tokens.len {
					if is_close_parenthesis_token(tokens[i]) {
						bracket_stack--
					} else if is_open_parenthesis_token(tokens[i]) {
						bracket_stack++
					}
					if bracket_stack == 0 {
						break
					}
					param_tokens << tokens[i]
					i++
				}
				param_post := to_postfix(param_tokens)
				post_tokens << param_post
				post_tokens << tokens[i] // )
				post_tokens << func_name
			} else {
				stack.push(tokens[i])
			}
		} else if is_close_parenthesis_token(t) { // )
			for stack.len() > 0 {
				top := &lexer.Token(stack.peek())
				if is_open_parenthesis_token(top) {
					break
				}
				post_tokens << &lexer.Token(stack.pop())
			}
			stack.pop() // (
		} else {
			for stack.len() > 0 {
				top := &lexer.Token(stack.peek())
				if precedence[t.val] > precedence[top.val] {
					break
				}
				post_tokens << &lexer.Token(stack.pop())
			}
			stack.push(tokens[i])
		}
	}
	stack_len := stack.len()
	for _ in 0 .. stack_len {
		post_tokens << &lexer.Token(stack.pop())
	}
	// println('<post tokens:$post_tokens')
	return post_tokens
}
