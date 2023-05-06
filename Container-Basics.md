# Container Technology

OCI - Open Container Initiative  
CRI - Container Runtime Interface  
CNI - Container Network Interface  

Container Runtime => s/w used to run containers (e.g. docker, rkt, cri-o)  

Two ways make container possible to isolate the processes
- Linux Namespaces
  - each process sees it's personal view of system (files, process, n/w interfaces, hostname)
- cgroups => Control Groups
  - limits the resources like CPU, memory, n/w b/w


Docker was the first container platform that made containers mainstream  
Docker doesn't provide process isolation, but linux kernel does it using namespaces and cgroups.  
Docker makes it easier for user to use linux kernel features for process isolation  

With success of Docker, Open Container Initiative (OCI) was born  
OCI Objective => create open industry standards around container formats and runtime  

rkt (pronounced as rock-it) is a platform for running containers
  - emphasis is on security, composability, and conforming to open standards

Limitation of docker/containers
 - containers shares the linux kernel
 - so if an app require specific kernel or made for specific h/w then such container apps are not portable across container runtimes

Limitation of docker/containers (w/o k8s or equivalent mgmt s/w)
 - tied to lifecycle of VM => VM fails container stops
 - VM mount point used for data. If it fails then container's state data lost

Container images
 - build by layers
 - alpine => min base image for a cloud app
 - layers are managed by overlay fs driver

Every RUN command creates an image layer. 
 - Sol: club all RUN commands using &&  

ENTRYPOINT can not be overridden, use CMD instead to override it 




