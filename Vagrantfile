
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vagrant.plugins = "vagrant-reload"

  config.vm.provider "virtualbox" do |vb|    
    vb.cpus = 8
    vb.memory = 8192
    vb.gui = true
    vb.customize ['modifyvm', :id, '--clipboard-mode', 'bidirectional']
    vb.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
  end

  config.vm.synced_folder ".", "/home/vagrant/Desktop/iot", type: "virtualbox"
  config.vm.provision "shell", name: "Setting up Vm", privileged: false,  inline: <<-SHELL
    set -eux

    sudo apt-get update
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends gdm3 ubuntu-desktop-minimal
    echo "display manager and desktop installed."

    curl -sfL https://get.docker.com | sudo sh -
    sudo usermod -aG docker "$USER"
    echo "docker installed."

    sudo apt-get install -y virtualbox vagrant
    echo "virtualbox and vagrant installed."

    sudo snap install --classic code
    echo "vscode installed."

    sudo snap install firefox
    echo "firefox installed."

    mkdir -p ~/bin && cd ~/bin
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ~/bin/kubectl
    cd -
    echo "kubectl installed."
    
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | sudo bash -
    echo "k3d installed."

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
		echo '' >> ~/.bashrc
		echo "# add helm completion" >> ~/.bashrc
		echo "source <(helm completion bash)" >> ~/.bashrc
    echo "helm installed."

  SHELL
  
  config.vm.provision :reload

  config.vm.provision "shell", name: "Finishing setup...", privileged: false, inline: <<-SHELL
    set -ex
  
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'org.gnome.Terminal.desktop', 'code_code.desktop', 'firefox_firefox.desktop', 'virtualbox.desktop']"

    sudo mkdir -p /etc/vbox
    sudo bash -c 'echo "* 192.168.42.0/24" >> /etc/vbox/networks.conf'
    echo "vbox allowed ranges set (192.168.42.0/24)"
    
    #p3
    sudo sh -c 'echo "192.168.42.110 app1.com app2.com app3.com no.com" >> /etc/hosts'
    # bonus
    sudo sh -c 'echo "127.0.0.1 minio.iot.com registry.iot.com gitlab.iot.com kas.iot.com" >> /etc/hosts'

    # vagrant autocomplete install 1> /dev/null

    vagrant plugin install vagrant-reload

  SHELL

end