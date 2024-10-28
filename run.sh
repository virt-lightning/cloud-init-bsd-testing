#!/bin/bash
set -euxo pipefail
export ANSIBLE_SSH_RETRIES=10
export VIRTUAL_ENV_DISABLE_PROMPT=1
. ~/virtualenv/bin/activate
ansible-galaxy collection install --requirements-file requirements.yml --collections-path collections
find collections/ansible_collections/ -maxdepth 3 -name requirements.txt -exec pip install -r {} \;

git_repo="goneri/cloud-init"
#git_repo="canonical/cloud-init"
promote=false

log_dir=$(date +results/%Y%m%d-%H%M)
mkdir -p ${log_dir}

function run_test() {
    target=${1}
    ansible-playbook cleanup.yaml
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/${target}.yaml -e git_repo=${git_repo}
    timeout 1800 ansible-playbook openstack.yaml -e @targets/${target}.yaml
    if [ "${promote}" = true ] ; then
        ansible-playbook promote.yaml -e @targets/${target}.yaml
    fi
    ansible-playbook cleanup.yaml

}

for target in freebsd-13.4-ufs freebsd-13.4-zfs freebsd-14.1-ufs freebsd-14.1-zfs ;do
    run_test ${target} 2>&1 | tee ${log_dir}/${target}-build.log
done
