# Solar Flare Prediction

# Setup 

assumptions:
1. you are logged into the OpenShift cluster with cluster-admin

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

MinIO is a high performance, distributed object storage system. It is software-defined, runs on industry standard hardware and is 100% open source with the dominant license being GNU AGPL v3. (source)[https://min.io/product/overview]

From the Web Terminal

```
# deploy minio object storage in a namespace from the web terminal
oc apply -k components/configs/kustomized/minio/overlays/with-namespace-known-password

# manually create a bucket

# manually create an access key
```

### Install and configure the minio client to sync data

The MinIO Client `mc` command line tool provides a modern alternative to UNIX commands like ls, cat, cp, mirror, and diff with support for both filesystems and Amazon S3-compatible cloud storage services. (source)[https://min.io/docs/minio/linux/reference/minio-mc.html]

```
# install
brew install minio/stable/mc

# create an alias
# The following basic example temporarily disables the bash history to mitigate the risk of authentication credentials leaking in plain text.
bash +o history

mc alias set ALIAS URL ACCESS_KEY SECRET_KEY
mc alias set minio-gong http://127.0.0.1:9000 minioadmin minioadmin
mc admin info k8s-minio-dev

bash -o history
```

## Create a devfile.yaml

Devfiles are yaml text files used for development environment customization. Use them to configure a devfile to suit your specific needs and share the customized devfile across multiple workspaces to ensure identical user experience and build, run, and deploy behaviours across your team.

- Reduce the gap between development and deployment
- Find available devfile stacks or samples in a devfile registry
- Produce consistent build and run behaviors

see (source)[https://devfile.io/docs/2.1.0/benefits-of-devfile] and (Red Hat Dev Spaces)[https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.12/html/user_guide/devfile-introduction].

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

## Create a Redis Pod to Use a Volume for Storage

Redis is a key-value store. In rough terms, it works just like a database, but it keeps its data in memory, which means that reads and writes are orders of magnitude faster compared to relational databases like PostgreSQL. It is important to mention that Redis does not replace a relational database. It has its own use-cases and we will explore some of them in this post.

A Container's file system lives only as long as the Container does. So when a Container terminates and restarts, filesystem changes are lost. For more consistent storage that is independent of the Container, you can use a Volume. (source)[https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/].

For persistent storage in a pod see (source)[https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/]

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

## Copying local files to the Container

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

# manual upload files to minio storage bucket
```

## Configure conda for project

Script to configure conda. 

In this script, the conda shell.bash hook command sets up shell functions for Conda. The eval command then evaluates the output of this command. Finally, conda activate myenv activates the Conda environment named myenv. (source)[https://saturncloud.io/blog/activating-conda-environments-from-scripts-a-guide-for-data-scientists/#activating-a-conda-environment-from-a-script]

### Setup script
```
#!/bin/bash

# UPDATE YOUR ENV NAME
ENV=solar-flare

echo "update conda"
conda update -n base -c defaults conda -y

echo "check if conda $ENV exists"
if conda env list | grep -q "\b$ENV/b";then
    echo "conda environment $ENV already exists"
else
    "create the conda environment $ENV"
    conda create -n $ENV python=3.12 -y
fi

echo "wait for 2s"
sleep 2s

echo "initialize the env"
conda init bash

echo "activate the virtual env"
eval "$(conda shell.bash hook)"
conda activate $ENV

echo "install packages from conda-forge"
conda install -c conda-forge jupyterlab matplotlib opencv boto3 -y

echo "match the python version"
python -m ipykernel install --user --name=$ENV
```

### Cleanup script

```
#!/bin/bash

# UPDATE YOUR ENV NAME
ENV=solar-flare

eval "$(conda shell.bash hook)"

echo "init the conda env"
conda init bash

echo "deactive conda env"
conda deactivate

# wait for 5 seconds
sleep 5

echo "delete conda env"
conda env remove --name=$ENV -y
```

## Launch Dev Space based on github devfile.yaml

