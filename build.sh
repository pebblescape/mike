#!/bin/bash

eval `ssh-agent -s`
chmod 600 deploy.pem
ssh-add deploy.pem

git config user.email "travis@rang.ee"
git config user.name "Travis CI"

git checkout -- .
git remote add github git@github.com:pebblescape/mike.git || exit
git fetch github || exit
git checkout -t -b build github/build || exit
git rebase github/master
git push github build
