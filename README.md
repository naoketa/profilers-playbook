```
vagrant ssh-config --host webapp >> ~/.ssh/config
ansible -i hosts webapp -m ping

ansible-playbook -i hosts main.yml
ansible-playbook -i hosts main_local.yml --ask-become-pass
```

### todo

- [ ] Roles分割/ディレクトリ構成整理する 

- [ ] OS依存タスクを定義(yum/aptとか)

