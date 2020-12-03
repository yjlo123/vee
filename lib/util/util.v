module util

import lib.lexer

pub struct Stack {
mut:
	data []voidptr
	len  int
}

fn (s Stack) str() string {
	mut list_content := ''
	for i, n in s.data {
		if i > 0 {
			list_content += ' '
		}
		m := &lexer.Token(n)
		list_content += '$m'
	}
	return '[$list_content]'
}

struct Node {
	val int
}

pub fn (mut s Stack) push(v voidptr) {
	s.data << v
	s.len++
}

pub fn (mut s Stack) pop() voidptr {
	val := s.data[s.len - 1]
	s.data = s.data[0..s.len - 1]
	s.len--
	return val
}

pub fn (s Stack) peek() voidptr {
	return s.data[s.len - 1]
}

pub fn (s Stack) len() int {
	return s.len
}

pub fn test() {
	mut s := Stack{}
	a := Node{4}
	b := Node{6}
	s.push(a)
	s.push(b)
	println(s.len())
	v := &Node(s.pop())
	println(v)
	w := &Node(s.peek())
	println(w)
}
