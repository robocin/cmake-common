set(QT6_DEFAULT_VERSION 6)

function(ROBOCIN_APPEND_QT6_PREFIX_PATH OUTPUT_DIRS)
  foreach (QT_PATH ${ARGN})
    if (IS_DIRECTORY ${QT_PATH})
      file(GLOB subdirs RELATIVE ${QT_PATH} ${QT_PATH}/*)
      foreach (subdir ${subdirs})
        if (IS_DIRECTORY ${QT_PATH}/${subdir}/gcc_64)
          list(APPEND DIRS_LIST ${QT_PATH}/${subdir}/gcc_64)
        endif ()
      endforeach ()
    endif ()
  endforeach ()
  set(${OUTPUT_DIRS} ${DIRS_LIST} PARENT_SCOPE)
endfunction()

macro(ROBOCIN_LINK_QT6_LIBRARIES TARGET_NAME)
  ROBOCIN_APPEND_QT6_PREFIX_PATH(QT_HINT_DIRS $ENV{HOME}/qt $ENV{HOME}/Qt /opt/qt /opt/Qt)

  foreach (DIR ${QT_HINT_DIRS})
    list(APPEND CMAKE_PREFIX_PATH ${DIR})
  endforeach ()

  foreach (LIBRARY_NAME ${ARGN})
    find_package(QT NAMES Qt6 COMPONENTS ${LIBRARY_NAME} REQUIRED)
    find_package(Qt${QT_VERSION_MAJOR} ${QT6_DEFAULT_VERSION} COMPONENTS ${LIBRARY_NAME} REQUIRED)

    target_link_libraries(${TARGET_NAME} PUBLIC Qt${QT_VERSION_MAJOR}::${LIBRARY_NAME})
  endforeach ()
endmacro()

function(ROBOCIN_ADD_TEST_SUBDIR TEST_NAME)
  add_subdirectory(${TEST_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${TEST_NAME})
endfunction()

macro(ROBOCIN_MAKE_QT_TEST TEST_NAME)
  cmake_minimum_required(VERSION 3.16)

  project(${TEST_NAME})

  include_directories(${CMAKE_BINARY_DIR})

  set(CMAKE_INCLUDE_CURRENT_DIR ON)

  set(CMAKE_AUTOUIC ON)
  set(CMAKE_AUTOMOC ON)
  set(CMAKE_AUTORCC ON)

  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)

  add_executable(${TEST_NAME} ${TEST_NAME}.h ${TEST_NAME}.cpp)

  ROBOCIN_LINK_QT6_LIBRARIES(${TEST_NAME} Test)
endmacro()

macro(ROBOCIN_LINK_AND_INCLUDE_DIR TARGET_NAME DIR_PATH)
  target_link_directories(${TARGET_NAME} PUBLIC ${DIR_PATH})
  target_include_directories(${TARGET_NAME} PUBLIC ${DIR_PATH})
endmacro()

macro(ROBOCIN_LINK_OPENGL TARGET_NAME)
  find_package(OpenGL REQUIRED)
  find_package(GLUT REQUIRED)

  target_include_directories(${TARGET_NAME} PUBLIC ${OPENGL_INCLUDE_DIRS} ${GLUT_INCLUDE_DIRS})
  target_link_libraries(${TARGET_NAME} PUBLIC ${OPENGL_LIBRARIES} ${GLUT_LIBRARY})
endmacro()

macro(ROBOCIN_LINK_PROTOBUF TARGET_NAME)
  include(FindProtobuf)
  find_package(Protobuf REQUIRED)
  target_link_libraries(${TARGET_NAME} INTERFACE ${Protobuf_LIBRARIES})
  target_include_directories(${TARGET_NAME} PUBLIC ${PROTOBUF_INCLUDE_DIR})
endmacro()

macro(ROBOCIN_LINK_FUNDAMENTAL_LIBRARIES TARGET_NAME)
  ROBOCIN_LINK_OPENGL(${TARGET_NAME})
  ROBOCIN_LINK_PROTOBUF(${TARGET_NAME})
  ROBOCIN_LINK_QT6_LIBRARIES(${TARGET_NAME} Widgets Core Gui OpenGL OpenGLWidgets Concurrent Network Test Svg)
endmacro()

macro(ROBOCIN_DOXYGEN_CUSTOM_TARGET TARGET_NAME ROOT_PATH)
  find_package(Doxygen)

  if (Doxygen_FOUND)
    set(DOXYGEN_IN ${ROOT_PATH}/docs/Doxyfile)
    set(DOXYGEN_OUT ${ROOT_PATH}/build/Doxyfile.out)

    configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)

    add_custom_target(${TARGET_NAME}
            COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
            WORKING_DIRECTORY ${ROOT_PATH}/docs
            COMMENT "Generating API documentation with Doxygen"
            VERBATIM)
  else ()
    message(Doxygen was not found.)
  endif ()
endmacro()
