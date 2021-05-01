#!/bin/bash
set -euxo pipefail
export ANSIBLE_SSH_RETRIES=10
export VIRTUAL_ENV_DISABLE_PROMPT=1
. ~/virtualenv/bin/activate


#repo="goneri/cloud-init"
repo="canonical/cloud-init"
promote_image=false


log_dir=$(date +results/%Y%m%d-%H%M)
mkdir -p ${log_dir}

function run_test() {
    os=${1}
    version=${2}
    #git_repo=${3:-canonical/cloud-init}
    git_repo=${3}
    vl fetch ${os}-${version}
    ansible-playbook cleanup.yaml
    ansible-playbook playbook.yml -i inventory.yaml -e @targets/${os}-${version}.yaml -e git_repo=${git_repo} -vvv
    timeout 1800 ansible-playbook openstack.yaml -e @targets/${os}-${version}.yaml -vvv
    timeout 1800 ansible-playbook openstack.yaml -e config_drive=yes -e @targets/${os}-${version}.yaml -vvv
    ansible-playbook promote.yaml -e @targets/${os}-${version}.yaml -vvv

}

os=openbsd
for version in 6.8; do
    run_test ${os} ${version} ${repo} > ${log_dir}/${os}-${version}-build.log 2>&1
done

os=freebsd
for version in 11.4 12.2; do
    run_test ${os} ${version} ${repo} > ${log_dir}/${os}-${version}-build.log 2>&1
done

os=netbsd
for version in 8.2 9.1; do
    run_test ${os} ${version} ${repo} > ${log_dir}/${os}-${version}-build.log 2>&1
done

#os=dragonflybsd
#for version in 5.8.3; do
#    run_test ${os} ${version} ${repo} > ${log_dir}/${os}-${version}-build.log 2>&1
#done


sudo find /var/www/bsd-cloud-image.org -type f -exec chmod 644 {} \;
sudo find /var/www/bsd-cloud-image.org -type d -exec chmod 755 {} \;
