module values

const (
	null = 0
)

struct Integer {
pub:
	val int
}

struct String {
pub:
	val string
}

struct ListValue {
pub:
	val &List
}

pub struct Nil {}

type Value = Integer | String | ListValue | Nil

pub fn new_integer(val int) Integer {
	return Integer{val}
}

pub fn new_string(val string) String {
	return String{val}
}

fn (v Value) add_one() Value {
	if v.type_name() == 'lib.values.Integer' {
		num := v as Integer
		return Value(Integer{num.val + 1})
	} else if v.type_name() == 'lib.values.String' {
		s := v as String
		return Value(String{s.val + '1'})
	} else if v.type_name() == 'lib.values.ListValue' {
		l := v as ListValue
		l.val.push(&Value(String{val: 'new'}))
		return Value(l)
	}
	return Value(Nil{})
}

fn (v Value) copy_value() &Value {
	if v.type_name() == 'lib.values.Integer' {
		num := v as Integer
		return &Value(Integer{num.val})
	} else if v.type_name() == 'lib.values.String' {
		s := v as String
		return &Value(String{s.val})
	} else if v.type_name() == 'lib.values.ListValue' {
		l := v as ListValue
		return &Value(ListValue{l.val})
	}
	return &Value(Nil{})
}

pub fn (v Integer) to_string() string {
	return '${v.val}(int)'
}

pub fn (v String) to_string() string {
	return '${v.val}(str)'
}

pub fn (v Value) to_string() string {
	if v.type_name() == 'lib.values.Integer' {
		num := v as Integer
		return num.to_string()
	} else if v.type_name() == 'lib.values.String' {
		s := v as String
		return s.to_string()
	}
	return ''
}

fn (v Value) str() string {
	return v.to_string()
}

pub fn (v Value) to_val_string() string {
	if v.type_name() == 'lib.values.Integer' {
		num := v as Integer
		return '${num.val}'
	} else if v.type_name() == 'lib.values.String' {
		s := v as String
		return '${s.val}'
	}
	return ''
}

struct ListNode {
pub mut:
	val  &Value
	prev &ListNode
	next &ListNode
}

struct List {
pub mut:
	head &ListNode
	tail &ListNode
}

fn (list &List) pop() &Value {
	if list.tail == null {
		return null
	}
	mut tail := list.tail
	copy := tail.val.copy_value()
	mut the_list := list
	if tail.prev == null {
		the_list.tail = null
		the_list.head = null
	} else {
		tail.prev.next = null
		the_list.tail = tail.prev
	}
	unsafe {free(tail)}
	return copy
}

fn (list &List) poll() &Value {
	if list.head == null {
		return null
	}
	mut head := list.head
	copy := head.val.copy_value()
	mut the_list := list
	if head.next == null {
		the_list.tail = null
		the_list.head = null
	} else {
		head.next.prev = null
		the_list.head = head.next
	}
	unsafe {free(head)}
	return copy
}

fn (list &List) push(v &Value) {
	mut tail := list.tail
	tail.next = &ListNode{
		val: v
		prev: tail
		next: 0
	}
	mut the_list := list
	the_list.tail = tail.next
}

fn new_node() &ListNode {
	return &ListNode{
		val: &Value{}
		prev: null
		next: null
	}
}

fn build_list(nums []int) &List {
	mut node := new_node()
	mut head := node
	for i, num in nums {
		head.val = &Value(Integer{num})
		if i < nums.len - 1 {
			head.next = new_node()
			head.next.prev = head
			head = head.next
		}
	}
	return &List{
		head: node
		tail: head
	}
}

fn print_list(list &List) {
	mut str := ''
	str += '[ '
	mut head := list.head
	for {
		if head == null {
			break
		}
		str += (head.val.to_string() + ' ')
		head = head.next
	}
	str += ']'
	println(str)
}

pub fn test() {
	mut p := build_list([1, 2, 3, 4])
	print_list(p)
	mut v := p.pop()
	println(v.to_string())
	print_list(p)
	v = p.poll()
	println(v.to_string())
	mut nv := v.add_one()
	println(nv.to_string())
	print_list(p)

	Value(ListValue{p}).add_one()
	print_list(p)

	p.push(&Value(String{val: 'abc'}))
	print_list(p)
	v = p.pop()
	println(v.to_string())
	nv = v.add_one()
	println(nv.to_string())
	p.poll()
	p.poll()
	print_list(p)
	p.pop()
	print_list(p)
}
