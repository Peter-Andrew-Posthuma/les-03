[web]
%{ for idx, ip in web_ips ~}
web-${idx + 1} ansible_host=${ip}
%{ endfor ~}

[db]
db-1 ansible_host=${db_ip}

[all:vars]
ansible_user=student
ansible_ssh_private_key_file=~/.ssh/student_esxi

