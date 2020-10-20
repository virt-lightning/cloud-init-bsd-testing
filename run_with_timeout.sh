#!/bin/bash
timeout 10800 bash run.sh
ansible-playbook cleanup.yaml
