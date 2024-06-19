TEMPLATES=$(wildcard template/*)
K_NS1=kubectl --namespace ns1
K_NS2=kubectl --namespace ns2
K_EXEC_NS1=$(K_NS1) exec rabbitmq-0 --
K_EXEC_NS2=$(K_NS2) exec rabbitmq-0 --
RABBITMQ_ADMIN_NS1=$(K_EXEC_NS1) rabbitmqadmin -u guest -p guest
RABBITMQ_ADMIN_NS2=$(K_EXEC_NS2) rabbitmqadmin -u guest -p guest
RABBITMQ_CTL_NS1=$(K_EXEC_NS1) rabbitmqctl
RABBITMQ_CTL_NS2=$(K_EXEC_NS2) rabbitmqctl

all: deployment/ns1 deployment/ns2
	# Set up NS1
	$(RABBITMQ_ADMIN_NS1) declare exchange name=customers type=direct
	$(RABBITMQ_ADMIN_NS1) declare queue name=customers.us durable=true
	$(RABBITMQ_ADMIN_NS1) declare queue name=customers.de durable=true
	$(RABBITMQ_ADMIN_NS1) declare binding source=customers destination=customers.us routing_key=us
	$(RABBITMQ_ADMIN_NS1) declare binding source=customers destination=customers.de routing_key=de
	# Set up NS2
	$(RABBITMQ_ADMIN_NS2) declare exchange name=customers type=direct
	$(RABBITMQ_ADMIN_NS2) declare queue name=customers.us durable=true
	$(RABBITMQ_ADMIN_NS2) declare queue name=customers.de durable=true
	$(RABBITMQ_ADMIN_NS2) declare binding source=customers destination=customers.us routing_key=us
	$(RABBITMQ_ADMIN_NS2) declare binding source=customers destination=customers.de routing_key=de
	# Federation upstream NS1
	$(RABBITMQ_CTL_NS1) set_parameter federation-upstream 'federation' '{"uri":"amqp://rabbitmq.ns2.svc.cluster.local", "exchange":"customers.*"}'
	# Federation upstream NS2
	$(RABBITMQ_CTL_NS2) set_parameter federation-upstream 'federation' '{"uri":"amqp://rabbitmq.ns1.svc.cluster.local", "exchange":"customers.*"}'
	# Set up federation policy NS1
	$(RABBITMQ_CTL_NS1) set_policy --vhost "/" --apply-to "all" federation "customers.*" '{"federation-upstream-set": "all"}'
	# Set up federation policy NS2
	$(RABBITMQ_CTL_NS2) set_policy --vhost "/" --apply-to "all" federation "customers.*" '{"federation-upstream-set": "all"}'

	# Cannot setup federation using rabbitmqadmin!

ns1: deployment/ns1
ns2: deployment/ns2

deployment/ns1: $(TEMPLATES)
	kubectl get namespace | grep -q "^ns1 " || kubectl create namespace ns1
	./deploy.sh apply ns1 ns2
	$(K_NS1) wait --for=condition=Ready pod/rabbitmq-0
	sleep 5
	$(K_NS1) wait --for=condition=Ready pod/rabbitmq-2

deployment/ns2: $(TEMPLATES)
	kubectl get namespace | grep -q "^ns2 " || kubectl create namespace ns2
	./deploy.sh apply ns2 ns1
	$(K_NS2) wait --for=condition=Ready pod/rabbitmq-0
	sleep 5
	$(K_NS2) wait --for=condition=Ready pod/rabbitmq-2

clean: clean-ns1 clean-ns2

clean-ns1:
	./deploy.sh delete ns1 ns2
	-kubectl delete namespace ns1  # Makes sure PVCs are gone

clean-ns2:
	./deploy.sh delete ns2 ns1
	-kubectl delete namespace ns2  # Makes sure PVCs are gone
