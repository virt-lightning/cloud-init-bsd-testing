#!/bin/bash
set -eux
export VIRTUAL_ENV_DISABLE_PROMPT=1
. ~/virtualenv/bin/activate

for target in $(find targets/ -type f -name '*.*'); do
    ansible-playbook playbook.yml -i inventory.yaml -e promote_image=true -e @${target}
done
