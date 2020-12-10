module parser

import lib.lexer

// ===== check AST =====
fn is_open_parenthesis_ast(ast AST) bool {
	return ast.tag == 'bracket' && ast.val == '('
}

fn is_close_parenthesis_ast(ast AST) bool {
	return ast.tag == 'bracket' && ast.val == ')'
}

fn is_param_list(ast AST) bool {
	return ast.tag == 'param_list'
}

// ===== check Token =====
fn is_parenthesis_token(token lexer.Token) bool {
	return token.typ == lexer.TokenType.bracket && (token.val == '(' || token.val == ')')
}

fn is_open_parenthesis_token(token lexer.Token) bool {
	return token.typ == lexer.TokenType.bracket && token.val == '('
}

fn is_close_parenthesis_token(token lexer.Token) bool {
	return token.typ == lexer.TokenType.bracket && token.val == ')'
}

fn is_open_brace_token(token lexer.Token) bool {
	return token.typ == lexer.TokenType.bracket && token.val == '{'
}

fn is_close_brace_token(token lexer.Token) bool {
	return token.typ == lexer.TokenType.bracket && token.val == '}'
}

fn is_newline(token lexer.Token) bool {
	return token.typ == lexer.TokenType.newline
}

fn is_eof(token lexer.Token) bool {
	return token.typ == lexer.TokenType.eof
}
