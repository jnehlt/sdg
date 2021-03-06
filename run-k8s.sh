#!/usr/bin/env bash

source ./scripts/funcs.sh

(
    cd kubernetes
    c_echo "green" "Providing kubernetes stack..."
    deps_check

    vagrant up
    check_exitstatus

    c_echo "green" "Wait for all nodes to be in Ready state"
    vagrant ssh master -c "kubectl wait --for=condition=Ready nodes --all 1>& /dev/null; kubectl get nodes -o wide"
    check_exitstatus

    c_echo "yellow" "Sleeping for 5sec before cleanup..."
    sleep "5"

    c_echo "green" "Cleaning up..."
    vagrant destroy --force
    check_exitstatus

    rm -f  $(find . -type f -name "join-command")
    rm -rf $(find . -type d -name ".vagrant")
)

c_echo "blue" "Thank's alot."