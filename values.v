const (
	null_ptr = 0
)

struct Value {
pub mut:
	typ string
	val string
}

pub fn (v Value) str() string {
	return '${v.val}($v.typ)'
}

pub fn (v Value) to_string() string {
	return v.str()
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
	if list.tail == null_ptr {
		return null_ptr
	}
	mut tail := list.tail
	copy := &Value{
		typ: tail.val.typ
		val: tail.val.val
	}
	
	mut the_list := list
	if tail.prev == null_ptr {
		the_list.tail = null_ptr
		the_list.head = null_ptr
	} else {
		tail.prev.next = null_ptr
		the_list.tail = tail.prev
	}
	unsafe {
		free(tail)
	}
	return copy
}

fn (list &List) poll() &Value {
	if list.head == null_ptr {
		return null_ptr
	}
	mut head := list.head
	copy := &Value{
		typ: head.val.typ
		val: head.val.val
	}
	mut the_list := list
	if head.next == null_ptr {
		the_list.tail = null_ptr
		the_list.head = null_ptr
	} else {
		head.next.prev = null_ptr
		the_list.head = head.next
	}
	unsafe {
		free(head)
	}
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
		prev: null_ptr
		next: null_ptr
	}
}

fn build_list(nums []int) &List {
	mut node := new_node()
	mut head := node
	for i, num in nums {
		head.val = &Value{
			typ: 'int'
			val: num.str()
		}
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
		if head == null_ptr {
			break
		}
		str += (head.val.to_string() + ' ')
		head = head.next
	}
	str += ']'
	println(str)
}

fn main() {
	p := build_list([1, 2, 3, 4])
	print_list(p)
	mut v := p.pop()
	println(v)
	print_list(p)
	v = p.poll()
	println(v)
	print_list(p)
	p.push(&Value{
		typ: 'str'
		val: '12'
	})
	print_list(p)
	p.pop()
	p.poll()
	p.poll()
	print_list(p)
	p.pop()
	print_list(p)
}
