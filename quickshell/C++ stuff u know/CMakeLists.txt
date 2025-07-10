cmake_minimum_required(VERSION 3.10)
project(ThemeEditor)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt5 REQUIRED COMPONENTS Widgets)

add_executable(ThemeEditor main.cpp)
target_link_libraries(ThemeEditor Qt5::Widgets)
