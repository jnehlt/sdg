#!/usr/bin/env bash

source ./scripts/funcs.sh

(
    cd terraform
    c_echo "green" "Providing vpss stack..."
    deps_check

    terraform init
    check_exitstatus

    terraform apply -auto-approve
    check_exitstatus

    c_echo "yellow" "Sleeping for 5sec before cleanup..."
    sleep "5"

    c_echo "green" "Cleaning up..."
    terraform destroy -auto-approve
    check_exitstatus
    cd ../packer
    vagrant destroy --force
    check_exitstatus

    cd ../
    rm -rf $(find . -type d -name ".terraform")
    rm -f  $(find . -type f -name "*tfstate*")
    rm -rf $(find . -type d -name ".vagrant")
    rm -rf $(find . -type d -name "keys")
    rm -rf $(find . -type d -name "packer_cache")
    rm -rf $(find . -type d -name "*.box")
)

c_echo "blue" "Thank's alot."