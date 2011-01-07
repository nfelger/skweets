#!/bin/bash
rvm use 1.8.7 -S app.rb &
rvm use 1.8.7 -S lib/tweet_worker.rb &

