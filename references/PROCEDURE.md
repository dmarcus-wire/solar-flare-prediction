## Environment

Install the Web Terminal Operator via the OperatorHub - [linked here](https://github.com/redhat-na-ssa/demo-ai-gitops-catalog/tree/main?tab=readme-ov-file#bootstrapping-a-cluster)

### Baseline

Configure the cluster.

```sh
# Install the Web Terminal Operator via the CLI 
# Reference: https://github.com/dmarcus-wire/web-terminal-operator.git

# bootstrap the cluster from the Web Terminal copying, pasting and running the following script
YOLO_URL=https://raw.githubusercontent.com/codekow/demo-ai-gitops-catalog/main/scripts/library/term.sh
. <(curl -s "${YOLO_URL}")
term_init

# make custom web terminal persistent
oc apply -k bootstrap/install-web-terminal

# load functions
. scripts/functions.sh
```

### GPUs

Configure NVIDIA GPUs.

```sh
# setup a rhods demo /w gpu
apply_firmly demos/rhods-nvidia-gpu-autoscale
```

## Minio Object Storage

Configure Object Storage.

MinIO is a high performance, distributed object storage system. It is software-defined, runs on industry standard hardware and is 100% open source with the dominant license being GNU AGPL v3. [source](https://min.io/product/overview)

From the Web Terminal

```sh
# deploy minio object storage in a namespace 'minio' from the web terminal
oc apply -k components/configs/kustomized/minio/overlays/with-namespace-known-password

# manually create a bucket

# manually create an access key
```

1. Go to `minio` project
1. Go to Networking > Routes
1. Click `minio-console` URL
1. Get the username and password Worloads > Secrets > `minio-root-user` > Reveal values
1. Click `Create a Bucket`
    1. Name: `gong2`
    1. Versioning: `False`
    1. Object Locking: `False`
    1. Quota: `False`

## Label Studio

Configure a data labelling platform.

- Text (txt)
- Audio (wav, mp3, flac, m4a, ogg)
- Video (mpeg4/H.264 webp, webm*)
- Images (jpg, jpeg, png, gif, bmp, svg, webp)
- HTML (html, htm, xml)
- Time Series (csv, tsv)
- Common Formats (csv, tsv, txt, json)

```sh
oc apply -k components/configs/kustomized/label-studio/overlays/default/
```

1. Login
1. Create Project
    1. Project Name: Solar Flare
    1. Description: Labeling GONG2 data for solar flare prediction
    1. Data Import: Cloud Storage

## Advanced Cluster Security

1. Deploy ACS via Kustomize from the [ai-gitops-catalog](https://github.com/redhat-na-ssa/demo-ai-gitops-catalog/tree/main/components/operators/rhacs-operator)

```
# clone the ai-gitops-catalog
git clone https://github.com/redhat-na-ssa/demo-ai-gitops-catalog.git && cd demo-ai-gitops-catalog

# apply the kustomization configs
oc apply -k components/operators/rhacs-operator/operator/overlays/latest

# create an instance 
oc apply -k components/operators/rhacs-operator/instance/overlays/internal-registry-integration

# access the URL via Project 'stackrox' > Networking > routes > 'central' 
# use uname and pwd from workloads > secrets > 'central-htpasswd'
```