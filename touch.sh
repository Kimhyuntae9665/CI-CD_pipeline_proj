#!/bin/bash

current_date=$(date +"%Y%m%d_%H%M%S")


git add .
git commit -m "auto_commit_${current_date}"
git push -u origin main