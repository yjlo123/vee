module lexer

// import lib.values
const (
	operators = ['+', '-', '*', '/', '%', '++', '--', '+=', '-=', '*=', '/=', '%=', '>', '<', '>=',
		'<=', '=', '==', ',', ';']
)

enum TokenType {
	name
	string
	number
	newline
	bracket
	operator
}

struct Token {
	value    string
	category TokenType
	line     int
	pos      int
}

fn (t Token) str() string {
	return '$t.value\t$t.category\t$t.line,$t.pos'
}

fn create_token(val string, category TokenType, line, pos int) Token {
	return Token{
		value: val
		category: category
		line: line
		pos: pos
	}
}

pub fn tokenize(s string) []Token {
	mut tokens := []Token{}
	mut lc := 1
	mut cc := 0
	mut i := 0
	mut token := ''
	for i < s.len {
		if s[i] == ` ` || s[i] == `\t` || s[i] == `\n` {
			// terminator
			if token.len > 0 {
				tokens << create_token(token, TokenType.name, lc, cc - token.len)
				token = ''
			}
			if s[i] == `\n` {
				tokens << create_token('', TokenType.newline, lc, cc)
				lc++
				cc = -1
			}
		} else if s[i].str() in operators {
			// operator
			if token.len > 0 {
				tokens << create_token(token, TokenType.name, lc, cc - token.len)
				token = ''
			}
			mut op := s[i].str()
			for op + s[i + 1].str() in operators {
				op += s[i + 1].str()
				i++
			}
			tokens << create_token(op, TokenType.operator, lc, cc)
		} else if s[i] in [`(`, `)`, `{`, `}`] {
			// bracket
			if token.len > 0 {
				tokens << create_token(token, TokenType.name, lc, cc - token.len)
				token = ''
			}
			tokens << Token{
				value: s[i].str()
				category: TokenType.bracket
				line: lc
				pos: cc
			}
		} else if s[i] in [`\'`, `"`, '`'[0]] {
			// string
			q := s[i]
			i++
			for {
				if s[i] == q {
					tokens << create_token(token, TokenType.string, lc, cc - token.len)
					token = ''
					break
				}
				token += s[i].str()
				i++
			}
		} else if s[i] >= `0` && s[i] <= `9` {
			// number
			for {
				if s[i] < `0` || s[i] > `9` {
					tokens << create_token(token, TokenType.number, lc, cc - token.len)
					token = ''
					break
				}
				token += s[i].str()
				i++
			}
			i--
		} else {
			token += s[i].str()
		}
		i++
		cc++
	}
	if token.len > 0 {
		tokens << create_token(token, TokenType.name, lc, cc - token.len)
	}
	return tokens
}

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

pub fn parse(tokens []Token) AST {
	mut ast_arr := []AST{}
	mut ast_b_arr := []AST{}
	ast_arr << AST{
		tag: 'name'
		val: 'a'
		list: []AST{}
	}
	ast_b_arr << AST{
		tag: 'name'
		val: 'b'
		list: []AST{}
	}
	ast_b_arr << AST{
		tag: 'name'
		val: 'c'
		list: []AST{}
	}
	ast_arr << AST{
		tag: 'operator'
		val: '+'
		list: ast_b_arr
	}
	return AST{
		tag: 'operator'
		val: '='
		list: ast_arr
	}
}
