# Masamune

## A Ruby source code analyzer based on Ripper’s Abstract Syntax Tree generator (`Ripper#sexp`).

## Installation

```ruby
sudo gem install "masamune-ast"
```

Or add the following to your Gemfile and run `bundle install`
```ruby
gem "masamune-ast"
```

## Usage

Pinpoint variables and methods in your source code even when other tokens have the same or similar spelling:
```ruby
code = <<CODE
java = "java"
javascript = java + "script"
puts java + " is not " + javascript
# java
CODE

msmn = Masamune::AbstractSyntaxTree.new(code)

# Searching the tree returns the specific node and the line number it's on.
msmn.variables
#=> [[[1, 0], "java"], [[2, 0], "javascript"], [[2, 13], "java"], [[3, 5], "java"], [[3, 25], "javascript"]]

msmn.search(:variable, "java")
#=> [[[1, 0], "java"], [[2, 13], "java"], [[3, 5], "java"]]

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

msmn.search(:method_call, "sum")
#=> [[[2, 4], "sum"]]

msmn.search(:def, "foo")
#=> [[[6, 4], "foo"]]

msmn.search(:method_call, "foo")
#=> [[[8, 0], "foo"], [[9, 0], "foo"]]
```

In some cases, it can be easier to look at the given lex nodes to analyze your source code:
```ruby
msmn.lex_nodes
=> [#<Masamune::LexNode:0x00007fd61810cac0 @ast_id=1200, @index=0, @position=[1, 0], @state=CMDARG, @token="java", @type=:ident>,
 #<Masamune::LexNode:0x00007fd61810c930 @ast_id=1200, @index=1, @position=[1, 4], @state=CMDARG, @token=" ", @type=:sp>,
 #<Masamune::LexNode:0x00007fd61810c7c8 @ast_id=1200, @index=2, @position=[1, 5], @state=BEG, @token="=", @type=:op>,
 #<Masamune::LexNode:0x00007fd61810c638 @ast_id=1200, @index=3, @position=[1, 6], @state=BEG, @token=" ", @type=:sp>,
 #<Masamune::LexNode:0x00007fd61810c480 @ast_id=1200, @index=4, @position=[1, 7], @state=BEG, @token="\"", @type=:tstring_beg>,
 #<Masamune::LexNode:0x00007fd61810c318 @ast_id=1200, @index=5, @position=[1, 8], @state=BEG, @token="java", @type=:tstring_content>,
 #<Masamune::LexNode:0x00007fd61810c188 @ast_id=1200, @index=6, @position=[1, 12], @state=END, @token="\"", @type=:tstring_end>,
 #<Masamune::LexNode:0x00007fd61810c020 @ast_id=1200, @index=7, @position=[1, 13], @state=BEG, @token="\n", @type=:nl>,
 #<Masamune::LexNode:0x00007fd618113e88 @ast_id=1200, @index=8, @position=[2, 0], @state=CMDARG, @token="javascript", @type=:ident>,
 #<Masamune::LexNode:0x00007fd618113cf8 @ast_id=1200, @index=9, @position=[2, 10], @state=CMDARG, @token=" ", @type=:sp>,
 #<Masamune::LexNode:0x00007fd618113b68 @ast_id=1200, @index=10, @position=[2, 11], @state=BEG, @token="=", @type=:op>,
…
]

msmn.lex_nodes.first.is_variable?
#=> true

msmn.lex_nodes.first.is_string?
#=> false

msmn.lex_nodes.first.is_method_definition?
#=> false

# etc...
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gazayas/masamune-ast.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
