[app]
les03-vm ansible_host=${ip} app_name=demoapp

[all:vars]
ansible_user=student
ansible_ssh_private_key_file=~/.ssh/student_esxi

