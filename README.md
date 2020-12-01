# runtime-v
Runtime Script II written in [vlang](https://vlang.io/)

Runtime Script II example:
```
fn hello(names) {
	for name in names {
		println('Hello ' + name)
	}
}

names = ['Wrold', 'yjlo']
hello(names)
```

Original Runtime Script:
```
let names = []
psh $names 'World' 'yjlo'

#loop
pol $names name
jeq $name $nil done
prt $name
jmp loop

#done
```

Learn more about the original Runtime Script:  
https://github.com/yjlo123/runtime-script
