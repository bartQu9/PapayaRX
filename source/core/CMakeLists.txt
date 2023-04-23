configure_file(include/PapayaRX_comp_time_cfg.hh.in include/PapayaRX_comp_time_cfg.hh)
target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_BINARY_DIR/include}")

target_include_directories(${PROJECT_NAME} PUBLIC include)

target_sources(${PROJECT_NAME} PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/source/main.cc
)