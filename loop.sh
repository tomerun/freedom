#!/bin/bash

i=100
while [ $i -lt 200 ]; do
	./some_executable
	i=$(( i + 1 ))
done
