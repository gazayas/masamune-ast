## [Unreleased]

## [2.0.0] - 2023-10-13

- Migrate to Prism by @gazayas in #60
- Return array of Prism nodes for `Masamune::AbstractSyntaxTree` search methods.
- Refactor NodeHelper into inline extensions by @kaspth in #61
- Remove functionality to replace source code by Node name (the `type` keyword now only accepts Symbols such as `:variable` and `:method_call`).

## [1.0.0] - 2023-05-01

- Change `MasamuneAst` module to `Masamune`.

## [0.1.0] - 2023-04-24

- Initial release
