# Code example:
# puts "hello"
#
# syntax_tree output:
# SyntaxTree::Command[
#   message: SyntaxTree::Ident[value: "puts"],
#   arguments: SyntaxTree::Args[
#     parts: [
#       SyntaxTree::StringLiteral[
#         parts: [SyntaxTree::TStringContent[value: "greetings"]]
#       ]
#     ]
#   ]
# ]

# Code example:
# namespace :project
#   resources :pages
# end
#
# syntax_tree output:
# SyntaxTree::Command[
#   message: SyntaxTree::Ident[value: "namespace"],
#   arguments: SyntaxTree::Args[
#     parts: [SyntaxTree::SymbolLiteral[value: SyntaxTree::Ident[value: "project"]]]
#   ],
#   block: SyntaxTree::BlockNode[
#     bodystmt: SyntaxTree::BodyStmt[
#       statements: SyntaxTree::Statements[
#         body: [
#           SyntaxTree::Command[
#             message: SyntaxTree::Ident[value: "resources"],
#             arguments: SyntaxTree::Args[
#               parts: [
#                 SyntaxTree::SymbolLiteral[
#                   value: SyntaxTree::Ident[value: "pages"]
#                 ]
#               ]
#             ]
#           ]
#         ]
#       ]
#     ]
#   ]
# ]


# TODO: As you can see in the second example above, `command` can receive a
# block, so we might want to have a way to access the block node in the future.
module Masamune
  class AbstractSyntaxTree
    class Command < Node
      def initialize(contents, ast_id)
        super
      end

      def extract_data_nodes
        [
          DataNode.new(@contents[1], @ast_id, self)
        ]
      end
    end
  end
end
