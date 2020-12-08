# vee Script
A programming language written in [vlang](https://vlang.io/)

What vee looks like:
```v
fn hello(names) {
	for name in names {
		println('Hello ' + name)
	}
}

names = ['Wrold', 'yjlo']
hello(names)
```

Features:
- easy to learn
- dynamic typing
- can be translated to Runtime Script

Runtime Script:
```ruby
def hello
 let _names $0
 #loop
 pol $_names _name
 jeq $_name $nil done
 add _msg 'Hello ' $_name
 prt $_msg
 jmp loop
 #done
 ret
end

let names []
psh $names 'World' 'yjlo'
cal hello $names
```

Learn more about Runtime Script:  
https://github.com/yjlo123/runtime-script
