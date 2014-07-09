Node Provisioning Service
=========================


Run [Apache ACE Server] (https://ace.apache.org/) as a CoreOS/Docker service. 


Run on localhost
-------------------

* Install Docker
* Clone this repository
* Run `./node-provisioning-service build
* Run `./node-provisioning-service run`
* Check `http://localhost:8080`


Run in Vagrant
--------------
* Install Vagrant & VirtualBox
* Clone this repository
* Configure discovery in coreos-userdata (optional)
* Run `vagrant up`
* Check `http://172.17.8.201:8080/ace/`

