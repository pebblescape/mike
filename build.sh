#!/bin/bash

eval `ssh-agent -s`
chmod 600 .travis/deploy.pem
ssh-add .travis/deploy.pem

git config user.email "travis@rang.ee"
git config user.name "Travis CI"

git checkout -- . || exit
git remote add github git@github.com:pebblescape/mike.git || exit
git fetch github || exit
git checkout -t -b build github/build || exit
git merge github/master --no-edit || exit
git push github build
