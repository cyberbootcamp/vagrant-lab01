.PHONY: default
default:
	echo list of options

.PHONY: syncdev
syncdev:
	rsync -zavh ~/repositories/github/cyberbootcamp/vagrant-lab01/ lab01:~/repositories/github/cyberbootcamp/vagrant-lab01/
.PHONY: ansible
ansible:
	ansible-playbook --inventory ./ansible_inventory ./site.yml