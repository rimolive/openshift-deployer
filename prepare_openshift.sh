#!/bin/bash
# For debugging purposes uncomment the next line
# set -x

OPENSHIFT_HOME=$(pwd)
TEMPLATES_DIR=/home/rmartine/Development/git-repos/openshift-ansible/roles/openshift_examples/files/examples/latest
XPAAS_DIR=/home/rmartine/Development/git-repos/application-templates

function deployOpenShift() {
	IS_FIREWALLD_STARTED = $(systemctl is-active sshd >/dev/null 2>&1 && echo YES || echo NO)

	if ["IS_FIREWALLD_STARTED" == "YES" ]; then
		echo "You have firewalld started in this system. Stop firewalld service and run the script again."
		exit 1
	fi

	export PATH=$OPENSHIFT_HOME:$PATH

	cd $OPENSHIFT_HOME
	sudo nohup ./openshift start --cors-allowed-origins='.*' --master=https://192.168.1.131:8443 --loglevel=5 &

	while [ `curl -o /dev/null --silent --head --write-out '%{http_code}\n' -k https://192.168.1.131:8443` != 200  ]; do	
		sleep 2s
	done

	export KUBECONFIG=$OPENSHIFT_HOME/openshift.local.config/master/admin.kubeconfig
	export CURL_CA_BUNDLE=$OPENSHIFT_HOME/openshift.local.config/master/ca.crt
	sudo chmod 777 $OPENSHIFT_HOME/openshift.local.config/master/admin.kubeconfig
	sudo chmod 777 $OPENSHIFT_HOME/openshift.local.config/master/openshift-registry.kubeconfig

	oc login -u system:admin
	oc project default

	oadm registry --credentials=$OPENSHIFT_HOME/openshift.local.config/master/openshift-registry.kubeconfig

	importTemplates
	importXpaasTemplates
}

function importTemplates() {
	oc create -f $TEMPLATES_DIR/image-streams/image-streams-centos7.json -n openshift
	oc create -f $TEMPLATES_DIR/db-templates/ -n openshift
	oc create -f $TEMPLATES_DIR/infrastructure-templates/ -n openshift
	oc create -f $TEMPLATES_DIR/infrastructure-templates/origin/ -n openshift
	oc create -f $TEMPLATES_DIR/quickstart-templates/ -n openshift
}

function importXpaasTemplates() {
	oc create -f $XPAAS_DIR/jboss-image-streams.json -n openshift
	oc create -f $XPAAS_DIR/amq/ -n openshift
	oc create -f $XPAAS_DIR/datagrid/ -n openshift
	oc create -f $XPAAS_DIR/decisionserver/ -n openshift
	oc create -f $XPAAS_DIR/eap/ -n openshift
	oc create -f $XPAAS_DIR/processserver/ -n openshift
	oc create -f $XPAAS_DIR/sso/ -n openshift
	oc create -f $XPAAS_DIR/webserver/ -n openshift
	oc create -f $XPAAS_DIR/secrets/ -n openshift
}

function clean() {
	docker rm -f $(docker ps -a -q)
	sudo rm -rf $OPENSHIFT_HOME/openshift.local.*
}

function cleanAll() {
	clean
	sudo rm -rf $OPENSHIFT_HOME
	rm -rf $TEMPLATES_DIR
	rm -rf $XPAAS_DIR
}

function printHelp() {
	echo "Prepares an OpenShift Origin environment for demo purposes or simple development."
	echo ""
	echo "Available options:"
	echo ""
	echo "--deploy:    Deploy an OpenShift environment using openshift binary and deploy the registry and templates"
	echo "--clean:     Wipe out the OpenShift data"
	echo "--clean-all: Wipe out the OpenShift data and OpenShift diretory"
	echo "-h:          Print this help contents"
}

for ARG in "$@"; do
	if [ "$ARG" == "--deploy" ]; then
		deployOpenShift
	elif [ "$ARG" == "--clean" ]; then
		clean
		exit 0	
	elif [ "$ARG" == "--clean-all" ]; then
		cleanAll
		exit 0
	elif [ "$ARG" == "-h" ]; then
		printHelp
		exit 0
	fi
done


