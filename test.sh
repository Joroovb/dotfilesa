#!/bin/bash

comment() {
    echo ">> $(tput setaf 2) $@$(tput sgr0)" >&2
}

fail() {
    echo "$(tput bold; tput setaf 5)$@$(tput sgr0)" >&2
}

run() {
    echo "# $(tput setaf 6)$@$(tput sgr0)" >&2
    "$@"
    code=$?
    if (( code > 0 ))
    then
        fail "The following command executed with error $code:"
        fail "$@"
        exit $code
    fi
}

echo -n "What should this computer be called? "
read HOSTNAME
run echo "$HOSTNAME" > /etc/hostname

run cp ${PWD}/hosts /etc/hosts
run echo -e "\n127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" >> /etc/hosts