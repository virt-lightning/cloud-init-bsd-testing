#!/bin/bash
set -eux
export VIRTUAL_ENV_DISABLE_PROMPT=1
. ~/virt-lightning/bin/activate

for i in 8; do
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/netbsd-${i}.yaml
done

for i in 11 12; do
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/freebsd-${i}.yaml
done

for i in 6.6; do
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/openbsd-${i}.yaml
done

