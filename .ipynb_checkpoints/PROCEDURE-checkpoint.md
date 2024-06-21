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

## RHOAI

Create a Project. 

1. Create Project
1. Git clone repo
1. Apply cookiecutter data science https://cookiecutter-data-science.drivendata.org/

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
1. Settings 
    1. Cloud Storage
    1. Storage Type AWS S3
    1. Storage Title Solar Flare Data
    1. Bucket Name data
    1. Region Name us-east-2
    1. S3 Endpoint http://minio.minio.svc:900
    1. Access Key ID minioadmin
    1. Secret Access Key minioadmin
    1. Treat every bucket as a source file TRUE
    

## Create job for ETL

A job automates the completion of a task only once, in contrast to a replication controller, runs a pod with any number of replicas to completion. A job tracks the overall progress of a task and updates its status with information about active, succeeded, and failed pods. [source](https://docs.openshift.com/container-platform/3.11/dev_guide/jobs.html#dev-guide-jobs)

*A replication controller ensures that a specified number of replicas of a pod are running at all times. If pods exit or are deleted, the replication controller acts to instantiate more up to the defined number.*

A job configuration consists of the following key parts:

1. A pod template, which describes the application the pod will create.
1. An optional parallelism parameter, which specifies how many pod replicas running in parallel should execute a job. If not specified, this defaults to the value in the completions parameter.
1. An optional completions parameter, specifying how many concurrently running pods should execute a job. If not specified, this value defaults to one.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: gong-data-etl
spec:
  parallelism: 1    
  completions: 1    
  template:         
    metadata:
      name: pi
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: OnFailure    
```

parallelism: Optional value for how many pod replicas a job should run in parallel; defaults to completions
completions: Optional value for how many successful pod completions are needed to mark a job completed; defaults to one.
template: Template for the pod the controller creates.
restartPolicy: The restart policy of the pod. This does not apply to the job controller.

### Job usage

You can create the job in a namespace

```
oc create -f jobs.yaml -n <Project/Namespace>
```

You can also create and launch a job from a single command using oc run. The following command creates and launches the same job as specified in the previous example:

```
$ oc run pi --image=perl --replicas=1  --restart=OnFailure \
    --command -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

A job can be scaled up or down by using the oc scale command with the --replicas option, which, in the case of jobs, modifies the spec.parallelism parameter.

A job can be defined by maximum duration by setting the activeDeadlineSeconds field. It is specified in seconds and is not set by default. When not set, there is no maximum duration enforced.

## Create Cronjob for ETL

A cron job builds on a regular job by allowing you to specifically schedule how the job should be run.

## Copying local files to the Container

Support for copying local files to or from a container is built into the `oc` CLI. You MUST install `rysnc` on the client. [source](https://docs.openshift.com/container-platform/4.14/nodes/containers/nodes-containers-copying-files.html)

```sh
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

# gunzip the files
for f in *.gz; do
  gzip -d "$f" &
done
wait

# check files (1138 count)
ls -l . | wc -l

# manual upload files to minio storage bucket
```

### Cleanup script

## Launch Dev Space based on github devfile.yaml
