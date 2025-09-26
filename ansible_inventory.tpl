[bastion]
vm-bastion ansible_host=${bastion_external_ip} ansible_user=chupin ansible_ssh_private_key_file=/home/chupin/.ssh/course/id_rsa

[web]
${vm_1_name} ansible_host=${vm_1_external_ip} ansible_user=chupin ansible_ssh_private_key_file=/home/chupin/.ssh/course/id_rsa
${vm_2_name} ansible_host=${vm_2_external_ip} ansible_user=chupin ansible_ssh_private_key_file=/home/chupin/.ssh/course/id_rsa

[prometheus]
${prometheus_name} ansible_host=${prometheus_external_ip} ansible_user=chupin ansible_ssh_private_key_file=/home/chupin/.ssh/course/id_rsa

[all:vars]
bastion_public_ip=${bastion_external_ip}
host_key_checking = False
