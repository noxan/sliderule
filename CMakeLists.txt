project (sliderule)

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (EXEC_NAME "sliderule")
set (RELEASE_NAME "A simple calculator.")
set (VERSION "0.0.1")

find_package (PkgConfig)

pkg_check_modules(DEPS REQUIRED gtk+-3.0)

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)

include (ValaVersion)

ensure_vala_version("0.16" MINIMUM)

include (ValaPrecompile)

vala_precompile(VALA_C ${EXEC_NAME}
  src/Application.vala

  PACKAGES
    gtk+-3.0
)

add_executable (${EXEC_NAME} ${VALA_C})

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
