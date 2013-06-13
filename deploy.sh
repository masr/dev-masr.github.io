#!/bin/bash -e
jekyll build
rm -rf ../_site/
cp -r _site ../_site
#git add -A
#git commit -m"jekyll dev"
#git push origin dev
git checkout master
rm -rf *
dads
cp -r ../_site/* .
rm -rf ../_site/
git add -A
git commit -m"jekyll static"
git push origin master
git checkout dev
