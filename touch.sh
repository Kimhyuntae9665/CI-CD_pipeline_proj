#!/bin/bash
count = 1

git add .
git commit -m "auto_commit_${count}"
git push -u origin main
