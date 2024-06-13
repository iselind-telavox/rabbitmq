all: deployment/ns1 deployment/ns2
	find deployment

ns1: deployment/ns1
ns2: deployment/ns2

deployment/ns1:
	kubectl create namespace ns1
	./deploy.sh apply ns1 ns2

deployment/ns2:
	kubectl create namespace ns2
	./deploy.sh apply ns2 ns1

clean: clean-ns1 clean-ns2
	-find deployment

clean-ns1:
	./deploy.sh delete ns1 ns2
	-kubectl delete namespace ns1

clean-ns2:
	./deploy.sh delete ns2 ns1
	-kubectl delete namespace ns2
