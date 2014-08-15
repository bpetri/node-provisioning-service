#Node Provisioning Service

Run [Apache ACE Server] (https://ace.apache.org/) as a CoreOS/Docker service. 

#TODO
* etcd is started from the node-provisioning script. etcd should configured as a service 
* The node-provisioning script is started with a fixed provisioning id, this should be someting dynamic and unique.



#Run on localhost

* Install Docker
* Clone this repository: git clone https://github.com/INAETICS/node-provisioning-service.git
* Build docker Image : docker build -t inaetics/node-provisioning node-provision-service
* Run docker image: docker run -d -p 8080:8080 --name=provisioning inaetics/node-provisioning 
* [Optional] Run the docker image ineractive: docker run -t -i inaetics/node-provisioning /bin/bash
* Check `http://localhost:8080`


#Run in Vagrant
* Install Vagrant & VirtualBox
* Clone this repository
* Configure discovery in coreos-userdata (optional)
* Run `vagrant up`
* Check `http://172.17.8.201:8080/ace/`

