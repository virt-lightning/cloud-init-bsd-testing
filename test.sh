#!/bin/bash

for i in 11 12; do
    ansible-playbook -vvv playbook.yml -i inventory.yaml -e @targets/freebsd-${i}.yaml -e git_ref=ebb3e05dfd2ea54072d25754fde370fb9116bb95
done

