Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vagrant.plugins = "vagrant-reload"

  config.vm.provider "virtualbox" do |vb|    
    vb.cpus = 2
    vb.memory = 4096
    vb.gui = true
    vb.customize ['modifyvm', :id, '--clipboard-mode', 'bidirectional']
    vb.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
  end

  config.vm.synced_folder ".", "/home/vagrant/Desktop/iot", type: "virtualbox"
  config.vm.provision "shell", name: "Setting up Vm", privileged: false,  inline: <<-SHELL
    set -eux

    sudo apt-get update
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends gdm3 ubuntu-desktop-minimal
    echo "display manager and desktop installed."
  
    sudo apt-get install -y virtualbox
    echo "virtualbox installed."

    sudo snap install --classic code
    echo "vscode installed."

    sudo snap install firefox
    echo "firefox installed."

    mkdir -p ~/bin && cd ~/bin
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ~/bin/kubectl
    cd -
    echo "kubectl installed."
    
    VAGRANT="https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_linux_amd64.zip"
    mkdir -p ~/bin
    wget -qO- "$VAGRANT" | busybox unzip -d ~/bin/ - 1> /dev/null
    chmod +x ~/bin/vagrant
    sudo apt-get install -y libarchive-tools
    echo "vagrant installed."

  SHELL
  
  config.vm.provision :reload

  config.vm.provision "shell", name: "Finishing setup...", privileged: false,  inline: <<-SHELL
    set -ex
  
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'org.gnome.Terminal.desktop', 'code_code.desktop', 'firefox_firefox.desktop', 'virtualbox.desktop']"

    sudo mkdir -p /etc/vbox
    sudo bash -c 'echo "* 192.168.42.0/24" >> /etc/vbox/networks.conf'
    echo "vbox allowed ranges set (192.168.42.0/24)"

    # vagrant autocomplete install 1> /dev/null

    cd /home/vagrant/Desktop/iot/p1
    vagrant up

  SHELL

end