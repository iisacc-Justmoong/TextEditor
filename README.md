# TextEditor

Modern Qt Quick text and Markdown editor that mixes a QML user interface with a thin C++20 backend. The app targets desktop platforms (Windows, macOS, Linux) and focuses on side-by-side editing, live Markdown rendering, and small productivity helpers such as timestamps and document statistics.

## High-Level Architecture

- **Entry point (`main.cpp`)**  
  Bootstraps `QGuiApplication`, registers backend types into the `TextEditor.Backend` QML module, and loads `qml/Main.qml`.
- **QML presentation (`qml/*.qml`)**  
  `Main.qml` hosts the `ApplicationWindow`, wiring up the toolbar, viewer stack, and footer controls. `AppToolbar.qml` provides file/timestamp commands plus the cross-platform font picker. `ViewerStack.qml` exposes three editor modes (plain text, Markdown-only, split view) and keeps the caret and preview synchronized. `ViewerFooter.qml` and `ViewerStack.qml` coordinate switching modes.
- **Editor services (`src/editor`)**  
  `TextDocument` wraps the current document buffer, file path, and disk I/O (open/save) while exposing Q_PROPERTY bindings to QML.
- **Markdown rendering pipeline (`src/parser`, `src/render`)**  
  `MarkdownParser` performs the Markdown-to-HTML transformation (headings, emphasis, lists, inlines). `MarkdownRenderEngine` owns the parser and exposes a simple `render()` call. `MarkdownRenderBridge` is a QObject visible to QML so UI code can request HTML for previews.
- **Document utilities (`src/utils`)**  
  `DocumentUtilities` calculates live word/paragraph/line counts and generates timestamp strings according to the toolbar commands.

The UI exchanges data with the backend via QML signals/slots and Q_INVOKABLE methods:

1. Typing in any `TextArea` updates `TextDocument.text`, which pushes the buffer to all viewers.  
2. Each text change triggers `DocumentUtilities.analyzeText()` and `MarkdownRenderBridge.render()`, keeping statistics and rendered HTML current.  
3. Toolbar actions call `TextDocument` methods for file operations and `DocumentUtilities.makeTimestamp()` for content insertion.  
4. The font picker in the toolbar surfaces `Qt.fontFamilies()` so the chosen family/size propagate through `ViewerStack` to every editor and preview surface.

## Source Tree

```
TextEditor/
├── CMakeLists.txt              # Configures the TextEditor executable and Qt imports
├── main.cpp                    # Application entry + type registration
├── qml/                        # QML UI (Main, ViewerStack, AppToolbar, etc.)
├── src/
│   ├── editor/                 # TextDocument buffer + file I/O
│   ├── parser/                 # MarkdownParser (Markdown → HTML)
│   ├── render/                 # Render engine + QML bridge
│   └── utils/                  # DocumentUtilities (metrics & timestamps)
├── assets/                     # Place shared fixtures/resources here (currently empty)
└── tests/                      # Placeholder for future GoogleTest coverage
```

## Build & Run

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target TextEditor
./build/TextEditor
```

`ViewerStack` supports text-only, Markdown-only, and split layouts. Use the toolbar buttons to open/save files, insert timestamps, and choose fonts that exist on the host OS (Windows, macOS, Linux). The footer toggles visualization modes, and the live metrics label reports characters, words, paragraphs, and lines.

## Testing

GoogleTest is the preferred framework. Once tests are added under `tests/` and registered via CMake, execute:

```bash
ctest --test-dir build
```

Add coverage for parser behavior, document utilities, and future buffer commands to maintain confidence in the application core.
