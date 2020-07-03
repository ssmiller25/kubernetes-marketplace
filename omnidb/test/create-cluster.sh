#!/bin/sh

cname="adminer-test"
crun="docker run -it --rm -v /home/steve/.civo.json:/.civo.json civo/cli:latest"

$crun k3s create ${cname} -n 3 --size g2.small --wait
$crun k3s config ${cname} > ${HOME}/.kube/${cname}
export KUBECONFIG=${HOME}/.kube/${cname}
$crun k3s apps add Longhorn --cluster ${cname}
#$crun k3s apps add KubeDB --cluster ${cname}
