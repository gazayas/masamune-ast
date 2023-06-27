# Masamune

## A Ruby source code analyzer based on Ripper’s Abstract Syntax Tree generator.

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
#=> [{:line_number=>1, :index_on_line=>0, :token=>"java"},
#=> {:line_number=>2, :index_on_line=>0, :token=>"javascript"},
#=> {:line_number=>2, :index_on_line=>13, :token=>"java"},
#=> {:line_number=>3, :index_on_line=>5, :token=>"java"},
#=> {:line_number=>3, :index_on_line=>25, :token=>"javascript"}]

msmn.strings
#=> [{:line_number=>1, :index_on_line=>8, :token=>"java"},
#=> {:line_number=>2, :index_on_line=>21, :token=>"script"},
#=> {:line_number=>3, :index_on_line=>13, :token=>" is not "}]

msmn.variables(name: "java")
#=> [{:line_number=>1, :index_on_line=>0, :token=>"java"},
#=> {:line_number=>2, :index_on_line=>13, :token=>"java"},
#=> {:line_number=>3, :index_on_line=>5, :token=>"java"}]

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
#=> [{:line_number=>2, :index_on_line=>4, :token=>"sum"},
#=> {:line_number=>2, :index_on_line=>8, :token=>"times"},
#=> {:line_number=>3, :index_on_line=>2, :token=>"puts"},
#=> {:line_number=>6, :index_on_line=>4, :token=>"foo"},
#=> {:line_number=>8, :index_on_line=>0, :token=>"foo"},
#=> {:line_number=>9, :index_on_line=>0, :token=>"foo"}]

msmn.method_calls
#=> [{:line_number=>2, :index_on_line=>4, :token=>"sum"},
#=> {:line_number=>2, :index_on_line=>8, :token=>"times"},
#=> {:line_number=>3, :index_on_line=>2, :token=>"puts"},
#=> {:line_number=>8, :index_on_line=>0, :token=>"foo"},
#=> {:line_number=>9, :index_on_line=>0, :token=>"foo"}]

msmn.method_definitions
#=> [{:line_number=>6, :index_on_line=>4, :token=>"foo"}]
```

You can also return the node classes themselves and get the data from there:
```ruby
code = <<~CODE
  "ruby"
  "rails"
CODE

msmn = Masamune::AbstractSyntaxTree.new(code)
msmn.strings(result_type: :nodes)
#=> [#<Masamune::AbstractSyntaxTree::StringContent:0x00007ff2d987c020
#=>   @ast_id=406820,
#=>   @contents=[:string_content, [:@tstring_content, "ruby", [1, 1]]],
#=>   @data_nodes=
#=>    [#<Masamune::AbstractSyntaxTree::DataNode:0x00007ff2d9883fc8
#=>      @ast_id=406820,
#=>      @contents=[:@tstring_content, "ruby", [1, 1]],
#=>      @data_nodes=nil,
#=>      @index_on_line=1,
#=>      @line_number=1,
#=>      @parent=#<Masamune::AbstractSyntaxTree::StringContent:0x00007ff2d987c020 ...>,
#=>      @token="ruby",
#=>      @type=:@tstring_content>]>,
#=>  #<Masamune::AbstractSyntaxTree::StringContent:0x00007ff2d9883190
#=>   @ast_id=406820,
#=>   @contents=[:string_content, [:@tstring_content, "rails", [2, 1]]],
#=>   @data_nodes=
#=>    [#<Masamune::AbstractSyntaxTree::DataNode:0x00007ff2d9883168
#=>      @ast_id=406820,
#=>      @contents=[:@tstring_content, "rails", [2, 1]],
#=>      @data_nodes=nil,
#=>      @index_on_line=1,
#=>      @line_number=2,
#=>      @parent=#<Masamune::AbstractSyntaxTree::StringContent:0x00007ff2d9883190 ...>,
#=>      @token="rails",
#=>      @type=:@tstring_content>]>]
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
