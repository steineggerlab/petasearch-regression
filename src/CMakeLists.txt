cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)
project(MMseqs_benchmark)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11")

add_executable(evaluate_results EvaluateResults.cpp EvaluateResults.h)
