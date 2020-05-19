#!BuildTag: libvirtd
#
# podman pull registry.opensuse.org/home/RobinR1/containers/containers/libvirtd:latest
#
FROM opensuse/tumbleweed
MAINTAINER Robin Roevens <robin.roevens@disroot.org>

RUN zypper ref && \
    # Work around https://github.com/openSUSE/obs-build/issues/487 \
    zypper install -y openSUSE-release-appliance-docker && \
    zypper -n in qemu-kvm libvirt-daemon-qemu libvirt-client insserv-compat && \
    zypper clean -a ; \
    (cd /usr/lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /usr/lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /usr/lib/systemd/system/local-fs.target.wants/*; \
    rm -f /usr/lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /usr/lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /usr/lib/systemd/system/basic.target.wants/*; \
    rm -f /usr/lib/systemd/system/anaconda.target.wants/*; \
    # appropriately change permissions of the /dev/kvm device which is normally done by a udev rule \
    sed -i "/Service/a ExecStartPost=\/bin\/chmod 666 /dev/kvm" /usr/lib/systemd/system/libvirtd.service ; \
    systemctl enable libvirtd; systemctl enable virtlockd; systemctl enable libvirt-guests 

RUN zypper -n in openssh && \
    systemctl enable sshd && \
    mkdir -p /root/.ssh

COPY ["container_init.sh", "/usr/bin/"]
COPY ["container_init.service", "/etc/systemd/system/"]
RUN systemctl enable container_init

VOLUME [ "/sys/fs/cgroup" ]
VOLUME [ "/etc/libvirt/qemu" ]
VOLUME [ "/var/lib/libvirt" ]

CMD ["/usr/lib/systemd/systemd", "--system"]


