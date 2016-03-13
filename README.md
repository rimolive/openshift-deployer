# openshift-deployer
====================

A Bash script to automate configuration of OpenShift environments. The objective is quickly provision an OpenShift environment in your PC or laptop for demo of development purposes.

### How to use

```
$ git clone https://github.com/rimolive/openshift-deployer.git
$ cd openshift-deployer
$ ./prepare-openshift -h
Prepares an OpenShift Origin environment for demo purposes or simple development.

Available options:

--deploy:    Deploy an OpenShift environment using openshift binary and deploy the registry and templates
--clean:     Wipe out the OpenShift data
--clean-all: Wipe out the OpenShift data and OpenShift diretory
-h:          Print this help contents
```

### Future improvements

* Add some more parameters for deployment to make it more flexible
* Create a workflow to deploy OpenShift in container using oinc
* Create an interactive mode
