source ../template.sh 
export nums=({1..10})
declare -A labels=([app]="hello" [version]="v1" [hf.io/desc]="test")
export labels
