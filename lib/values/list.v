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

fn (mut list List) pop() &Value {
	if list.is_empty() {
		return &Value(Empty{})
	}
	mut tail := list.get_tail()
	copy := tail.val.copy_value()
	mut prev := new_node()
	if !tail.has_prev() {
		list.set_empty()
	} else {
		prev = tail.get_prev()
		prev.set_no_next()
		list.set_tail(tail.get_prev())
	}
	unsafe { free(tail) }
	return copy
}

fn (mut list List) poll() &Value {
	if list.is_empty() {
		return &Value(Empty{})
	}
	mut head := list.get_head()
	mut head_next := new_node()
	copy := head.val.copy_value()
	if !head.has_next() {
		list.set_empty()
	} else {
		head_next = head.get_next()
		head_next.set_no_prev()
		list.set_head(head.get_next())
	}
	unsafe { free(head) }
	return copy
}

fn (mut list List) push(v &Value) {
	mut tail := list.get_tail()
	mut node := new_node()
	node.val = unsafe { v }
	node.set_prev(tail)
	tail.set_next(node)
	list.set_tail(tail.get_next())
}
