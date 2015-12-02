#!/bin/bash

git add .
git commit -am "컨텐츠 업데이트"
git push
hugo -d dist
sh deploy.sh
