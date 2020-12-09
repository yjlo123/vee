module parser

import lib.lexer
import lib.util

struct AST {
pub mut:
	tag  string
	val  string
	list []AST
}

fn (ast AST) str() string {
	mut list_content := ''
	for i, n in ast.list {
		if i > 0 {
			list_content += ' '
		}
		list_content += '$n'
	}
	if list_content.len > 0 {
		return '${ast.tag}($ast.val)[$list_content]'
	} else {
		return '${ast.tag}($ast.val)'
	}
}

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
			if tokens[i + 2].val != '(' {
				println('ERROR: expect `(`')
			}
			i += 2 // func_name (
			param_start := i + 1
			for i < tokens.len && tokens[i].val != ')' {
				i++
			}
			mut func_params := AST{}
			if tokens[param_start..i].len > 0 {
				// println('func_params=${tokens[param_start..i]}')
				func_params = parse(tokens[param_start..i]).list[0]
				mut params := []AST{}
				params << func_params
				if func_params.tag != 'param_list' {
					func_params = AST{
						tag: 'param_list'
						val: ''
						list: params
					}
				}
				// println('func_paramsP=$func_params')
			}
			i++ // )
			if tokens[i].val != '{' {
				println('ERROR: expect `{`')
			}
			i++ // {
			for tokens[i].typ == lexer.TokenType.newline {
				// skip new line
				i++
			}
			body_start := i
			for i < tokens.len && tokens[i].val != '}' {
				i++
			}
			end_of_func_body := i
			// TODO add newline or eof to the end of func body
			// println(tokens[body_start..i])
			func_body := parse(tokens[body_start..i])
			// func_detail << if func_params.len > 0 {
			// func_params.list[0]
			// } else {
			// func_params.list
			// }
			func_detail << func_params
			func_detail << func_body
			stmt_list << AST{
				tag: 'func'
				val: func_name
				list: func_detail
			}
			i = end_of_func_body + 1 // }
			line_start = i + 1
		} else if token.typ == lexer.TokenType.ret {
			// === Func Return ===
			i++ // keyword(return)
			return_val_start := i
			for i < tokens.len && tokens[i].typ != lexer.TokenType.newline {
				i++
			}
			mut return_val := []AST{}
			// TODO check return nothing
			return_val << parse(tokens[return_val_start..i]).list[0] // since parse returns a stmt_list
			stmt_list << AST{
				tag: 'return'
				val: ''
				list: return_val
			}
		} else if token.typ == lexer.TokenType.newline ||
			token.typ == lexer.TokenType.eof || i == tokens.len - 1 {
			// === Expression ===
			// TODO check the end of an expression
			// if i == tokens.len - 1 {
			// println('line:${tokens[line_start..i+1]}')
			// } else {
			// println('line:${tokens[line_start..i]}')
			// }
			if tokens[line_start..i].len == 1 &&
				tokens[line_start..i][0].typ == lexer.TokenType.newline {
				// empty line
				continue
			}
			mut post_tokens := to_postfix(tokens[line_start..i])
			if i == tokens.len - 1 &&
				token.typ != lexer.TokenType.eof && token.typ != lexer.TokenType.newline {
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
					if stack.len > 0 &&
						stack[stack.len - 1].tag == 'bracket' && stack[stack.len - 1].val == ')' {
						// func call
						mut func_params := []AST{}
						if stack[stack.len - 2].tag == 'bracket' && stack[stack.len - 2].val == '(' {
							// empty param list
							func_params << AST{
								tag: 'param_list'
								val: ''
								list: []AST{}
							}
							stack = stack[0..stack.len - 2] // remove ( )
						} else if stack[stack.len - 2].tag == 'param_list' {
							// multiple params
							func_params << stack[stack.len - 2]
							stack = stack[0..stack.len - 3] // remove ( pl )
						} else {
							// single param
							mut param_list := []AST{}
							param_list << stack[stack.len - 2]
							func_params << AST{
								tag: 'param_list'
								val: ''
								list: param_list
							}
							stack = stack[0..stack.len - 3] // remove ( p )
						}
						stack << AST{
							tag: 'call'
							val: t.val
							list: func_params
						}
					} else {
						// var name
						stack << AST{
							tag: 'name'
							val: t.val
							list: []AST{}
						}
					}
				} else if t.typ == lexer.TokenType.number {
					stack << AST{
						tag: 'number'
						val: t.val
						list: []AST{}
					}
				} else if t.typ == lexer.TokenType.string {
					stack << AST{
						tag: 'string'
						val: t.val
						list: []AST{}
					}
				} else if t.typ == lexer.TokenType.operator {
					if t.val == ',' {
						if stack.len > 1 && stack[stack.len - 2].tag != 'param_list' {
							mut operands := []AST{}
							operands << stack[stack.len - 2..stack.len]
							stack = stack[0..stack.len - 2]
							stack << AST{
								tag: 'param_list'
								val: ''
								list: operands
							}
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
						stack << AST{
							tag: 'operator'
							val: t.val
							list: operands
						}
					}
				} else if t.typ == lexer.TokenType.bracket {
					stack << AST{
						tag: 'bracket'
						val: t.val
						list: []AST{}
					}
				}
			}
			stmt_list << stack[0]
			line_start = i + 1
		}
	}
	ast := AST{
		tag: 'stmt_list'
		val: ''
		list: stmt_list
	}
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
		t := tokens[i] // caution: do not assign t to anyone
		if t.typ == lexer.TokenType.name || t.typ == lexer.TokenType.number {
			post_tokens << tokens[i]
		} else if t.typ == lexer.TokenType.bracket && t.val == '(' {
			if post_tokens.len > 0 && post_tokens[post_tokens.len - 1].typ == lexer.TokenType.name {
				// func call
				func_name := post_tokens[post_tokens.len - 1]
				post_tokens = post_tokens[0..post_tokens.len - 1]
				post_tokens << tokens[i] // (
				i++
				mut param_tokens := []lexer.Token{}
				mut bracket_stack := 1
				for i < tokens.len {
					if tokens[i].typ == lexer.TokenType.bracket {
						if tokens[i].val == ')' {
							bracket_stack--
						} else if tokens[i].val == '(' {
							bracket_stack++
						}
					}
					if bracket_stack == 0 {
						break
					}
					param_tokens << tokens[i]
					i++
				}
				// println('=========$param_tokens')
				param_post := to_postfix(param_tokens)
				post_tokens << param_post
				post_tokens << tokens[i] // )
				post_tokens << func_name
			} else {
				stack.push(tokens[i])
			}
		} else if t.typ == lexer.TokenType.bracket && t.val == ')' {
			for stack.len() > 0 {
				top := &lexer.Token(stack.peek())
				if top.val == '(' {
					break
				}
				post_tokens << &lexer.Token(stack.pop())
			}
			stack.pop()
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
