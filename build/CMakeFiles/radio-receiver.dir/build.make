# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.28

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/piotr/Desktop/radio-receiver

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/piotr/Desktop/radio-receiver/build

# Include any dependencies generated for this target.
include CMakeFiles/radio-receiver.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/radio-receiver.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/radio-receiver.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/radio-receiver.dir/flags.make

CMakeFiles/radio-receiver.dir/src/main.cpp.o: CMakeFiles/radio-receiver.dir/flags.make
CMakeFiles/radio-receiver.dir/src/main.cpp.o: /home/piotr/Desktop/radio-receiver/src/main.cpp
CMakeFiles/radio-receiver.dir/src/main.cpp.o: CMakeFiles/radio-receiver.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --progress-dir=/home/piotr/Desktop/radio-receiver/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/radio-receiver.dir/src/main.cpp.o"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/radio-receiver.dir/src/main.cpp.o -MF CMakeFiles/radio-receiver.dir/src/main.cpp.o.d -o CMakeFiles/radio-receiver.dir/src/main.cpp.o -c /home/piotr/Desktop/radio-receiver/src/main.cpp

CMakeFiles/radio-receiver.dir/src/main.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Preprocessing CXX source to CMakeFiles/radio-receiver.dir/src/main.cpp.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/piotr/Desktop/radio-receiver/src/main.cpp > CMakeFiles/radio-receiver.dir/src/main.cpp.i

CMakeFiles/radio-receiver.dir/src/main.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Compiling CXX source to assembly CMakeFiles/radio-receiver.dir/src/main.cpp.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/piotr/Desktop/radio-receiver/src/main.cpp -o CMakeFiles/radio-receiver.dir/src/main.cpp.s

CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o: CMakeFiles/radio-receiver.dir/flags.make
CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o: /home/piotr/Desktop/radio-receiver/src/RtlSdrReceiver.cpp
CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o: CMakeFiles/radio-receiver.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --progress-dir=/home/piotr/Desktop/radio-receiver/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o -MF CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o.d -o CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o -c /home/piotr/Desktop/radio-receiver/src/RtlSdrReceiver.cpp

CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Preprocessing CXX source to CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/piotr/Desktop/radio-receiver/src/RtlSdrReceiver.cpp > CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.i

CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Compiling CXX source to assembly CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/piotr/Desktop/radio-receiver/src/RtlSdrReceiver.cpp -o CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.s

# Object files for target radio-receiver
radio__receiver_OBJECTS = \
"CMakeFiles/radio-receiver.dir/src/main.cpp.o" \
"CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o"

# External object files for target radio-receiver
radio__receiver_EXTERNAL_OBJECTS =

radio-receiver: CMakeFiles/radio-receiver.dir/src/main.cpp.o
radio-receiver: CMakeFiles/radio-receiver.dir/src/RtlSdrReceiver.cpp.o
radio-receiver: CMakeFiles/radio-receiver.dir/build.make
radio-receiver: /usr/local/lib/librtlsdr.so
radio-receiver: CMakeFiles/radio-receiver.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --bold --progress-dir=/home/piotr/Desktop/radio-receiver/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Linking CXX executable radio-receiver"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/radio-receiver.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/radio-receiver.dir/build: radio-receiver
.PHONY : CMakeFiles/radio-receiver.dir/build

CMakeFiles/radio-receiver.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/radio-receiver.dir/cmake_clean.cmake
.PHONY : CMakeFiles/radio-receiver.dir/clean

CMakeFiles/radio-receiver.dir/depend:
	cd /home/piotr/Desktop/radio-receiver/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/piotr/Desktop/radio-receiver /home/piotr/Desktop/radio-receiver /home/piotr/Desktop/radio-receiver/build /home/piotr/Desktop/radio-receiver/build /home/piotr/Desktop/radio-receiver/build/CMakeFiles/radio-receiver.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : CMakeFiles/radio-receiver.dir/depend

