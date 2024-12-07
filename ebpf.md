# Documenting eBPF related stuff

## One of way to identify/find syscall name supported on target machine

```bash
ls -l /proc/kallsyms
```

## Program types and attachments types are defined in

```bash
ls -l uapi/linux/bpf.h

# enum bpf_prog_type {} and enum bpf_prog_type {}
```
# List of which helper functions are available for each program type
```bash
sudo bpftool feature

# This provides list for your version of the kernel
```