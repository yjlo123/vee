module lexer

pub fn pretty_print_tokens(tokens []Token) {
	mut lc := 0
	print('$lc ')
	for t in tokens {
		mut newline := ' '
		if t.typ == TokenType.newline {
			lc++
			newline = '\n$lc '
		}
		print(t)
		print(newline)
	}
	println('')
}
