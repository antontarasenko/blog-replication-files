#!/usr/bin/env bash

# If you get an error, get the files at
# https://www.kaggle.com/c/leapfrogging-leaderboards/data
# and put them in
# input/

mkdir input
cd input

curl -s -O 'https://www.kaggle.com/c/leapfrogging-leaderboards/download/ALL_LEADERBOARDS.zip'
curl -s -O 'https://www.kaggle.com/c/leapfrogging-leaderboards/download/teams.csv'
wait
unzip ALL_LEADERBOARDS.zip -d 'ALL_LEADERBOARDS'
