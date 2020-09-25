#!/bin/bash
REGION=eu-west-1
while true
do
echo " Running the node termination script "
for i in $(kubectl get nodes | grep NotReady | awk 'NF{NF-=4};1'); do
  echo "Nodes   $i is Not Ready"
  id=$(kubectl get node $i -o=custom-columns=ID:spec.providerID |  tail -n +2)
  insatnceid=${id##*/}
date1=$(kubectl get node $i -o=custom-columns=AGE:metadata.creationTimestamp |  tail -n +2)
date2=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
nodeage=$(printf "%s\n" $(( $(date -d "$date2" "+%s") - $(date -d "$date1" "+%s") )))
echo " node age is $nodeage seconds "
if [ "$nodeage" -gt "300" ];then
  echo "Node $i age is moretan 5 min "
  echo " Node $i instance id is $insatnceid "
  echo " Delete the all the pods from the node $i "
  kubectl delete pods  --grace-period=0 --force  --all-namespaces --field-selector spec.nodeName=$i
  echo " Terminating the instance "
  aws ec2 terminate-instances --instance-ids $insatnceid --region ${REGION}
  echo " Terminated the NotReady node "
  echo " Remove the node from cluster "
  kubectl  delete node $i
  echo " Removed the node $i from cluster "
fi
echo " All  NotReady Nodes terminated  successfully "
done
sleep 60s
done
