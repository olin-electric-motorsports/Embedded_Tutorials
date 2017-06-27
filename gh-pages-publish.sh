#!/bin/bash
gitbook install && gitbook build
git checkout gh-pages
cp -R _book/* .
git clean -fx node_modules
git clean -fx _book
gid add .
git commit -a -m "Update docs"
git push origin gh-pages
git checkout master
