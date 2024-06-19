To access RabbitMQ deployed in Orbstack k8s, go to the
[management interface for ns1](http://rabbitmq.ns1.svc.cluster.local:15672)
and
[management interface for ns2](http://rabbitmq.ns2.svc.cluster.local:15672)

The credentials are
```
Username: guest
Password: guest
```

On the "Overview" tab you should see three nodes connected to form the cluster.

# Federation
Federation enables the mirroring of exchanges and queues between RabbitMQ
brokers, thereby enabling data distribution and replication.

I found someone who got this working
[over here](https://kanapuli.github.io/posts/playing-with-rabbitmq-federation/).

CloudAMQP has written a post on high availability which you can
[find here](https://www.cloudamqp.com/blog/part3-rabbitmq-best-practice-for-high-availability.html).
It describes a lot of useful tips.

Exchange federation is a mechanism that allows a flow of messages through an exchange in one location (called the upstream or the source) be replicated to exchanges in other locations (downstreams).
The downstreams are independent nodes or clusters that can span wide area networks (geo regions).
The replication process is asynchronous and tolerates connectivity failures.

Federated queues provides a way of balancing the load of a single logical queue across nodes or clusters.
It does so by moving messages to other federation peers (nodes or clusters) when the local queue has no consumers.

## Thoughts on federated exchanges and so on.

As we need to add a policy for federation it might be a good idea to use a common prefix for federated stuff, something like `.federated.*`.

## Testing
Not sure how to test federation.
