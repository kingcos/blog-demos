#!/bin/sh
c++ -g -O2 -DUSE_CF=1 -framework CoreFoundation NaiveArray.cpp arrays.cpp -o cfarray
c++ -g -O2 -DUSE_NAIVE=1 -framework CoreFoundation NaiveArray.cpp arrays.cpp -o naivearray
c++ -g -O2 -DUSE_VECTOR=1 -framework CoreFoundation NaiveArray.cpp arrays.cpp -o vectorarray
