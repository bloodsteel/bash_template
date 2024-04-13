# README.md

- en [English](README.en_US.md)
- zh_CN [简体中文](README.md)

# bash template

这是一个 bash 的 template 方案。

`envsubst` 太简单了，只能实现变量的替换。
如果想使用 `jinja2` 或者 `helm template` 的效果，那就不行了。

但是有的时候，只是想实现一个简单的模板效果，而且环境也不太方便安装这些工具。

那么 `bash` 是否有 `template` 方案呢?

没搜到，那么自己琢磨一个吧。

# 支持的功能

* 判断
* 循环
* 数组，关联数组
* 支持注释
    * 使用类似 `jinja2` 的形式 `{# "comment: this is a comment" #}`
    * 目前只考虑单行注释
    * 这一步应该在第一步进行
* 支持文档内存在真正的脚本内容: 
    * 即不把真正的内容进行替换, 需要添加类似于 `jinja2` 的 `{%raw%}{%endraw%}`
* 模板继承, 比如在一个模板中，引用其他文件 `$(cat /tmp/test2.yml)`


# examples

## 基本使用

```yaml
# test2.yml
name: $(pwd)
age: $(echo 18)
$(cat test3.yml)
```

```bash
##test_source.sh 脚本在 test 目录下
# source test_source.sh
# template test2.yml 
name: /opt/mycode/bash_template/test
age: 18
name: "I'm test3.yml"

```

## 一个带有注释的复杂的案例

```yaml
$(cat test2.yml)
---
apiVersion: v1
kind: Service
metadata:
  name: ${HOSTNAME}
  labels:
    age: $(if [ "a" == "a" ];then echo 19; else echo 20; fi)
    $(if [ "abc" == "abc" ];then 
        printf "label: abc"
    fi)
    {# "comment: this is a comment" #}
    # this is a comment
    $(a=0; for i in ${!labels[@]};do
        if [ ${a} == 0 ];then
            printf "%s: %s\n" "${i}" "${labels[${i}]}" 
        else
            printf "    %s: %s\n" "${i}" "${labels[${i}]}"
        fi
        a=$((a+1))
    done)
numbers:
$(for i in ${nums[@]};do
    printf "  - ${i}\n"
done)
shell: |
  {%raw%}
  a="name"
  if [ "${a}" == "name" ];then
      echo "hahah"
  else
      echo "heheh"
  fi
  {%endraw%}

shell2: |
  {% raw %}
  a="name"
  if [ "${a}" == "name" ];then
      echo "hahah"
  else
      echo "heheh"
  fi
  {% endraw %}

```

执行结果
```bash
# template test1.yml
name: /opt/mycode/bash_template/test
age: 18
name: "I'm test3.yml"
---
apiVersion: v1
kind: Service
metadata:
  name: wanghaifeng-test
  labels:
    age: 19
    label: abc
    # this is a comment
    version: v1
    hf.io/desc: test
    app: hello
numbers:
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
  - 10
shell: |
  a="name"
  if [ "${a}" == "name" ];then
      echo "hahah"
  else
      echo "heheh"
  fi

shell2: |
  a="name"
  if [ "${a}" == "name" ];then
      echo "hahah"
  else
      echo "heheh"
  fi





```

## 一个实际的创建k8s资源的案例

```bash
# cd examples/k8s/svc1/
# source svc_var.sh 
# template svc1_resources.yml 

```


# 一些关于yaml的函数

* `indent_from_stdin`: 运行在管道后的函数，控制缩进，示例见 `test/test_indent_from_stdin.yml`
* `indent_file_or_var`: 针对文件或者多行变量进行缩进的函数，示例见 `test/test_indent_file.yml` and `test/test_indent_var.yml`
* `yaml_dump_array`: 将数组打印为 yaml 形式, 示例见 `test/test_yaml_dump_array.yml`
* `yaml_dump_map`: 将关联数组打印为 yaml 形式，示例见 `test/test_yaml_dump_map.yml`


