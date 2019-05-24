```
vagrant ssh-config --host webapp >> ~/.ssh/config
ansible -i hosts webapp -m ping

ansible-playbook -i hosts main.yml
```