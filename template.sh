#!/bin/bash
# License: Apache-2.0
# editor: haifengsss@163.com
# dependencies: cat dirname grep awk sed md5sum echo

set -eo pipefail

file_name=$1

# 结尾符, 用来保留空行
end_token="___end___"
# 临时目录
tmp_work_base_dir="/tmp/.bash_template"
# 去除注释
# doc=$(grep -v '{#.*#}' ${file_name}; echo "${end_token}")
rm_cmd=/bin/rm

indent_from_stdin(){
    local space_count=${1:-0} first_indent=${2:-0}
    local space_num=""
    for((i=0;i<${space_count};i++));do
        space_num="${space_num} "
    done
    # 判断是否要对首行进行缩进，默认不进行，即使用此函数时，要将其放到合适的缩进处
    #if [[ ${first_indent} == 0 ]];then
    #    for((i=0;i<${space_count};i++));do
    #        printf "\b"
    #    done
    #fi
    #while read line; do 
    #    # printf 不能保证百分百的原样输出，所以改用 awk, 比如原文本为 '\""', 其就会将 \ 给去掉
    #    printf  "%s%s\n" "${space_num}" "${line}"
    #done
    awk -v space="${space_num}" -v first_indent="${first_indent}" '{
        if (first_indent == "0" && NR == 1){
            print $0
        } else {
            print space$0
        }
    }'
}

# 引入某个文件时，控制是否缩进的函数
# 第一个参数是缩进的类型，file or var
# 第二个参数是文件名, 或者变量名
# 第三个参数是缩进空格数
# 第四个参数，0或者大于0，用于判断是否首行缩进的
indent_file_or_var(){
    local indent_type="${1}" source_name="$2" space_count=${3:-0} first_indent=${4:-0}
    local space_num=""
    for((i=0;i<${space_count};i++));do
        space_num="${space_num} "
    done
    # 判断是否要对首行进行缩进，默认不进行，即使用此函数时，要将其放到合适的缩进处
    #if [[ ${first_indent} == 0 ]];then
    #    for((i=0;i<${space_count};i++));do
    #        printf "\b"
    #    done
    #fi
    if [ "${indent_type}" == "file" ];then
        #while read line; do 
        #    printf  "%s%s\n" "${space_num}" "${line}"
        #done < "${source_name}"
        awk -v space="${space_num}" -v first_indent="${first_indent}" '{
            if (first_indent == "0" && NR == 1){
                print $0
            } else {
                print space$0
            }
        }' "${source_name}"
    elif [ "${indent_type}" == "var" ];then
        #while read line; do 
        #    printf  "%s%s\n" "${space_num}" "${line}"
        #done <<< "${source_name}"
        awk -v space="${space_num}" -v first_indent="${first_indent}" '{
            if (first_indent == "0" && NR == 1){
                print $0
            } else {
                print space$0
            }
        }' <<< "${source_name}"
    else
        printf "the indent_type is error with ${indent_type}\n" >&2
        return 1
    fi
}

# 将文件内容渲染至模板当中，可以保持文件原样内容，即使其中有 bash 语句
load_file(){
    local file_name=$1 space_count=${2:-0} first_indent=${3:-0}
    echo '{%raw%}'
    indent_file_or_var file "${file_name}" ${space_count} ${first_indent}
    echo '{%endraw%}'
}

# 第一个参数是数组名
# 第二个参数可以省略，是缩进的层级
# 第三个参数，0或者大于0，用于判断是否首行缩进的
yaml_dump_array(){
    local arr_name=$1 layer=${2:-0}
    local first_indent=${3:-0} arr=()
    eval arr=(\"\${${arr_name}[@]}\")
    local arr_len=${#arr[@]}
    #printf '  -' {1..10}
    # 存储空格数量
    local space_num=""
    if [[ ${layer} == 0 ]];then
        #printf '\b - %s\n'  "${arr[@]}"
        for ((i=0;i<${arr_len};i++));do
            echo "- ${arr[${i}]}"
        done
    else
        layer=$((layer*2))
        for((i=0;i<${layer};i++));do
            space_num="${space_num} "
        done
        # 判断是否要对首行进行缩进，默认不进行，即使用此函数时，要将其放到合适的缩进处
        for ((i=0;i<${arr_len};i++));do
            if [[ ${first_indent} == 0 && ${i} -eq 0 ]];then
                echo "- ${arr[${i}]}"
            else
                echo "${space_num}- ${arr[${i}]}"
            fi
        done
        #if [[ ${first_indent} == 0 ]];then
        #    for((i=0;i<${layer};i++));do
        #        printf "\b"
        #    done
        #fi
        #printf "${space_num}- %s\n"  "${arr[@]}"
    fi
}


yaml_dump_map(){
    local arr_name=$1 k_arr=() v_arr=() k_len=0
    local layer=${2:-0}  first_indent=${3:-0}
    eval v_arr=(\"\${${arr_name}[@]}\") k_arr=(\"\${!${arr_name}[@]}\")
    k_len=${#k_arr[@]}
    # 存储空格数量
    local space_num=""
    if [[ ${layer} == 0 ]];then
        for((i=0;i<${k_len};i++));do
            echo '%s: "%s"'  "${k_arr[${i}]}" "${v_arr[${i}]}"
        done
    else
        layer=$((layer*2))
        for((i=0;i<${layer};i++));do
            space_num="${space_num} "
        done
        # 判断是否要对首行进行缩进，默认不进行，即使用此函数时，要将其放到合适的缩进处
        for((i=0;i<${k_len};i++));do
            if [[ ${first_indent} == 0 && ${i} -eq 0 ]];then
                echo "${k_arr[${i}]}: \"${v_arr[${i}]}\""
            else
                echo "${space_num}${k_arr[${i}]}: \"${v_arr[${i}]}\""
            fi
        done
    fi
    #echo "${key_arr[@]}"
    #eval echo "\${${arr}[${key_arr[0]}]}"
}

help_f(){
    printf "Bash template solution, like Jinja2 in Python\n"
    printf "LICENSE: Apache-2.0\n"
    printf "examples:\n"
    local the_main="${0}"
    #printf "the FUNCNAME '%s' in help_f\n" "${FUNCNAME[@]}"
    #printf "the 0 is '%s' in help_f\n" "${0}"
    if [[ "${the_main}" =~ .*\.sh ]];then
        :
    else
        if [[ "${FUNCNAME[1]}" == "template" ]];then
            the_main="${FUNCNAME[1]}"
        fi
    fi
    printf "    ${the_main} file1.yml\n\n"
}
__template_base(){
    local file_name=$1
    if [ ! -e "${file_name}" ];then
        printf "the ${file_name} isn't exist.\n"
        return 1
    fi
    # 生成临时文件
    local file_base_name="${file_name##*/}" 
    local file_dir_name="$(dirname ${file_name})"
    # md5 value
    # 使用 md5 的原因是防止文件名长导致的失败
    # TODO: 这里每次递归的时候都会产生新的 md5 值, 这就导致在匹配临时目录时，匹配失败
    #       考虑加一个参数, 有 md5 值时，则直接使用此值
    local file_name_md5value=$(md5sum <<< "${file_name}")
    file_name_md5value="${file_name_md5value%% *}"
    # 这个临时目录是用来存放 {%raw%} 段的文件的
    #local tmp_work_dir="${tmp_work_base_dir}/${file_base_name}"
    local tmp_work_dir="${tmp_work_base_dir}/${file_name_md5value}"
    mkdir -p ${tmp_work_dir}
    # 切换工作目录至文件所在的目录
    cd ${file_dir_name}
    # 这个文件是指去掉注释后的临时文件
    #local tmp_file_name=".__no_comment_${file_base_name}"
    local tmp_file_name=".__no_comment_${file_name_md5value}"
    #cd ${tmp_work_dir}
    # 预处理，去掉注释
    grep -v '{#.*#}' ${file_name} > ${tmp_file_name}
    # 如果去掉注释后的文件中，没有需要渲染的内容，则直接返回
    if ! grep -E '\$\(|\$\{' ${tmp_file_name} &> /dev/null; then
        cat ${tmp_file_name}
        ${rm_cmd} -f ${tmp_file_name}
        return 0
    fi 
    #############################################################
    local raw_line_array=() 
    # 获取其内的注释段的行数
    raw_line_array=($(awk 'BEGIN{i=1;j=1}
       /^[[:space:]]*{%.*%}[[:space:]]*$/{
           if($0 ~ /{%\s*raw\s*%}/){
               raws[i]=NR; i++
           } 
           if($0 ~ /{%\s*endraw\s*%}/){
               endraws[j]=NR; j++
           }
       }
       END{
           raws_length=length(raws)
           endraws_length=length(endraws)
           if (raws_length != endraws_length) {
               print("error")
               exit
           }
           if (raws_length == 0) {
               print("0")
               exit
           }
           for (k=1;k<=raws_length;k++){
               if (endraws[k] < endraws[k+1]) {
                   print("error1")
                   exit
               }
           }
           for (k=1;k<=raws_length;k++){
               print raws[k]"_"endraws[k]; 
           } 
       }' ${tmp_file_name}))
    #
    if [ "${raw_line_array[0]}" == "error" ];then
        #printf "the raw line is error\n" >&2
        echo "there is an error where the {%raw%} or {%endraw%} is absent" >&2
        return 1
    fi
    if [ "${raw_line_array[0]}" == "error1" ];then
        echo "the {%raw%} can not include another {%raw%}" >&2
        return 1
    fi
    # 
    #echo ${raw_line_array[@]}
    # 获得文件的行号
    local file_line=$(wc -l ${tmp_file_name})   
    file_line=${file_line% *} 
    # 获得原始注释开始的行号，和实际内容的行号
    local raw_begin_line_num=0 raw_end_line_num=0
    local raw_content_begin_line_num=0 raw_content_end_line_num=0
    # 存放原始内容的临时文件
    local tmp_raw_content_file=""
    local sed_cmd=""
    if [ "${raw_line_array[0]}" != "0" ];then
        sed_cmd=$(for raw_line in ${raw_line_array[@]};do
            raw_begin_line_num=${raw_line%_*}   
            raw_content_begin_line_num=$((raw_begin_line_num+1))
            raw_end_line_num=${raw_line#*_}
            raw_content_end_line_num=$((raw_end_line_num-1))
            tmp_raw_content_file="${tmp_work_dir}/__raw_${file_line}_${raw_begin_line_num}_${raw_end_line_num}.txt"
            touch ${tmp_raw_content_file}
            # 将原始内容写至临时文件当中
            sed -n "${raw_content_begin_line_num},${raw_content_end_line_num}w ${tmp_raw_content_file}" ${tmp_file_name}
            printf "${raw_begin_line_num},${raw_content_end_line_num}d;${raw_end_line_num}s#.*#${tmp_raw_content_file}#;"
        done)
    fi
    # 生成没有 {%raw%}  的临时文件
    #local tmp_file_name_no_raw=${file_dir_name}/.__no_raw_${file_base_name}
    local tmp_file_name_no_raw=${file_dir_name}/.__no_raw_${file_name_md5value}
    # doc 用于存储文件内容
    # tmp_file_to_render 用来存储要被渲染的文件名，有些文件因为存在 {%raw%}，所以会生成 .__no_raw 文件，有的则不会
    local doc="" tmp_file_to_render=""
    # 如果需要分离 {%raw%} 则执行
    if [ -n "${sed_cmd}" ];then
        eval sed "'${sed_cmd}'" ${tmp_file_name} > ${tmp_file_name_no_raw}
        ${rm_cmd} ${tmp_file_name}
    fi
    # 获取要被渲染的文件
    if [ -e "${tmp_file_name_no_raw}" ];then
        tmp_file_to_render=${tmp_file_name_no_raw}
    else
        tmp_file_to_render=${tmp_file_name}
    fi
    # 获取文件内容
    doc=$(cat ${tmp_file_to_render}; printf "${end_token}\n")
    # 
    local tmp_render_file=${file_dir_name}/.__tmp_render_${file_name_md5value}
    # 如果有需要写回文件的 raw 内容, 则不去掉末尾的结尾符
    # 在这里判断是不太成立的，因为递归的情况下，会将不该替换掉的，也给替换掉, 所以改为在下个函数内进行操作
    #if grep "^${tmp_work_dir}.*\.txt$" ${tmp_file_to_render} &> /dev/null;then
    # printf 在这里有些问题, 主要是 % 转义时
    #eval 'printf "'"${doc}"'"' > ${tmp_render_file}
    eval 'echo "'"${doc}"'"' > ${tmp_render_file}
    #else
    #    eval 'echo "'"${doc}"'"' | sed 's/'${end_token}'//' > ${tmp_render_file}
    #    eval 'echo "'"${doc}"'"' > ${tmp_render_file}
    #fi
    #sleep 60
    # 删除临时文件
    ${rm_cmd} ${tmp_file_to_render}
    # 检查 tmp_render_file 中是否存在需要继续渲染的内容
    if grep -E '\$\(|\$\{' ${tmp_render_file} &> /dev/null; then
        __template_base ${tmp_render_file}
        ${rm_cmd} ${tmp_render_file}
    else
        cat ${tmp_render_file}
        ${rm_cmd} ${tmp_render_file}
    fi 
    
}

# 将 {%raw%} 的内容回写至文件内
# 去除 ${end_token} 保留末尾的空行
template(){
    local file_name="${1}"
    if [ -n "${file_name}" ];then
        if [[ "${file_name}" == "-h" || "${file_name}" == "--help" ]];then
            help_f
            return 0
        fi
        #
        if [ -f "${file_name}" ];then
            :
        else
            printf "the file is not exist.\n"
            return 1
        fi
    else
        printf "please provide a file name.\n"
        help_f
        return 1
    fi
    #
    local file_base_name="${file_name##*/}" 
    local file_name_md5value=$(md5sum <<< "${file_name}")
    file_name_md5value="${file_name_md5value%% *}"
    local tmp_work_dir="${tmp_work_base_dir}/${file_name_md5value}" doc=""
    mkdir -p ${tmp_work_dir}
    local tmp_file_to_render=${tmp_work_dir}/__to_render.txt
    __template_base ${file_name} > ${tmp_file_to_render}
    # 那些被分离出来的 {%raw%} 的文件
    # tmp_raw_file_line_num 是指文件路径的行数
    # append_file_line 是指文件路径的上一行，从这里开始添加文件内容
    local tmp_raw_files="" tmp_raw_file_line_num=0 append_file_line=0 tmp_raw_file_path=""
    local sed_cmd=""
    if tmp_raw_files=$(grep -n "^${tmp_work_base_dir}/.\{32\}/.*\.txt$" ${tmp_file_to_render}); then
        #doc=$(sed 's#\(^'${tmp_work_dir}'.*\.txt$\)#\$\(cat \1\)#' ${tmp_file_to_render})
         #${tmp_file_to_render}
        sed_cmd=$(
            printf "sed"
            for tmp_raw_file in ${tmp_raw_files};do
                tmp_raw_file_line_num="${tmp_raw_file%:*}"
                tmp_raw_file_path="${tmp_raw_file#*:}"
                append_file_line=$((tmp_raw_file_line_num-1))
                printf " -e '${tmp_raw_file_line_num}d;${append_file_line}r ${tmp_raw_file_path}'"
            done
            printf " -e '/${end_token}/d'")
            #printf " -e 's/${end_token}//'")
        #eval sed "'${sed_cmd}'" ${tmp_file_to_render}
        eval ${sed_cmd} ${tmp_file_to_render}
        # 最后这一下子，不能使用 eval 来进行
        #eval 'echo "'"${doc}"'"' | sed 's/'${end_token}'//'
    else
        sed '/'${end_token}'/d' ${tmp_file_to_render}
    fi
    # 删除临时目录
    ${rm_cmd} -r ${tmp_work_dir}
    
}
export -f indent_from_stdin
export -f indent_file_or_var
export -f yaml_dump_array
export -f yaml_dump_map
export -f load_file
#export __template_base
export -f template

function main(){
    if [ "${FUNCNAME[1]}" != "source" ];then
        template ${file_name}
    else
        set +e
        set +o pipefail
    fi
}

main
