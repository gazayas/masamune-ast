# frozen_string_literal: true

require "test_helper"

class TestMasamune < Minitest::Test
  def test_find_variable
    similar_tokens = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(similar_tokens)
    assert msmn.variables.size == 4
    assert msmn.variables(name: "java").size == 3
    assert msmn.variables(name: "javascript").size == 1
  end

  def test_find_string
    strings = <<~CODE
      foo = "foo"
      bar = "bar"
      puts "foo bar"
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(strings)
    assert msmn.strings.size == 3
    assert msmn.strings(content: "foo").size == 1
    assert msmn.strings(content: "bar").size == 1
    assert msmn.strings(content: "foo bar").size == 1
  end

  def test_find_method_and_string
    methods = <<~CODE
      def foo
        puts "foo"
      end
      foo
      foo # Call foo again.
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(methods)
    assert msmn.all_methods.size == 3
    assert msmn.method_calls.size == 2
    assert msmn.method_definitions.size == 1
  end

  def test_chained_method_calls
    blocks = <<~CODE
      ary = [1, 2, 3]

      # Picks up :do_block params.
      ary.sum.times do |n|
        puts n
      end

      # Picks up :brace_block params.
      ary.sum.times {|z| puts z}

      {foo: "bar"}.each {|k, v| puts "Picks up multiple params"}
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(blocks)
    methods = msmn.all_methods
    assert methods.size == 5

    method_names = methods.map {|m| m[:token]}
    assert method_names.include?("sum")
    assert method_names.include?("times")

    # Picks up ary, n, z, k, and v.
    assert msmn.variables.size == 9

    # Check block params and their line positions.
    assert msmn.block_params.size == 4
    assert msmn.block_params.first == {position: [4, 18], token: "n"}
    assert msmn.block_params.last == {position: [11, 23], token: "v"}
  end

  def test_find_comments
    comments = <<~CODE
      # First comment
      # Second comment
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(comments)

    # Comments don't have a data node in @tree.
    assert msmn.data_node_list.empty?
    assert msmn.comments.size == 2
    assert msmn.comments.first[:token] == "# First comment\n"
  end

  def test_lex_nodes_return_proper_type
    similar_tokens = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(similar_tokens)
    assert msmn.lex_nodes.first.variable?
    refute msmn.lex_nodes.first.method?
    refute msmn.lex_nodes.first.string?
  end
end
