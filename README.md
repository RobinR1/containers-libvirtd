# Libvirt container
This container runs a libvirtd instance in an openSUSE Tumbleweed environment.

It will autostart virtual machines that are set to autostart inside libvirt. It will
also suspend virtual machines still running when the container is stopped and
re-activate those virtual machines again when the container is started again.

It is intended to be run with `host` networking and has an SSH daemon active to remotely connect
for example virt-manager to it. 
For a correct functioning of the virtualization, this container needs to be run in `privileged` mode

It will retain virtual machines and VM configuration files using a seperate 
volume for `/var/lib/libvirt` and `/etc/libvirt/qemu`.

## Starting container
Start the container as follows:
```bash
podman run --privileged --net=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
-v /var/lib/libvirt/:/var/lib/libvirt/ -v libvirtd_vm_configs:/etc/libvirt/qemu \
-e ROOT_PASSWORD="some-password" -e SSHD_PORT="some-port" --name some-libvirtd sicho/libvirtd
```
Where `some-libvirtd` is the name you want to assign to your container. `some-password` is the
password to set for the `root`-user, and `some-port` is the port the SSH daemon will listen on. 
The SSH port will default to 22 but will then probably fail to start if the host system already
has SSH running on port 22.
Tip: add `-v /root/.ssh:/root/.ssh` to share the root SSH keys from the host system with this
system.

## Container shell access
Since the container is running an SSH Daemon you can connect to it using SSH to the `SSHD_PORT`
on the host system.
Otherwise you can also gain shell access using:
```bash
docker exec -ti some-libvirtd /bin/bash
```

## Environment variables
When you start the `libvirtd` image, you can adjust the configuration of the container by passing
one or more environment variables on the `podman run` command line.
### `ROOT_PASSWORD`
This variable sets the password for the `root` user inside the container. This password is required
to SSH into the host when not using an authorized ssh key.
### `SSHD_PORT`
This variable sets the port the SSH daemon needs to listen on. This defaults to port 22 but will
then probably conflict with an SSH daemon already running on the host system as this container is
intended to run with `host` network.

## Volumes
### `/var/lib/libvirt`
The volume is used to store the images of the virtual machines
### `/etc/libvirt/qemu`
The volume is used to store the virtual machine configuration files
### `/sys/fs/cgroup`
As this container is running systemd, it requires `rw` access to the host systems `/sys/fs/cgroup`.
So make sure to mount this volume using `-v /sys/fs/cgroup:/sys/fs/cgroup:rw`
