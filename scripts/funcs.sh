#!/usr/bin/env bash

function c_echo (){
    case "$1" in
        "black")   tput setaf 0 ;;
        "red")     tput setaf 1 ;;
        "green")   tput setaf 2 ;;
        "yellow")  tput setaf 3 ;;
        "blue")    tput setaf 4 ;;
        "magenta") tput setaf 5 ;;
        "cyan")    tput setaf 6 ;;
        "white")   tput setaf 7 ;;
        *)         tput setaf 0 ;; # black
    esac
    echo -e "$2" # Print message
    tput setaf 7
}

function is_su (){
    [[ ${EUID:-$(id -u)} -eq 0 ]] && true || false
}

function deps_check (){
    deps=("ansible" "packer" "terraform" "vagrant" "virtualbox")
    for dep in ${deps[@]}; do
        command -v "${dep}" 1>& /dev/null
        if [[ $? -ne 0 ]]; then
            c_echo "red" "${dep} installation was not found\nExiting..."
            exit 1;
        fi
        c_echo "yellow" "${dep} installation found"
    done
    return 0;
}

function check_exitstatus (){
    [[ $1 -ne 0 ]] && exit 2
}