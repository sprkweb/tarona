#!/bin/sh
bin_path=$(dirname -- "$0")
proj_path=$(dirname -- "$bin_path")
jruby_path=$proj_path/vendor/jruby.jar

if [ -n $(which java) ] && [ -r $jruby_path ]
then
  java -jar $jruby_path $bin_path/tarona
else
  echo 'No available embedded Ruby is detected.'
  echo 'If you have installed Ruby, run the tarona file.'
fi
