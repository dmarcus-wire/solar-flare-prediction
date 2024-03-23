# Solar Flare Prediction

# Setup 

## Cluster Configuration

Install the Web Terminal Operator via the OperatorHub - (linked here)[https://github.com/redhat-na-ssa/demo-ai-gitops-catalog/tree/main?tab=readme-ov-file#bootstrapping-a-cluster]

```
# bootstrap the cluster from the Web Terminal copying, pasting and running the following script
YOLO_URL=https://raw.githubusercontent.com/codekow/demo-ai-gitops-catalog/main/scripts/library/term.sh
. <(curl -s "${YOLO_URL}")
term_init

# make custom web terminal persistent
apply_firmly bootstrap/web-terminal

# basic cluster config

# load functions
. scripts/functions.sh

# setup an enhanced web terminal on a default cluster
# alt cmd: until oc apply -k bootstrap/web-terminal; do : ; done
apply_firmly bootstrap/web-terminal

# setup a default cluster w/o argocd managing it
apply_firmly clusters/default

# setup a dev spaces demo /w gpu
apply_firmly demos/devspaces-nvidia-gpu-autoscale

# setup a rhods demo /w gpu
apply_firmly demos/rhods-nvidia-gpu-autoscale
```

## Minio Object Storage

From the Web Terminal

```
# deploy minio object storage in a namespace from the web terminal
oc apply -k components/configs/kustomized/minio/overlays/with-namespace-known-password
```

## Create a devfile.yaml

```
schemaVersion: 2.2.0
metadata:
  name: devspaces-gpu
attributes:
#   controller.devfile.io/scc: container-build
  controller.devfile.io/storage-type: ephemeral
projects:
  - name: solar-flare-prediction
    git:
      remotes:
        origin: "https://github.com/dmarcus-wire/solar-flare-prediction.git"
      checkoutFrom:
        revision: main
components:
  - attributes:
      container-overrides:
        resources:
          limits:
            nvidia.com/gpu: '1'
      controller.devfile.io/merge-contribution: true
    container:
      # image: ghcr.io/redhat-na-ssa/udi-cuda:11.8.0-cudnn8-devel-ubi8
      image: ghcr.io/redhat-na-ssa/udi-cuda:latest
      memoryLimit: 2G
      cpuLimit: 1000m
      mountSources: true
      sourceMapping: /projects
    name: python
```

## Create a Pod to Use a Volume for Storage

A Container's file system lives only as long as the Container does. So when a Container terminates and restarts, filesystem changes are lost. For more consistent storage that is independent of the Container, you can use a Volume. (source)[https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/]

```
# search for container image to use
podman search --filter=is-official redis 

# create a pod with one container with volume type of emptyDir
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: redis-storage
      mountPath: /data/
  volumes:
  - name: redis-storage
    emptyDir: {}

# create the pod in a namespace 
oc apply -f https://k8s.io/examples/pods/storage/redis.yaml -n <enter your namespace>

# monitor the deployment 
oc get pod redis --watch

# in another terminal, get a shell to the running Container
exec -it redis -- /bin/bash
```

## Copying local file to the Container

Support for copying local files to or from a container is built into the `oc` CLI. You MUST install `rysnc` on the client. (source)[https://docs.openshift.com/container-platform/4.14/nodes/containers/nodes-containers-copying-files.html]

```
# To copy a local directory to a pod directory
# oc rsync <local-dir> <pod-name>:/<remote-dir> -c <container-name>
oc rsync ~/Downloads/ redis:/data

# connect to the pod container
# oc rsh --container CONTAINERNAME POD
oc rsh --container redis redis
cd data

# untar the files
for f in *.tar; do
  tar xf "$f" &
done
wait

# check files (1138 count)
ls -l . | wc -l

```