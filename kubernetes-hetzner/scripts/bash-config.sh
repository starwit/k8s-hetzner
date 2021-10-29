#!/bin/bash

# some useful basrc stuff
alias tf="tail -f"
alias dir="ls -al --color"
alias cd..="cd .."
alias cd~="cd ~"

# set red PS1 for root
if [[ "`id -u`" -eq 0 ]]; then
        echo "root"
        PS1='\[\033[01;31m\]\u@\h\[\033[01;33m\] \w \n\$\[\033[00m\] '
else
        PS1='\[\033[01;32m\]\u@\h\[\033[01;33m\] \w \n\$\[\033[00m\] '
fi

function net_listen {
        echo "***************** UDP listener *******************"
        netstat -anp | grep -vi unix | grep -vi established | grep -i udp 
        echo "***************** TCP listener *******************"
        netstat -anp | grep -vi unix | grep -i listen
}

function net_open {
        echo "***************** Connections *******************"
        netstat -anp | grep -i 'udp\|tcp' | grep -i 'ESTABLISHED\|CLOSE_WAIT\|TIME_WAIT'
}

function net_all {
        net_listen
        net_open
}

# Kubernetes stuff
function kwatch {
    if [ $1 ]; then
        watch -n 1 kubectl get all -o wide -n $1;
    else
        watch -n 1 kubectl get all -o wide --all-namespaces
    fi
}

# K8s stuff
if [ -x "$(command -v kubectl)" ]
then
    source <(kubectl completion bash)
fi

# helm stuff
if [ -x "$(command -v helm)" ]
then
    source <(helm completion bash)
fi

export KUBECONFIG=~/.kube/config

# PATH
export PATH=$PATH:~/bin