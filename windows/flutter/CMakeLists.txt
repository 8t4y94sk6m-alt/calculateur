cmake_minimum_required(VERSION 3.14)
project(flutter LANGUAGES CXX)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration-specific library paths.
set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")
set(FLUTTER_LIBRARY_DEBUG "${EPHEMERAL_DIR}/flutter_windows.dll")
set(FLUTTER_LIBRARY_PROFILE "${EPHEMERAL_DIR}/flutter_windows.dll")
set(FLUTTER_LIBRARY_RELEASE "${EPHEMERAL_DIR}/flutter_windows.dll")

add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter INTERFACE
  $<$<CONFIG:Debug>:${FLUTTER_LIBRARY_DEBUG}>
  $<$<CONFIG:Profile>:${FLUTTER_LIBRARY_PROFILE}>
  $<$<CONFIG:Release>:${FLUTTER_LIBRARY_RELEASE}>
)

add_library(flutter_wrapper_app INTERFACE)
target_include_directories(flutter_wrapper_app INTERFACE
  "${EPHEMERAL_DIR}/cpp_client_wrapper/include"
)
target_link_libraries(flutter_wrapper_app INTERFACE flutter)
