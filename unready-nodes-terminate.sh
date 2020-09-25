#!/bin/bash
while true
do 
for i in $(kubectl get nodes | grep Ready | awk 'NF{NF-=4};1'); do
echo "Nodes   $i is Not Ready"
id=$(kubectl get no $i -o=custom-columns=ID:spec.providerID |  tail -n +2)
insatnceid=${id##*/}
date1=$(kubectl get no $i -o=custom-columns=AGE:metadata.creationTimestamp |  tail -n +2)
date2=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
nodeage=$(printf "%s\n" $(( $(date -d "$date2" "+%s") - $(date -d "$date1" "+%s") )))
echo " node age is $nodeage seconds "
if [ "$nodeage" -gt "300" ];then
echo "Node $i age is moretan 5 min "
echo " Node $i instance id is $insatnceid "
fi
done
echo " All Nodes terminated  successfully "
sleep 120s
done
