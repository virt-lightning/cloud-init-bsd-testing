#!/bin/bash
set -eux
export VIRTUAL_ENV_DISABLE_PROMPT=1
. ~/virtualenv/bin/activate

for i in 8.1 9.0; do
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/netbsd-${i}.yaml -e promote_image=true
    ./test-openstack netbsd-${i}
done

for i in 11.2 12.1; do
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/freebsd-${i}.yaml -e promote_image=true
    ./test-openstack freebsd-${i}
done

for i in 6.6; do
    ansible-playbook -vvv playbook.yml -i inventory.yaml -e @targets/openbsd-${i}.yaml -e promote_image=true
    ./test-openstack openbsd-${i}
done

