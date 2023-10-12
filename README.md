# Masamune

## A covenience wrapper around Prism, a Ruby source code parser 

## Installation

```ruby
sudo gem install "masamune-ast"
```

Or add the following to your Gemfile and run `bundle install`
```ruby
gem "masamune-ast"
```

Then require the gem in a file like this:
```ruby
require "masamune"
```

## Usage

Isolate and replace variables, methods, or strings in your Ruby source code according to the specific tokens allotted when the code is intially parsed:
```ruby
code = <<~CODE
  :hello
  hello = "hello"
  def hello
    puts hello
  end
CODE

msmn = Masamune::AbstractSyntaxTree.new(code)
msmn.replace(type: :variable, old_token_value: "hello", new_token_value: "greeting")

# This will produce the following code in string form.
:hello
greeting = "hello"
def hello
  puts greeting
end
```

Pinpoint variables and methods in your source code even when other tokens have the same or similar spelling:
```ruby
code = <<CODE
java = "java"
javascript = java + "script"
puts java + " is not " + javascript
# java
CODE

msmn = Masamune::AbstractSyntaxTree.new(code)

# Returns an array of Prism nodes
msmn.variables

msmn.variables.first.token_value
#=> "java"
msmn.variables.first.token_location
#=> (1,0)-(1,4)

# Returns an array of Prism nodes
msmn.strings

last_java_node = msmn.variables(token_value: "java").last
last_java_node.token_location
#=> (3,5)-(3,9)

code = <<CODE
ary = [1, 2, 3]
ary.sum.times do |n|
  puts n
end

def foo
end
foo
foo # Call again
CODE

msmn = Masamune::AbstractSyntaxTree.new(code)

msmn.method_definitions.size
#=> 1

msmn.method_calls.size
#=> 5

msmn.all_methods.size
#=> 6
```

In some cases, it can be easier to look at the given lex nodes to analyze your source code:
```ruby
msmn.lex_nodes
=> [#<Masamune::LexNode:0x00007fd61810cac0 @ast_id=1200, @index=0, @location=[1, 0], @state=CMDARG, @token="java", @type=:ident>,
 #<Masamune::LexNode:0x00007fd61810c930 @ast_id=1200, @index=1, @location=[1, 4], @state=CMDARG, @token=" ", @type=:sp>,
 #<Masamune::LexNode:0x00007fd61810c7c8 @ast_id=1200, @index=2, @location=[1, 5], @state=BEG, @token="=", @type=:op>,
…
]

lex_node = msmn.lex_nodes.first

lex_node.variable?
#=> true

lex_node.string?
#=> false

lex_node.method_definition?
#=> false
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gazayas/masamune-ast.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
