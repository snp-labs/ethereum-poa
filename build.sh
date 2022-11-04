#!/bin/bash

cd go-ethereum && make all -j 8 && cd .. 
cp ./go-ethereum/build/bin/geth ./release/
cp ./go-ethereum/build/bin/puppeth ./release/