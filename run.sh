#!/bin/bash
set -euxo pipefail
export ANSIBLE_SSH_RETRIES=10
export VIRTUAL_ENV_DISABLE_PROMPT=1
. ~/virtualenv/bin/activate


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

for target in openbsd-7.0 openbsd-6.9 netbsd-9.2 netbsd-8.2 freebsd-13.0-zfs freebsd-13.0-ufs; do
    run_test ${target} 2>&1 | tee ${log_dir}/${target}-build.log
done

#os=dragonflybsd
#for version in 5.8.3; do
#    run_test ${os} ${version} ${repo} > ${log_dir}/${os}-${version}-build.log 2>&1
#done


sudo find /var/www/bsd-cloud-image.org -type f -exec chmod 644 {} \;
sudo find /var/www/bsd-cloud-image.org -type d -exec chmod 755 {} \;
