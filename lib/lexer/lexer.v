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
	func
	ret
	eof
}

struct Token {
pub mut:
	val  string
	typ  TokenType
	line int
	pos  int
}

fn (t Token) str() string {
	return '($t.val)[$t.typ]'
	// return '($t.val\t$t.typ\t$t.line,$t.pos)'
}

fn create_token(val string, category TokenType, line int, pos int) Token {
	mut cat := category
	if category == TokenType.name {
		if val == 'fn' {
			cat = TokenType.func
		} else if val == 'return' {
			cat = TokenType.ret
		}
	}
	return Token{
		val: val
		typ: cat
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
			tokens << create_token(s[i].str(), TokenType.bracket, lc, cc)
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
		} else if s[i] >= `0` && s[i] <= `9` && token.len == 0 {
			// number
			for {
				if i >= s.len || s[i] < `0` || s[i] > `9` {
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
	tokens << create_token('', TokenType.eof, lc, cc)
	return tokens
}
