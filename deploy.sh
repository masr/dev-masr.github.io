#!/bin/bash -e
jekyll build
rm -rf ../static.masr.github.io/*
cp -r _site/* ../static.masr.github.io/
cd ../static.masr.github.io/
git add -A
git commit -m"jekyll static"
git push origin master 
