module values

struct List {
pub mut:
	head []&ListNode
	tail []&ListNode
}

fn new_list() &List {
	return &List{
		head: []
		tail: []
	}
}

fn (list &List) is_empty() bool {
	return list.head.len == 0
}

fn (mut list List) set_empty() {
	list.tail = []
	list.head = []
}

fn (list &List) get_tail() &ListNode {
	return list.tail[0]
}

fn (mut list List) set_tail(node &ListNode) {
	list.tail = [node]
}

fn (list &List) get_head() &ListNode {
	return list.head[0]
}

fn (mut list List) set_head(node &ListNode) {
	list.head = [node]
}

fn (list &List) pop() &Value {
	if list.is_empty() {
		return &Value(Empty{})
	}
	mut tail := list.get_tail()
	copy := tail.val.copy_value()
	mut the_list := list
	if !tail.has_prev() {
		the_list.set_empty()
	} else {
		tail.get_prev().set_no_next()
		the_list.set_tail(tail.get_prev())
	}
	unsafe {free(tail)}
	return copy
}

fn (list &List) poll() &Value {
	if list.is_empty() {
		return &Value(Empty{})
	}
	mut head := list.get_head()
	copy := head.val.copy_value()
	mut the_list := list
	if !head.has_next() {
		the_list.set_empty()
	} else {
		head.get_next().set_no_prev()
		the_list.set_head(head.get_next())
	}
	unsafe {free(head)}
	return copy
}

fn (list &List) push(v &Value) {
	mut tail := list.get_tail()
	mut node := new_node()
	node.val = v
	node.set_prev(tail)
	tail.set_next(node)
	mut the_list := list
	the_list.set_tail(tail.get_next())
}
