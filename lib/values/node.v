module values

struct ListNode {
pub mut:
	val  &Value
	prev []&ListNode
	next []&ListNode
}

fn new_node() &ListNode {
	return &ListNode{
		val: &Empty{}
		prev: []
		next: []
	}
}

fn (node &ListNode) has_prev() bool {
	return node.prev.len != 0
}

fn (node &ListNode) get_prev() &ListNode {
	return node.prev[0]
}

fn (mut node ListNode) set_prev(prev &ListNode) {
	node.prev = [prev]
}

fn (mut node ListNode) set_no_prev() {
	node.prev = []
}

fn (node &ListNode) has_next() bool {
	return node.next.len != 0
}

fn (node &ListNode) get_next() &ListNode {
	return node.next[0]
}

fn (mut node ListNode) set_next(next &ListNode) {
	node.next = [next]
}

fn (mut node ListNode) set_no_next() {
	node.next = []
}
