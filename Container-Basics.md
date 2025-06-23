# Container Technology

- Terminologies
    - OCI - Open Container Initiative  
    - CRI - Container Runtime Interface  
    - CNI - Container Network Interface  

- Container Runtime => s/w used to run containers (e.g. docker, rkt, cri-o)  

- Two ways make container isolates the processes
    - Linux Namespaces
        - each process sees it's personal view of system (files, process, n/w interfaces, hostname)
    - cgroups => Control Groups
        - limits the resources like CPU, memory, n/w b/w

- Linux Namespaces
    - by default, all system resources (filesystems, process IDs, user IDs, 
    network interfaces, etc) belong to single namespace
    - One can create additional namespaces and organize resources across them
    - When running a process, you run it inside one of those namespaces
    - The process will only see resources that are inside the same namespace
    - multiple kinds of namespaces exist, so a process doesn’t belong to one 
    namespace, but to one namespace of each kind.
    -  kinds of namespaces 
        - Mount (mnt)
        - Process ID (pid)
        - Network (net)
            - Which n/w namespace a process belongs to determines which n/w 
            interfaces the application running inside the process sees.
            - Each n/w interface belongs to exactly one namespace
            - n/w interface can be moved from one namespace to another
            - Each container uses its own Network namespace, and therefore 
            each container sees its own set of network interfaces
        - Inter-process communication (ipc)
        - UTS (Unix Time-Sharing)
            - What hostname and domain name the process running inside that 
            namespace sees
            -  By assigning two different UTS namespaces to a pair of processes, 
            you can make them see different local hostnames
            - It will appear two processes are running on diff m/c's
        - User ID (user)

- cgroups
    - limiting the amount of system resources a container can consume
    - limits the resource usage of a process (or a group of processes)
    - A process can’t use more than the configured amount of CPU, memory, 
    n/w bandwidth, and so on.


- Docker was the first container platform that made containers mainstream  
- Docker doesn't provide process isolation, but linux kernel does it using namespaces and cgroups.  
- Docker makes it easier for user to use linux kernel features for process isolation  
- With success of Docker, Open Container Initiative (OCI) was born
- OCI Objective => create open industry standards around container formats and runtime  

- rkt (pronounced as rock-it) is a platform for running containers
    - emphasis is on security, composability, and conforming to open standards

- Limitation of docker/containers
    - containers shares the linux kernel
    - so if an app require specific kernel or made for specific h/w then such 
    container apps are not portable across container runtimes

- Limitation of docker/containers (w/o k8s or equivalent mgmt s/w)
    - tied to lifecycle of VM => VM fails container stops
    - VM mount point used for data. If it fails then container's state data lost

- Container images
    - build by layers
    - alpine => min base image for a cloud app
    - layers are managed by overlay fs driver

- Every RUN command creates an image layer.
    - Sol: club all RUN commands using &&

- ENTRYPOINT can not be overridden, use CMD instead to override it




