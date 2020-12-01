const (
	operators = ['+', '-', '*', '/', '%', '++', '--', '+=', '-=', '*=', '/=', '%=', '>', '<', '>=',
		'<=', '=', '==', ',', ';']
)

enum TokenType {
	nm // name
	st // string
	nb // number
	nl // newline
	br // bracket
	op // operator
}

struct Token {
	value    string
	category TokenType
	line     int
	pos      int
}

fn (t Token) str() string {
	return '$t.value\t$t.category  $t.line,$t.pos'
}

fn create_token(val string, category TokenType, line, pos int) Token {
	return Token{
		value: val
		category: category
		line: line
		pos: pos
	}
}

fn tokenize(s string) []Token {
	mut tokens := []Token{}
	mut lc := 1
	mut cc := 0
	mut i := 0
	mut token := ''
	for i < s.len {
		if s[i] == ` ` || s[i] == `\t` || s[i] == `\n` {
			// terminator
			if token.len > 0 {
				tokens << create_token(token, TokenType.nm, lc, cc - token.len)
				token = ''
			}
			if s[i] == `\n` {
				tokens << create_token('', TokenType.nl, lc, cc)
				lc++
				cc = -1
			}
		} else if s[i].str() in operators {
			// operator
			if token.len > 0 {
				tokens << create_token(token, TokenType.nm, lc, cc - token.len)
				token = ''
			}
			mut op := s[i].str()
			for op + s[i + 1].str() in operators {
				op += s[i + 1].str()
				i++
			}
			tokens << create_token(op, TokenType.op, lc, cc)
		} else if s[i] in [`(`, `)`, `{`, `}`] {
			// bracket
			if token.len > 0 {
				tokens << create_token(token, TokenType.nm, lc, cc - token.len)
				token = ''
			}
			tokens << Token{
				value: s[i].str()
				category: TokenType.br
				line: lc
				pos: cc
			}
		} else if s[i] in [`\'`, `"`, '`'[0]] {
			// string
			q := s[i]
			i++
			for {
				if s[i] == q {
					tokens << create_token(token, TokenType.st, lc, cc - token.len)
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
					tokens << create_token(token, TokenType.nb, lc, cc - token.len)
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
		tokens << create_token(token, TokenType.nm, lc, cc - token.len)
	}
	return tokens
}

fn main() {
	tokens := tokenize('a =12
b = a + 25 * 3
a*=2
b++

print(b)

fn my_fun(name, msg) {
	println("hello " + name)
	println(msg)
}
my_fun("yjlo", 123)
')
	for _, t in tokens {
		println(t)
	}
}
