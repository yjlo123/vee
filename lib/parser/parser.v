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
	mut stmt_list := []AST{}
	mut line_start := 0
	for i := 0; i < tokens.len; i++ {
		token := tokens[i]
		if token.typ == lexer.TokenType.func {
			mut func_detail := []AST{} // params, body
			func_name := tokens[i+1].val
			if tokens[i+2].val != '(' {
				println('ERROR: expect `(`')
			}
			i += 2 // func_name (
			for i < tokens.len && tokens[i].val != ')' {
				i++
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
			i++ // }
			func_body := parse(tokens[body_start..i])
			func_detail << func_body
			stmt_list << AST{
				tag: 'func'
				val: func_name
				list: func_detail
			}
			line_start = i + 1
		} else if token.typ == lexer.TokenType.newline || token.typ == lexer.TokenType.eof {
			// println('line:${tokens[line_start..i]}')
			post_tokens := to_postfix(tokens[line_start..i])
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
						if stack[stack.len - 2].tag == 'param_list' {
							func_params << stack[stack.len - 2]
						} else {
							// single param
							mut param_list := []AST{}
							param_list << stack[stack.len - 2]
							func_params << AST{
								tag: 'param_list'
								val: ''
								list: param_list
							}
						}
						stack = stack[0..stack.len - 3] // remove ( pl )
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
	return AST{
		tag: 'stmt_list'
		val: ''
		list: stmt_list
	}
}

fn to_postfix(tokens []lexer.Token) []lexer.Token {
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
				for i < tokens.len &&
					(tokens[i].typ != lexer.TokenType.bracket || tokens[i].val != ')') {
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
	// println('post tokens:$post_tokens')
	return post_tokens
}
