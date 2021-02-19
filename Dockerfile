FROM archlinux:base-20210207.0.15200 AS arch

RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
    bsdtar -C / -xvf "$patched_glibc"

RUN pacman -Syu base-devel git --noconfirm --overwrite '*' --ignore glibc && sed -i '/E_ROOT/d' /usr/bin/makepkg
RUN useradd -m -G wheel -s /bin/bash build
RUN perl -i -pe 's/# (%wheel ALL=\(ALL\) NOPASSWD: ALL)/$1/' /etc/sudoers
USER build
#RUN cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm
# https://bbs.archlinux.org/viewtopic.php?id=229027, eli schwartz

RUN echo "why this is cached"

RUN cd /tmp && git clone https://aur.archlinux.org/yay.git
RUN cd yay && source PKGBUILD && pacman -Syu --noconfirm && pacman -S --noconfirm --needed --asdeps "${makedepends[@]}" "${depends[@]}"

USER root
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

