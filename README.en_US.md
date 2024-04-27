# README.md

- en [English](README.en_US.md)
- zh_CN [简体中文](readme/README.md)

# bash template


Bash template solution, like Jinja2 in Python.

The `envsubst` command is too simple, it can only replace variables.
If you want to use the effects of jinja2 or help template, then it won't work.

But sometimes, I just want to achieve a simple template effect, and the environment is not very convenient to install these tools.

So does Bash have a template solution?

I couldn't find it, so I'll figure it out for myself.



# examples

## a simple template

```yaml
# test2.yml
name: $(pwd)
age: $(echo 18)
$(cat test3.yml)
```

```bash
#### env_var.sh in test dir
# source env_var.sh
# template test2.yml 
name: /opt/mycode/bash_template/test
age: 18
name: "I'm test3.yml"

```

## only load a file

```yaml
# cat test_import_script_2.yml 
script3: |
  $(
    load_file test_script.sh 2 1
  )

```

```bash
# cat test_script.sh 
#!/bin/bash
str="My name is test_script"
echo "${str}"
```

the result
```bash
# template test_import_script_2.yml 
script3: |
  #!/bin/bash
  str="My name is test_script"
  echo "${str}"

```

## a complex example 

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

## create a deployment, service and ingress of k8s

```bash
# cd examples/k8s/svc1/
# source svc_var.sh 
# template svc1_resources.yml 

```


# functions

* `indent_from_stdin`: check in `test/test_indent_from_stdin.yml`
* `indent_file_or_var`: check in `test/test_indent_file.yml` and `test/test_indent_var.yml`
* `yaml_dump_array`: check in `test/test_yaml_dump_array.yml`
* `yaml_dump_map`: check in `test/test_yaml_dump_map.yml`
* `load_file`: check in `test/import_script/test_import_script_2.yml`


