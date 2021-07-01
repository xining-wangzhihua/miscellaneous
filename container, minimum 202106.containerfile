# syntax=docker/dockerfile:1
FROM registry.opensuse.org/opensuse/tumbleweed:latest
LABEL vendor1="nwipb" author2=Sigmund\ Gray maintainer3="Sigmund Gray" \
      description="for bioinformatics" \
      version=0.0.1 release-date=20210617
SHELL ["/usr/bin/bash", "-c"]
RUN zypper refresh ; \
    zypper --non-interactive dist-upgrade ; \
    zypper --non-interactive install --recommends systemd ; \
    zypper --non-interactive install command-not-found curl dracut git info iproute2 make mlocate nano openssh shadow system-user-mail tree wget which udev ; \
    zypper --non-interactive install firewalld rsync sudo system-group-wheel wireguard-tools ; \
    which gawk   || zypper install gawk ; \
    which locale || zypper install glibc ; \
    which w      || zypper install procps ; \
    which xargs  || zypper install findutils ; \
    zypper clean --all ;
# ensure tar, gzip, xz, etc, are installed
# dmesg whereis are (is) provided by util-linux
RUN useradd --user-group --groups wheel --shell /usr/bin/bash --create-home UserA ; \
    useradd --no-user-group --gid UserA --create-home UserB && usermod --shell /usr/bin/bash UserB ; \
    chsh --shell /usr/bin/bash root ; \
#   try using xargs: echo {mm,fm,md,fd}; echo -e "mm\nfm\nmd\nfd\nmt\nft" | xargs --replace={} --verbose useradd --gid user1 --create-home {}
    bash -c "echo -e \"nwipb\nnwipb\" | passwd UserA" ; \
    bash -c "echo -e \"nwipb\nnwipb\" | passwd UserB" ; \
    bash -c "echo -e \"nwipb\nnwipb\" | passwd root" ; \
    echo -e "\nalias la='ls --format=long --almost-all --color=auto --group-directories-first'\n" >> /home/UserA/.bashrc ; \
    echo -e "\nalias la='ls --format=long --almost-all --color=auto --group-directories-first'\n" >> /home/UserB/.bashrc ; \
    echo -e "\nalias la='ls --format=long --almost-all --color=auto --group-directories-first'\n" >> /root/.bashrc ;
# RUN systemctl set-default multi-user.target
RUN systemctl disable firewalld ; \
    systemctl enable sshd ;
# modify /etc/ssh/sshd_config : "MaxSessions 3" "PasswordAuthentication no"
EXPOSE 22/tcp
CMD ["/usr/lib/systemd/systemd"]

# Try emptying the directory “/tmp/” after building images.
# consider put shell settings into ~/.profile instead of ~/.bashrc

