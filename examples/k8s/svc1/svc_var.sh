app_name=svc1
app_namespace=default
app_image="nginx:1.23.2"
app_replicas=3
app_ingress_class=nginx
http_port=8080
https_port=8443
declare -A labels=([app]=${app_name} [version]="v1" [hf.io/desc]="the svc1 is a test service")
declare -A annotations=([kubernetes.io/change-cause]="create the service in $(date)")
export labels app_name app_namespace app_image app_replicas http_port https_port annotations
source ../../../template.sh

#strs=("abc def" "haha hehe")
#yaml_dump_array strs
#yaml_dump_map labels

