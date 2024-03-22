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