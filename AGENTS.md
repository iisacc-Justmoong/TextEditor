# Repository Guidelines

## Project Structure & Module Organization
- `main.cpp` hosts the console entry point; grow new features by moving logic into dedicated translation units under `src/` (create it if absent) so the root stays minimal.
- `CMakeLists.txt` currently defines a single `TextEditor` executable; append new sources via `target_sources(TextEditor PRIVATE ...)` and register helper libraries with `add_library` when modules become reusable.
- IDE builds land in `cmake-build-debug/`; prefer a disposable `build/` directory for CLI workflows and keep generated folders out of version control.
- Place reusable assets (sample documents, configuration fixtures) in `assets/`, and mirror the source tree inside `tests/` to keep functionality and coverage aligned.

## Build, Test, and Development Commands
- `cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug` configures an out-of-tree build with sensible defaults.
- `cmake --build build --target TextEditor` compiles the executable for the active generator.
- `./build/TextEditor` launches the binary for manual verification of editing scenarios.
- `ctest --test-dir build` discovers and runs all registered tests once you populate the suite.

## Coding Style & Naming Conventions
- Target modern C++20, leaning on the STL and RAII; prefer composition over macros.
- Use 4-space indentation, Allman braces, UTF-8 encoding, and wrap lines at ~100 columns for readability.
- Classes/structs use PascalCase (`GapBuffer`), functions camelCase (`loadDocument`), constants SCREAMING_SNAKE_CASE, and file names stay snake_case (`document_io.cpp`).
- Format code with `clang-format -i <files>` before committing; run `cmake --build build --target clang-tidy` where available for static checks.

## Testing Guidelines
- Use GoogleTest; add targets under `tests/` such as `tests/document_io_test.cpp` and register them through CMake with `add_test` so `ctest` can execute them.
- Name tests `<Component>.<Behavior>` and keep fixtures lean; cover parsing, buffer operations, and command dispatch paths before merging.
- Maintain descriptive failure messages and consider coverage thresholds (e.g., keep core modules above 80%).

## Commit & Pull Request Guidelines
- With no established history, follow an imperative, 72-character subject line (e.g., `Add cursor movement commands`) and include rationale plus testing notes in the body.
- Reference related issues in commit bodies and PR descriptions, attach screenshots or terminal recordings for UX-facing changes, and call out new configuration steps.
- Require at least one reviewer, include `cmake`/`ctest` output snippets proving the branch builds cleanly, and list any follow-up work before requesting approval.
