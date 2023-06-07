# frozen_string_literal: true

require "test_helper"

class TestSlasher < Minitest::Test
  def test_replace_by_ast_method_type
    code = <<~CODE
      10.times do |n|
        puts n
      end

      def n
        "n"
      end
    CODE

    msmn = Masamune::AbstractSyntaxTree.new(code)
    new_code = msmn.replace(type: :variable, old_token: "n", new_token: "foo")
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

  def test_replace_by_masamune_node_type
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
      Masamune::AbstractSyntaxTree::VarRef,
      Masamune::AbstractSyntaxTree::Params
    ]
    new_code = msmn.replace(type: types_to_replace, old_token: "n", new_token: "foo")
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
