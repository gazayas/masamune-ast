# frozen_string_literal: true

require "test_helper"

class TestSlasher < Minitest::Test
  def test_replace_by_ast_method_type
    code = <<~CODE
      10.times do |n|
        puts n
      end

      puts n

      def n
        "n"
      end
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(code)
    new_code = msmn.replace(type: :variable, old_token_value: "n", new_token_value: "foo")
    expected_code = <<~CODE
      10.times do |foo|
        puts foo
      end

      puts foo

      def n
        "n"
      end
    CODE
    assert_equal expected_code, new_code
  end

  def test_replace_by_prism_node_type
    # TODO: Things get a little complicated when trying to determine the visitor dynamically,
    # so I'm leaving this functionality out for now.
    skip

    code = <<~CODE
      10.times do |n|
        puts n
      end

      def n
        "n"
      end
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(code)

    types_to_replace = [
      Prism::RequiredParameterNode,
      Prism::LocalVariableReadNode,
    ]
    new_code = msmn.replace(type: types_to_replace, old_token_value: "n", new_token_value: "foo")
    expected_code = <<~CODE
      10.times do |foo|
        puts foo
      end

      def n
        "n"
      end
    CODE
    assert_equal new_code, expected_code
  end
end
