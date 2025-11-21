cmake_minimum_required(VERSION 3.21)
project(TextEditor VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(GNUInstallDirs)

find_package(Qt6 6.8.3 REQUIRED COMPONENTS Quick Qml)
qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(TextEditor
    main.cpp
    src/editor/TextDocument.cpp
    src/editor/TextDocument.h
    src/parser/MarkdownParser.cpp
    src/parser/MarkdownParser.h
    src/render/MarkdownRenderEngine.cpp
    src/render/MarkdownRenderEngine.h
    src/render/MarkdownRenderBridge.cpp
    src/render/MarkdownRenderBridge.h
    src/utils/DocumentUtilities.cpp
    src/utils/DocumentUtilities.h
)

target_include_directories(TextEditor
    PRIVATE
        src
)

target_link_libraries(TextEditor
    PRIVATE
        Qt6::Quick
        Qt6::Qml
)

qt_add_qml_module(TextEditor
    URI TextEditor
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/AppToolbar.qml
        qml/ViewerStack.qml
        qml/ViewerFooter.qml
)

set_target_properties(TextEditor PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS TextEditor
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
