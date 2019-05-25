```
vagrant ssh-config --host webapp >> ~/.ssh/config
ansible -i hosts webapp -m ping

ansible-playbook -i hosts main.yml
ansible-playbook -i hosts main_local.yml --ask-become-pass
```