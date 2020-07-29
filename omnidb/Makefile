# For cli directly installed
CIVO_CMD="civo"
# For Docker
#CIVO_CMD=docker run -it --rm -v /home/steve/.civo.json:/.civo.json civo/cli:latest
CIVO_TEST_CLUSTER_NAME=omni-test
CIVO_KUBECONFIG=kubeconfig.$(CIVO_TEST_CLUSTER_NAME)
KUBECTL=kubectl --kubeconfig=$(CIVO_KUBECONFIG)

.PHONY: test
test:
	@echo "Creating $(CIVO_TEST_CLUSTER_NAME)"
	@$(CIVO_CMD) k3s create $(CIVO_TEST_CLUSTER_NAME) -n 3 --size g2.small --wait
	@$(CIVO_CMD) k3s config $(CIVO_TEST_CLUSTER_NAME) > $(CIVO_KUBECONFIG)
	@echo "Adding Longhorn"
	@$(CIVO_CMD) k3s apps add Longhorn --cluster 
	# check every 10 seconds for successful install
	@for i in $(seq 1 10); do \
		numready=$(kubectl get -n longhorn-system daemonset.apps/longhorn-csi-plugin -ojson | jq -r .status.numberReady); \
		if [ "${numready}" == "3" ]; then \
		  break; \
		elif [ ${i} == "10" ]; then \
			echo "Longhorn not available, stopping test"; \
			exit 1; \
		fi; \
	done \ 
	@echo "Applying manifest and test run"
	@$(KUBECTL) apply -f app.yaml
	@$(KUBECTL) create -f test-manifests/1-task.yaml 
	@$(KUBECTL) create -f test-manifests/2-taskrun.yaml 
	@sleep 10
	@echo "Checking status of test run"
	@$(KUBECTL) get taskrun -l tekton.dev/task=hello -ojson | jq -r .items[0].status.conditions[0].type | grep -q Succeeded
	@echo "Success!  Tearing down test cluster"
	@$(CIVO_CMD) k3s remove -y $(CIVO_TEST_CLUSTER_NAME)
	@rm $(CIVO_KUBECONFIG)