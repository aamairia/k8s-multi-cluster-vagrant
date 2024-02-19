BOX_NAME = "debian/bullseye64"
CLUSTER_NAME = "CLUSTER-SSO"
NUMBER_MATSER=1
NUMBER_NODE=2
BASE_IP = "192.168.56."
PREFIX = "SSO-"
TOKEN = "mprwdr.te2jihfjl5n65q4o"

VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder "vagrant-config/", "/data", disabled: false

    (1..NUMBER_MATSER).each do |i|
        #master server
        CURRENT_MASTER_IP = "#{BASE_IP}#{i + 10}"
        config.vm.define "#{PREFIX}MASTER-#{i}" do |kmaster|
            kmaster.vm.box = BOX_NAME
            #nom du host de la vm
            kmaster.vm.hostname = "#{PREFIX}MASTER-#{i}"
            kmaster.vm.box_url = BOX_NAME
            kmaster.vm.network :private_network, ip: CURRENT_MASTER_IP
            kmaster.vm.provider :virtualbox do |hyperviseur|
                hyperviseur.name = "#{PREFIX}MASTER-#{i}"
                hyperviseur.memory = 2048
                hyperviseur.cpus = 2
            end
            #provisionning
            kmaster.vm.provision "shell", inline: <<-SHELL
                sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
                service ssh restart
            SHELL
            kmaster.vm.provision "shell", path: "vagrant-config/scripts/common.sh"
            kmaster.vm.provision "shell", path: "vagrant-config/scripts/master.sh", args: [TOKEN]
            #Ansible
#             kmaster.vm.provision "ansible" do |ansible|
#                 ansible.playbook = "roles/playbook.yml"
#                 #Redefine defaults
#                 ansible.extra_vars = {
#                     k8s_cluster_name:       CLUSTER_NAME,
#                     k8s_master_admin_user:  "vagrant",
#                     k8s_master_admin_group: "vagrant",
#                     k8s_master_apiserver_advertise_address: "#{IP_BASE}#{i + 10}",
#                     k8s_master_node_name: "#{PREFIX}MASTER-#{i}",
#                     k8s_node_public_ip: "#{IP_BASE}#{i + 10}"
#                 }
#             end
        end
        # nodes workers
        (1..NUMBER_NODE).each do |k|
            config.vm.define "#{PREFIX}NODE-#{i}-#{k}" do |knode|
                knode.vm.box = BOX_NAME
                #nom du host de la vm
                knode.vm.hostname = "#{PREFIX}NODE-#{i}-#{k}"
                knode.vm.box_url = BOX_NAME
                knode.vm.network :private_network, ip: "#{BASE_IP}#{k + 10 + i}"
                knode.vm.provider :virtualbox do |hv|
                    hv.name = "#{PREFIX}NODE-#{i}-#{k}"
                    hv.memory = 1024
                    hv.cpus = 1
                end
                #provisionning
                knode.vm.provision "shell", inline: <<-SHELL
                    sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
                    service ssh restart
                SHELL
                knode.vm.provision "shell", path: "vagrant-config/scripts/common.sh"
                knode.vm.provision "shell", path: "vagrant-config/scripts/node.sh", args: [TOKEN, CURRENT_MASTER_IP]
                #Ansible
    #             knode.vm.provision "ansible" do |ansible|
    #                 ansible.playbook = "roles/playbook.yml"
    #                 #Redefine defaults
    #                 ansible.extra_vars = {
    #                     k8s_cluster_name:     CLUSTER_NAME,
    #                     k8s_node_admin_user:  "vagrant",
    #                     k8s_node_admin_group: "vagrant",
    #                     k8s_node_public_ip: "#{IP_BASE}#{k + 10 + NUMBER_MATSER}"
    #                 }
    #             end
            end
        end
    end
end