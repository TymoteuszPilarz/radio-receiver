cmake_minimum_required(VERSION 3.24)
project(radio-receiver)

set(CMAKE_CXX_STANDARD 20)

add_executable(radio-receiver src/main.cpp src/RtlSdrReceiver.cpp src/RtlSdrReceiver.h src/RDSDecoder.h src/RDSDecoder.cpp)

target_include_directories(radio-receiver PRIVATE /usr/local/include)
target_link_libraries(radio-receiver PRIVATE /usr/local/lib/librtlsdr.so)

