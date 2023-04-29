# frozen_string_literal: true

require "test_helper"

class TestMasamune < Minitest::Test
  # TODO: Match results with LexNode instances.

  def test_find_variable
    similar_identifiers = <<~CODE
      java = "java"
      javascript = java + "script"
      p java
      # java (Doesn't pick up comments)
    CODE

    msmn = Masamune::Base.new(similar_identifiers)
    assert msmn.ast.search(:variable).size == 4
    assert msmn.ast.search(:variable, "java").size == 3
    assert msmn.ast.search(:variable, "javascript").size == 1
  end

  def test_find_method_and_string
    methods_and_strings = <<~CODE
      foo_and_bar = "foo bar"
      def foo
        puts "foo"
      end
      foo
      foo # Call foo again.
    CODE

    msmn = Masamune::Base.new(methods_and_strings)

    # Methods
    assert msmn.ast.methods.size == 3
    assert msmn.ast.method_calls.size == 2
    assert msmn.ast.method_definitions.size == 1

    # Strings
    assert msmn.ast.strings.size == 2
    assert msmn.ast.search(:string, "foo").size == 1
  end

  def test_chained_method_calls
    blocks = <<~CODE
      ary = [1, 2, 3]
      ary.sum.times do |n|
        puts n
      end
    CODE

    msmn = Masamune::Base.new(blocks)
    methods = msmn.ast.methods
    assert methods.size == 2

    method_names = methods.map {|m| m.last}
    assert method_names.include?("sum")
    assert method_names.include?("times")
  end
end
