#!/bin/bash
str=\"${nums[@]}\"

{%raw%}
echo "${str}"
str1="this is raw str1"
echo "${str1}"
{%endraw%}
