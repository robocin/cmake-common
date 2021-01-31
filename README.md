# cmake-common 🏗️

*Esse repositório tem como objetivo apenas armazenar arquivos* `.cmake` *para funcionar como submódulo de outros projetos maiores que utilizem a buildsystem CMake;*

## Regras:

- ***Todo conteúdo do repositório encontra-se no arquivo* `utils.cmake`;**
    - Para cada função ou macro criada:
        - Adicionar o prefixo `ROBOCIN_`;
        - Manter sempre no padrão SNAKE_CASE;

    _ex:_

    ```CMake
    macro(ROBOCIN_LINK_PROTOBUF TARGET_NAME)
      include(FindProtobuf)
      find_package(Protobuf REQUIRED)
      target_link_libraries(${TARGET_NAME} INTERFACE ${Protobuf_LIBRARIES})
      target_include_directories(${TARGET_NAME} PUBLIC ${PROTOBUF_INCLUDE_DIR})
    endmacro()

    function(ROBOCIN_APPEND_QT5_PREFIX_PATH OUTPUT_DIRS)
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
    ```
