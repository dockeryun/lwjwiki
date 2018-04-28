#! /bin/bash
	
#ansible  push pub
#2018.04.28

#指定host参考/etc/ansible/hosts
host=$1
#修改的用户名
user=root
#是否覆盖远程主机上所有pub
isremove=no
#runinglog地址
pushlog=./pushpub.log


if [ $# -lt 1 ];then
        echo $"Usage: $0 {zabbix|all|node}"  
	exit 2  
fi


if [ `id -u` -ne 0 ];then
	echo "the user is not root,please command for root."
	exit 1
else



echo "创建新的密钥文件（保存在 ~/.ssh/目录中"
ssh-keygen -t rsa -f ~/.ssh/id_rsa_new 2>&1|tee $pushlog

(
cat << EOF
---
- hosts: $host
  remote_user: root

  tasks:
  - name: back server ssh pub
    command: cp /${user}/.ssh/authorized_keys  /${user}/.ssh/authorized_keys.bak$(date +%F)

  - name: copy ssh key
    authorized_key:
      user: $user
      key: "{{ lookup('file','~/.ssh/id_rsa_new.pub')}}"       
      exclusive: $isremove
EOF
)  > push_pubforsh.yml

ansible-playbook  push_pubforsh.yml 2>&1|tee -a $pushlog



cd ~/.ssh/
    if [ -d bak ]; then
	mv  ~/.ssh/id_rsa   ~/.ssh/bak/id_rsa_bak$(date +%F)
	mv  ~/.ssh/id_rsa.pub   ~/.ssh/bak/id_rsa_bak$(date +%F).bub
#移动新的rsa
#	mv ~/.ssh/id_rsa_new  ~/.ssh/id_rsa
#	mv ~/.ssh/id_rsa_new.pub  ~/.ssh/id_rsa.pub
    else
 	mkdir bak && chmod 600 bak 
        mv  ~/.ssh/id_rsa   ~/.ssh/bak/id_rsa_bak$(date +%F)
        mv  ~/.ssh/id_rsa.pub   ~/.ssh/bak/id_rsa_bak$(date +%F).bub
#移动新的rsa
#        mv ~/.ssh/id_rsa_new  ~/.ssh/id_rsa
#        mv ~/.ssh/id_rsa_new.pub  ~/.ssh/id_rsa.pub
    fi

#rm -f  push_pubforsh.yml 2>&1|tee -a  $pushlog
fi

