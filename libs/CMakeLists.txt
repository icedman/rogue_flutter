cmake_minimum_required(VERSION 3.10)
project(api LANGUAGES CXX C)

add_library(api
  SHARED
  ./api.cpp
  exports.def
)