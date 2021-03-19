# vee Script
A programming language written in [vlang](https://vlang.io/)

What does vee look like:
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


## AST
```
=== format ===
AST {
 (tag) val
 [AST...]
}

=== tags ===
name
number
string
operator
call
param_list
func
return
stmt_list
if

=== examples ===
6
{
  (number) 6
  []
}


'hello'
{
  (string) hello
  []
}


1+2
{
  (operator) +
  [
    {
      (number) 1
      []
    },
    {
      (number) 2
      []
    }
  ]
}


a = b + 3
{
  (operator) =
  [
    {
      (name) a
      []
    },
    {
      (operator) +
      [
        {
          (name) b
          []
        },
        {
          (number) 3
          []
        }
      ]
    }
  ]
}


print(1+2, 8)
{
  (call) print
  [
    {
      (param_list)
      [
        {
          (operator) +
          [
            {
              (number) 1
              []
            },
            {
              (number) 2
              []
            }
          ]
        },
        {
          (number) 8
          []
        }
      ]
    }
  ]
}


fn add(a, b) {
  return a + b
}
{
  (func) add
  [
    {
      (param_list)
      [
        {
          (name) a
          []
        },
        {
          (name) b
          []
        }
      ]
    },
    {
      (stmt_list)
      [
        {
          (return)
          [
            {
              (operator) +
              [
                {
                  (name) a
                  []
                },
                {
                  (name) b
                  []
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}


if a > b {
  max = a
} else {
  max = b
}
{
  (if)
  [
    {
      (operator) >
      [
        {
          (name) a
          []
        },
        {
          (name) b
          []
        }
      ]
    },
    {
      (stmt_list)
      [
        {
          (operator) =
          [
            {
              (name) max
              []
            },
            {
              (name) a
              []
            }
          ]
        }
      ]
    },
    {
      (stmt_list)
      [
        {
          (operator) =
          [
            {
              (name) max
              []
            },
            {
              (name) b
              []
            }
          ]
        }
      ]
    }
  ]
}
```
