all:
	kubectl apply -R -f .

clean:
	-kubectl delete -R -f .
	-kubectl delete pvc data-rabbitmq-{0,1,2}
