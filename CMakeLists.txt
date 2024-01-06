cmake_minimum_required(VERSION 3.24)
project(radio-receiver)

set(CMAKE_CXX_STANDARD 20)

add_executable(radio-receiver src/main.cpp src/AudioDecoder.h src/AudioDecoder.cpp src/RDSDecoder.h src/RDSDecoder.cpp)

target_include_directories(radio-receiver PRIVATE /opt/homebrew/include)
target_link_libraries(radio-receiver PRIVATE /opt/homebrew/lib/librtlsdr.dylib)
