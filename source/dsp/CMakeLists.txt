target_include_directories(${PROJECT_NAME} PUBLIC include)

target_sources(${PROJECT_NAME} PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/source/FlowGraphHandler.cc
)