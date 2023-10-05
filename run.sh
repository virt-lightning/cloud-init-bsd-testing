#!/bin/bash
set -euxo pipefail
export ANSIBLE_SSH_RETRIES=10
export VIRTUAL_ENV_DISABLE_PROMPT=1
. ~/virtualenv/bin/activate
ansible-galaxy collection install --requirements-file requirements.yml --collections-path collections
find collections/ansible_collections/ -maxdepth 3 -name requirements.txt -exec pip install -r {} \;

git_repo="goneri/cloud-init"
#git_repo="canonical/cloud-init"
promote_image=false


log_dir=$(date +results/%Y%m%d-%H%M)
mkdir -p ${log_dir}

function run_test() {
    target=${1}
    ansible-playbook cleanup.yaml
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/${target}.yaml -e git_repo=${git_repo}
    timeout 1800 ansible-playbook openstack.yaml -e @targets/${target}.yaml
    ansible-playbook promote.yaml -e @targets/${target}.yaml
    ansible-playbook cleanup.yaml

}

for target in dragonflybsd-6.0.1-hammer2 dragonflybsd-6.0.1-ufs freebsd-12.3-zfs freebsd-13.0-ufs freebsd-13.0-zfs netbsd-9.2 openbsd-7.0; do
    run_test ${target} 2>&1 | tee ${log_dir}/${target}-build.log
done

sudo find /var/www/bsd-cloud-image.org -type f -exec chmod 644 {} \;
sudo find /var/www/bsd-cloud-image.org -type d -exec chmod 755 {} \;
