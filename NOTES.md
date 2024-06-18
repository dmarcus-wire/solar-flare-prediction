## Create a Redis Pod to Use a Volume for Storage

*ruled out because its key-value  Create a Redis Pod to Use a Volume for Storage*

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
oc exec -it redis -- /bin/bashex
```

### Install and configure the minio client to sync data

*ruled out because not needed for this demonstration of data movement*

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

## Notes on containers

Linux containers have emerged as a key open source application packaging and delivery technology, combining lightweight application isolation with the flexibility of image-based deployment methods. Red Hat Enterprise Linux implements Linux containers using core technologies such as:

- Control groups (cgroups) for resource management
- Namespaces for process isolation
- SELinux for security
- Secure multi-tenancy

Unlike other container tools implementations, the tools described here do not center around the monolithic Docker container engine and docker command. Instead, Red Hat provides a set of command-line tools that can operate without a container engine. These include:

1. podman - for directly managing pods and container images (run, stop, start, ps, attach, exec, and so on)
1. buildah - for building, pushing, and signing container images
1. skopeo - for copying, inspecting, deleting, and signing images
1. runc - for providing container run and build features to podman and buildah
1. crun - an optional runtime that can be configured and gives greater flexibility, control, and security for rootless containers

Because these tools are compatible with the Open Container Initiative (OCI), they can be used to manage the same Linux containers that are produced and managed by Docker and other OCI-compatible container engines. However, they are especially suited to run directly on Red Hat Enterprise Linux, in single-node use cases. For a multi-node container platform, see OpenShift and Using the CRI-O Container Engine for details.

What is OCI? The Open Container Initiative is an open governance structure for the express purpose of creating open industry standards around container formats and runtimes.

Established in June 2015 by Docker and other leaders in the container industry, the OCI currently contains three specifications: 
1. the Runtime Specification (runtime-spec) - defines how to run the OCI image bundle as a container.
1. the Image Specification (image-spec) - defines how to create an OCI Image, which includes an image manifest, a filesystem (layer) serialization, and an image configuration.
1. and the Distribution Specification (distribution-spec) 

The main advantages of Podman, Skopeo and Buildah tools include:

1. Running in rootless mode - rootless containers are much more secure, as they run without any added privileges
1. No daemon required - these tools have much lower resource requirements at idle, because if you are not running containers, Podman is not running. Docker, conversely, have a daemon always running
1. Native systemd integration - Podman allows you to create systemd unit files and run containers as system services

The characteristics of Podman, Skopeo, and Buildah include:

1. Podman, Buildah, and the CRI-O container engine all use the same back-end store directory, /var/lib/containers, instead of using the Docker storage location /var/lib/docker, by default.
1. Although Podman, Buildah, and CRI-O share the same storage directory, they cannot interact with each other’s containers. Those tools can share images.
1. To interact programmatically with Podman, you can use the Podman v2.0 RESTful API, it works in both a rootful and a rootless environment. For more information, see Using the container-tools API chapter.

### Why not Docker?
Running the container tools such as Podman, Skopeo, or Buildah as a user with superuser privileges (root user) is the best way to ensure that your containers have full access to any feature available on your system. However, with the feature called "Rootless Containers" generally available as of Red Hat Enterprise Linux 8.1, you can work with containers as a regular user.

Although container engines, such as Docker, let you run Docker commands as a regular (non-root) user, the Docker daemon that carries out those requests runs as root. As a result, regular users can make requests through their containers that can harm the system. By setting up rootless container users, system administrators prevent potentially damaging container activities from regular users, while still allowing those users to safely run most container features under their own accounts.

(source)[https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/building_running_and_managing_containers/index#assembly_starting-with-containers_building-running-and-managing-containers]

Red Hat removed the Docker container engine and the docker command from RHEL 9.

(source)[https://access.redhat.com/solutions/3696691]

Containerfile "the instructions required to build an image". 