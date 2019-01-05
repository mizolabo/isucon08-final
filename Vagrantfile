
Vagrant.configure("2") do |config|

  config.vm.box = "bento/centos-7.4"

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder "{自身のローカルフォルダを指定}", "/home/vagrant/isucon08-final"

  config.vm.provision "shell", inline: <<-SHELL

  # docker innstall&setup
    echo '---------------yum update start---------------'
    yum -y update
    echo '---------------docker-tool install start---------------'
    yum -y install lvm2 device-mapper device-mapper-persistent-data device-mapper-event device-mapper-libs device-mapper-event-libs
    echo '---------------docker repositories get start---------------'
    wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
    echo '---------------docker install start---------------'
    yum -y install docker-ce-18.03.1.ce-1.el7.centos.x86_64
    echo '---------------vagrant user add start---------------'
    usermod -aG docker vagrant
    echo '---------------docker service start---------------'
    systemctl start docker
    echo '---------------docker service registration start ---------------'
    systemctl enable docker

  # docker-compose innstall&setup
    echo '---------------docker-compose install start ---------------'
    curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    echo '---------------docker-compose change mod start ---------------'
    chmod +x /usr/local/bin/docker-compose

  # go innstall
    echo '---------------epel-release install start ---------------'
    yum -y install epel-release
    echo '---------------go install start ---------------'
    yum -y install go
    echo '---------------pprof install or update start ---------------'
    go get -u github.com/google/pprof
    echo '---------------graphviz install start ---------------'
    yum -y install graphviz
    echo '---------------end ---------------'
    SHELL
end
