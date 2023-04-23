cmake_minimum_required(VERSION 3.13)

project(PapayaRX)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_BUILD_TYPE Debug)

find_package(Gnuradio 3.10 REQUIRED COMPONENTS analog blocks digital filter fft soapy)
find_package(spdlog 1.9.0 REQUIRED)
find_package(Boost 1.74.0 REQUIRED COMPONENTS program_options)

add_executable(${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
  gnuradio::gnuradio-blocks
  gnuradio::gnuradio-digital
  gnuradio::gnuradio-filter
  gnuradio::gnuradio-soapy
  Volk::volk
  spdlog::spdlog
  Boost::program_options  
)

add_subdirectory(source)