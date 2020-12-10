module parser

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

fn new_ast(tag string, val string, list []AST) AST {
	return AST{
		tag: tag
		val: val
		list: list
	}
}

pub fn pretty_print_ast(ast AST, indent string, last bool) {
	head := if last { '└' } else { '├' }
	println('$indent${head}($ast.tag) $ast.val')
	child_head := if last { ' ' } else { '│' }
	if ast.list.len > 0 {
		for i, l in ast.list {
			pretty_print_ast(l, indent + '$child_head   ', i == ast.list.len - 1)
		}
	}
}
