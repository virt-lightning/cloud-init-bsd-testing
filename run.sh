#!/bin/bash
set -eux
export ANSIBLE_SSH_RETRIES=10
export VIRTUAL_ENV_DISABLE_PROMPT=1
. ~/virtualenv/bin/activate

for i in 5.6.3; do
    ansible-playbook -vvv playbook.yml -i inventory.yaml -e @targets/dragonflybsd-${i}.yaml -e promote_image=true
    ./test-openstack dragonflybsd-${i} | tee dragonflybsd-${i}-openstack.log
done

for i in 6.6; do
    ansible-playbook -vvv playbook.yml -i inventory.yaml -e @targets/openbsd-${i}.yaml -e promote_image=true
    ./test-openstack openbsd-${i} | tee openbsd-${i}-openstack.log
done

for i in 8.2 9.0; do
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/netbsd-${i}.yaml -e promote_image=true
    ./test-openstack netbsd-${i} | tee netbsd-${i}-openstack.log
done

for i in 11.2 12.1; do
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/freebsd-${i}.yaml -e promote_image=true
    ./test-openstack freebsd-${i} | tee freebsd-${i}-openstack.log
done

sudo find /var/www/bsd-cloud-image.org -type f -exec chmod 644 {} \;
sudo find /var/www/bsd-cloud-image.org -type d -exec chmod 755 {} \;
