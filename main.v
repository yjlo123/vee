import os
// import lib.util
import lib.evaluator
import lib.lexer
import lib.parser
import lib.values

fn main() {
	exmaple_file := './example.vee'
	program_src := os.read_file(exmaple_file) or {
		panic('error reading file $exmaple_file')
		return
	}

	tokens := lexer.tokenize(program_src)
	println('===== Tokens =====')
	lexer.pretty_print_tokens(tokens)

	ast := parser.parse(tokens)
	// parser.pretty_print_ast(ast, '', true)
	mut ast_print := []string{}
	parser.pretty_print_ast_safe(ast, '', true, mut ast_print)

	println('====== AST ======')
	for _, l in ast_print {
		println(l)
	}

	mut env := evaluator.Env{
		vars: map[string]values.Value{}
		funcs: map[string][]parser.AST{}
	}

	println('====== RESULT ======')
	evaluator.eval(ast, mut env)

	println('====== ENV ======')
	println(env)

	println('====== TEST ======')
	values.test()
	// util.test()
}
