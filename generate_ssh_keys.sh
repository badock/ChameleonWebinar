# Generate a ssh key
if [ -f ~/.ssh/id_rsa ]; then
   rm ~/.ssh/id_rsa
fi

echo -e  'y\n' | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N '' -q
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
sudo sed -i "s/# Host */Host */g" /etc/ssh/ssh_config
sudo sed -i "s/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/g" /etc/ssh/ssh_config
