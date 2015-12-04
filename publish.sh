#!/bin/bash

git add .
git commit -am "컨텐츠 업데이트"
git push
if [[ -d "dist" ]]; then
    rm -rf dist
fi
#hugo -d dist
#./deploy.sh
