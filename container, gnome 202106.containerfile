# syntax=docker/dockerfile:1
FROM minimum:202106
RUN zypper refresh ; \
    zypper --non-interactive dist-upgrade ; \
#   install base packages
    zypper --non-interactive install --type pattern base documentation non_oss yast2_basis ; \
#   install packages used for compiling (not installing: rust cargo devel_python3)
    zypper --non-interactive install gcc openmpi openmpi-devel ; \
    zypper --non-interactive install --type pattern devel_basis devel_C_C++ ; \
    zypper clean --all ;
RUN zypper refresh ; \
    zypper --non-interactive dist-upgrade ; \
#   install gnome (not installing: bijiben evolution gnome-documents gnome-icon-theme gnome-menus gnome-music gnome-photos gnome-search-tool gnome-shell gnome-themes gnome-tweaks gnome-tweak-tool)
    zypper --non-interactive install --type pattern gnome ; \
    zypper --non-interactive install eog gedit gnome-backgrounds gnome-calculator gnome-screenshot gnome-system-monitor gnome-terminal gnome-usage nautilus ; \
#   install other packages (not installing: bleachbit MozillaThunderbird)
    zypper --non-interactive install --type pattern --recommends enhanced_base ; \
    zypper --non-interactive install --recommends libreoffice ; \
    zypper --non-interactive install MozillaFirefox xrdp ; \
    zypper clean --all ;
RUN zypper refresh ; \
    zypper --non-interactive dist-upgrade ; \
#   install fonts (not installing: libfonts)
    zypper --non-interactive install --type pattern --recommends fonts ; \
    zypper --non-interactive install adobe-sourcehansans-cn-fonts adobe-sourcehanserif-cn-fonts ; \
    zypper --non-interactive install noto-sans-cjk-fonts noto-sans-sc-fonts noto-serif-sc-fonts noto-sans-tc-fonts noto-serif-tc-fonts ; \
#   install Chinese input method
    zypper --non-interactive install ibus ibus-libpinyin ; \
    zypper clean --all ;
# RUN systemctl set-default graphical.target
RUN systemctl enable wicked ; \
    systemctl enable xrdp ;
# modify /etc/xrdp/xrdp.ini : tcp_keepalive=false|true crypt_level=medium max_bpp=16 [Xvnc]xserverbpp=16 [Xvnc]port=ask-1
# modify /etc/xrdp/sesman.ini : AllowRootLogin=false "ensure MaxSessions >= 50" KillDisconnected=true Policy=UBI IdleTimeLimit=3600
EXPOSE 3389/tcp


# set locale, timezone, keyboard layout, etc for each user. la /etc/sysconfig/. otherwise, root's locale is empty, which will make gnome-terminal not able to open. non-root user can set it automatically.
# set US and ZN-pinyin input method available in ibus. gsettings help.


# install ftp or nfs file servers and enable services

