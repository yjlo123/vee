module values

const (
	type_integer = 'lib.values.Integer'
	type_string  = 'lib.values.String'
	type_list    = 'lib.values.ListValue'
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
pub mut:
	val &List
}

pub struct Nil {
}

pub struct Empty {
}

type Value = Empty | Integer | ListValue | Nil | String

pub fn new_integer(val int) Integer {
	return Integer{val}
}

pub fn new_string(val string) String {
	return String{val}
}

fn (v Value) add_one() Value {
	if v.type_name() == values.type_integer {
		num := v as Integer
		return Value(Integer{num.val + 1})
	} else if v.type_name() == values.type_string {
		s := v as String
		return Value(String{s.val + '1'})
	} else if v.type_name() == values.type_list {
		mut l := v as ListValue
		l.val.push(&Value(String{
			val: 'new'
		}))
		return Value(l)
	}
	return Value(Nil{})
}

fn (v Value) copy_value() &Value {
	if v.type_name() == values.type_integer {
		num := v as Integer
		return &Value(Integer{num.val})
	} else if v.type_name() == values.type_string {
		s := v as String
		return &Value(String{s.val})
	} else if v.type_name() == values.type_list {
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
	if v.type_name() == values.type_integer {
		num := v as Integer
		return num.to_string()
	} else if v.type_name() == values.type_string {
		s := v as String
		return s.to_string()
	}
	return ''
}

fn (v Value) str() string {
	return v.to_string()
}

pub fn (v Value) to_val_string() string {
	if v.type_name() == values.type_integer {
		num := v as Integer
		return '$num.val'
	} else if v.type_name() == values.type_string {
		s := v as String
		return '$s.val'
	}
	return ''
}

fn build_list(nums []int) &List {
	mut node := new_node()
	mut head := node
	mut next_node := node
	for i, num in nums {
		head.val = &Value(Integer{num})
		if i < nums.len - 1 {
			head.set_next(new_node())
			next_node = head.get_next()
			next_node.set_prev(head)
			head = head.get_next()
		}
	}
	mut list := new_list()
	list.set_head(node)
	list.set_tail(head)
	return list
}

fn print_list(list &List) {
	mut str := ''
	str += '[ '
	mut head := list.head
	for {
		if head.len == 0 {
			break
		}
		str += (head[0].val.to_string() + ' ')
		head = head[0].next
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
	p.push(&Value(String{
		val: 'abc'
	}))
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
