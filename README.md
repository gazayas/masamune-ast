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

Then require the gem in a file like this:
```ruby
require "masamune"
```

## Usage

Isolate and replace variables, methods, or strings in your Ruby source code according to the specific tokens allotted when the code is intially parsed:
```ruby
code = <<~CODE
  10.times do |n|
    puts n
  end

  def n
    "n"
  end
CODE

msmn = Masamune::AbstractSyntaxTree.new(code)
msmn.replace(type: :variable, old_token: "n", new_token: "foo")

# This will produce the following code in string form.
10.times do |foo|
  puts foo
end

def n
  "n"
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

msmn.variables
#=> [{:position=>[1, 0], :token=>"java"},
#=> {:position=>[2, 0], :token=>"javascript"},
#=> {:position=>[2, 13], :token=>"java"},
#=> {:position=>[3, 5], :token=>"java"},
#=> {:position=>[3, 25], :token=>"javascript"}]

msmn.strings
#=> [{:position=>[1, 8], :token=>"java"},
#=> {:position=>[2, 21], :token=>"script"},
#=> {:position=>[3, 13], :token=>" is not "}]

msmn.variables(name: "java")
#=> [{position: [1, 0], token: "java"},
#=> {position: [2, 13], token: "java"},
#=> {position: [3, 5], token: "java"}]

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

msmn.all_methods
#=> [{:position=>[2, 4], :token=>"sum"},
#=> {:position=>[2, 8], :token=>"times"},
#=> {:position=>[3, 2], :token=>"puts"},
#=> {:position=>[6, 4], :token=>"foo"},
#=> {:position=>[8, 0], :token=>"foo"},
#=> {:position=>[9, 0], :token=>"foo"}]

msmn.method_calls
#=> [{:position=>[2, 4], :token=>"sum"},
#=> {:position=>[2, 8], :token=>"times"},
#=> {:position=>[3, 2], :token=>"puts"},
#=> {:position=>[8, 0], :token=>"foo"},
#=> {:position=>[9, 0], :token=>"foo"}]

msmn.method_definitions
#=> [{:position=>[6, 4], :token=>"foo"}]
```

You can also return the node classes themselves and get the data from there:
```ruby
code = <<~CODE
  "ruby"
  "rails"
CODE

msmn = Masamune::AbstractSyntaxTree.new(code)
msmn.strings(result_type: :nodes)
#=> [#<Masamune::AbstractSyntaxTree::StringContent:0x00007f6f7c9a6850
#=>  @ast_id=1440,
#=>  @contents=[:string_content, [:@tstring_content, "ruby", [1, 1]]],
#=>  @data_nodes=
#=>   [#<Masamune::AbstractSyntaxTree::DataNode:0x00007f6f7c9a6828
#=>     @ast_id=1440,
#=>     @contents=[:@tstring_content, "ruby", [1, 1]],
#=>     @data_nodes=nil,
#=>     @line_position=[1, 1],
#=>     @token="ruby",
#=>     @type=:@tstring_content>]>,
#=> #<Masamune::AbstractSyntaxTree::StringContent:0x00007f6f7c9a5630
#=>  @ast_id=1440,
#=>  @contents=[:string_content, [:@tstring_content, "rails", [2, 1]]],
#=>  @data_nodes=
#=>   [#<Masamune::AbstractSyntaxTree::DataNode:0x00007f6f7c9a5608
#=>     @ast_id=1440,
#=>     @contents=[:@tstring_content, "rails", [2, 1]],
#=>     @data_nodes=nil,
#=>     @line_position=[2, 1],
#=>     @token="rails",
#=>     @type=:@tstring_content>]>]
```

In some cases, it can be easier to look at the given lex nodes to analyze your source code since you can easily see the index and the line position it's on:
```ruby
msmn.lex_nodes
=> [#<Masamune::LexNode:0x00007fd61810cac0 @ast_id=1200, @index=0, @position=[1, 0], @state=CMDARG, @token="java", @type=:ident>,
 #<Masamune::LexNode:0x00007fd61810c930 @ast_id=1200, @index=1, @position=[1, 4], @state=CMDARG, @token=" ", @type=:sp>,
 #<Masamune::LexNode:0x00007fd61810c7c8 @ast_id=1200, @index=2, @position=[1, 5], @state=BEG, @token="=", @type=:op>,
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
