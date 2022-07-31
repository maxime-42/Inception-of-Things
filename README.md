# Inception-of-Things

##### p1 Schema

##### p2 Schema :

![alt](reference/p2.drawio.svg)
##### p3 Schema

#### Sources :

##### Vagrant
- [vagrant doc](https://www.vagrantup.com/docs)
- [vagrantfile tips](https://www.vagrantup.com/docs/vagrantfile/tips)
- [vagrant boxes](https://app.vagrantup.com/boxes/search)
- [multi machines](https://www.vagrantup.com/docs/multi-machine)
- [config.vm.network](https://friendsofvagrant.github.io/v1/docs/config/vm/network.html)
- [shared folder nfs mount failed](https://discuss.hashicorp.com/t/mount-nfs-connection-timed-out/37935)
- [nfs troubleshoot](https://github.com/hashicorp/vagrant/blob/80e94b5e4ed93a880130b815329fcbce57e4cfed/website/pages/docs/synced-folders/nfs.mdx#troubleshooting-nfs-issues)
- https://www.reddit.com/r/CentOS/comments/nytwi4/all_centos_8_mirrors_are_half_broken_and_nobody/

##### k3s
- [k3s doc](https://rancher.com/docs/k3s/latest/en/)
- [k3s server configuration reference](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/)
- [k3s multinode install](https://projectcalico.docs.tigera.io/getting-started/kubernetes/k3s/multi-node-install)
- [k8s multinode centos](https://www.golinuxcloud.com/kubernetes-add-node-to-existing-cluster/#Lab_Environment)
- [k3s node roles](https://rancher.com/docs/rancher/v2.5/en/cluster-provisioning/production/nodes-and-roles/)

##### k3d
- [Create a Multi-Node Cluster with k3d](https://docs.rancherdesktop.io/how-to-guides/create-multi-node-cluster/)
- [k3s + k3d = k8s - a new perfect match for dev and test](https://www.sokube.ch/post/k3s-k3d-k8s-a-new-perfect-match-for-dev-and-test)

##### Ingress

- [k3s traefic ingress controller doc](https://rancher.com/docs/k3s/latest/en/networking/#traefik-ingress-controller)
- [how k3s service load balancer works](https://rancher.com/docs/k3s/latest/en/networking/?query=servicelb)
- [Kubernetes: troubleshooting ingress and services traffic flows](https://medium.com/@ManagedKube/kubernetes-troubleshooting-ingress-and-services-traffic-flows-547ea867b120)
- [bad gateway, disable firewall](https://forums.rancher.com/t/solved-unable-to-use-ingress-traefik-in-k3s-version-v1-23-6-k3s1-418c3fa8/37838)

##### Nested vms
- [VT-x is not available](https://www.youtube.com/watch?v=JMT2qimIL9Q)
- https://blog.mattchung.me/2020/08/18/how-to-configure-ubuntu-w-nested-virtualization-using-vagrant-and-virtualbox-on-macos/
- https://stackoverflow.com/questions/38463579/vagrant-hangs-at-ssh-auth-method-private-key