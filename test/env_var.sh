#!/bin/bash

#echo "${BASH_SOURCE[@]}"
#echo "$0"

if [[ "${0}" =~ .*\.sh ]];then
    the_source=$0
else
    the_source=${BASH_SOURCE[0]}
fi
my_path="$(cd "$(dirname "${the_source}")"; pwd)"


source ${my_path}/../template.sh 
export nums=({1..10})
export names=("sun wukong" "zhu bajie" "sha heshang")
declare -A labels=([app]="hello" [version]="v1" [hf.io/desc]="test app in template")
export labels

set +e
