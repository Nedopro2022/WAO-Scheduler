> [!IMPORTANT]
> This repository is no longer being maintained. Please use the new [WAO Scheduler](https://github.com/waok8s/wao-scheduler) instead.

# WAO-Scheduler plugin

---
Kubernetes is a portable, extensible, open source platform for facilitating declarative configuration management and automation, and managing containerized workloads and services. Kubernetes has a huge and fast-growing ecosystem with a wide range of services, support and tools available.

This Document shows the steps to build and deploy Workload Allocation Optimizer (WAO)-Scheduler with power minimizing policy.

---

## Architecture overview
WAO-scheduler gets the CPU usage of each node with Metrics-server, also gets the ambient temperature and CPU temperature with ipmi_exporter. Then WAO-Scheduler predicts power increases with Tensorflow-serving and score the nodes. Finally, WAO-Scheduler selects the node that is expected to the power increases is minimum.
![architecture](https://user-images.githubusercontent.com/2385205/113538962-8a155480-9617-11eb-9215-77ddffdaa5b7.png)

## Prerequisites

* [Go v1.19](https://golang.org/)
* [Kubernetes v1.25](https://github.com/kubernetes/kubernetes/releases/tag/v1.19.7)
* [IPMI Exporter](https://github.com/soundcloud/ipmi_exporter) running on each node
* local docker repository  
* docker image of tensorflow serving containing power consumption model of each node.  

## Build WAO-Scheduler with power minimization policy

```sh
git checkout release-v1.25
make test
make build-bin
```

## Deploy to Kubernetes

### 1. Create a Docker image for scheduler

```sh
git checkout release-v1.25
IMAGE_REGISTRY=${YOUR_REPO} make build-image
IMAGE_REGISTRY=${YOUR_REPO} make push-image
```
    
### 2. Preparing to start WAO-Scheduler

#### Launch metrics-server

Check the [compatibility matrix](https://github.com/kubernetes-sigs/metrics-server#compatibility-matrix)

``` 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

#### Launch tensorflow serving

``` 
kubectl apply -f example/tensorflow-server-dep.yaml
kubectl apply -f example/tensorflow-server-svc.yaml
```

#### Label nodes

Give each node the following label:

* ambient/max: Maximum ambient temperature in celsius.
* ambient/min: Minimum ambient temperature in celsius.
* cpu1/max: Maximum CPU1 temperature in celsius.
* cpu1/min: Minimum CPU1 temperature in celsius.
* cpu2/max: Maximum CPU2 temperature in celsius.
* cpu2/min: Minimum CPU2 temperature in celsius.
* tensorflow/host: IP address of tensorflow serving.

### 3. launch MinimizePower scheduler

```
kubectl apply -f example/wao-scheduler-cm.yaml
kubectl apply -f example/wao-scheduler-sa.yaml
kubectl apply -f example/wao-scheduler-pod.yaml
```

Success if you can confirm the startup on each node with the following command
(Successful if the pod status is `Running`)

``` 
kubectl get pod -n kube-system -o wide | grep wao-scheduler
```

If you want to use wao-scheduler, please refer test.yaml.

```
kubectl apply -f test.yaml
```

## License
Apache License 2.0, see [LICENSE](LICENSE).
