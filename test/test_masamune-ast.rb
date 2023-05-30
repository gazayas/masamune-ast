# frozen_string_literal: true

require "test_helper"

class TestMasamune< Minitest::Test
  def test_find_variable
    similar_identifiers = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(similar_identifiers)
    assert msmn.variables.size == 4
    assert msmn.variables(name: "java").size == 3
    assert msmn.variables(name: "javascript").size == 1
  end

=begin
  def test_find_method_and_string
    methods_and_strings = <<~CODE
      foo_and_bar = "foo bar"
      def foo
        puts "foo"
      end
      foo
      foo # Call foo again.
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(methods_and_strings)

    # Methods
    assert msmn.all_methods.size == 3
    assert msmn.method_calls.size == 2
    assert msmn.method_definitions.size == 1

    # Strings
    assert msmn.strings.size == 2
    assert msmn.search(:string, "foo").size == 1
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
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(blocks)
    methods = msmn.all_methods
    assert methods.size == 4

    method_names = methods.map {|m| m.last}
    assert method_names.include?("sum")
    assert method_names.include?("times")

    # Picks up ary, n, and z.
    assert msmn.search(:variable).size == 7

    # Check block params and their line positions.
    assert msmn.block_params.size == 2
    assert msmn.block_params.first.first == [4, 18]
    assert msmn.block_params.last.first == [9, 16]
  end

  def test_lex_nodes_return_proper_type
    similar_identifiers = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(similar_identifiers)
    assert msmn.lex_nodes.first.is_variable?
    refute msmn.lex_nodes.first.is_method?
    refute msmn.lex_nodes.first.is_string?
  end
=end
end
