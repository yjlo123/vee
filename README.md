# runtime-v
Runtime Script II written in [vlang](https://vlang.io/)

Runtime Script II example:
```v
fn hello(names) {
	for name in names {
		println('Hello ' + name)
	}
}

names = ['Wrold', 'yjlo']
hello(names)
```

Original Runtime Script:
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

Learn more about the original Runtime Script:  
https://github.com/yjlo123/runtime-script
