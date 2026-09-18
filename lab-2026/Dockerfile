# Fedora hardening lab image for the "Raising the Security Bar" tutorial.
# Self-contained / offline-capable: toolchain + bzip2/libxml2 SRPMs + build deps
# are baked in so no network is needed at workshop time.
FROM fedora:41

# --- toolchain + analysis tools ---------------------------------------------
RUN dnf -y install \
        gcc clang make cmake meson ninja-build \
        autoconf automake libtool pkgconf-pkg-config bison flex texinfo \
        rpm-build rpmdevtools 'dnf-command(builddep)' 'dnf-command(download)' cpio \
        checksec binutils elfutils file \
        openssl devscripts \
        perf \
        openssh-server nftables systemd \
        lynis \
        sudo time \
        procps-ng iproute \
        git tree \
        libasan libubsan libcmocka-devel check-devel \
        python3-pylint python3-pip \
        cargo rust \
    && dnf clean all
# Analysis/build toolchain rationale:
#   cmake meson ninja-build + autotools : the candidate packages' varied build systems
#   openssl                             : checksec needs it for its full check set
#                                         (without it checksec warns "openssl not found")
#   devscripts                          : provides /usr/bin/hardening-check (the second
#                                         binary-hardening checker shown on the slides;
#                                         Fedora ships it inside devscripts, no standalone pkg)
#   git                                 : clone a target package
#   libasan libubsan                    : RUNTIME libs for -fsanitize=address/=undefined
#                                         (without libasan, ASan-linked test binaries fail
#                                         with "libasan.so.N: cannot open shared object file")
#   libcmocka-devel check-devel         : C unit-test frameworks (libcbor uses CMocka)
#   python3-pylint                      : the Python-track linter task (reference .pylintrc
#                                         is copied into the image at /doc/.pylintrc)
#   cargo rust                          : to build weggli (the flex-array finder) below

# --- weggli (AST-grep finder for flex-array candidates) ---------------------
# weggli is NOT packaged in Fedora, so build it with cargo. This needs network at
# image BUILD time (not at workshop time). Pinned to a known-good version.
RUN cargo install weggli --version 0.2.4 --root /usr/local \
    && /usr/local/bin/weggli --version
# Fedora's python3-pylint ships the CLI as `pylint-3`, not a bare `pylint`;
# add the `pylint` name so the workshop instructions (`pylint --rcfile=…`) work.
RUN ln -sf /usr/bin/pylint-3 /usr/local/bin/pylint \
    && pylint --version | head -1
# ============================================================================
# !!! SECURITY WARNING — DISPOSABLE TEACHING IMAGE ONLY, NOT FOR PRODUCTION !!!
# ----------------------------------------------------------------------------
# The block below deliberately weakens the container's account security so the
# workshop works for any invoking user:
#   * grants passwordless sudo to EVERY user (ALL ALL=(ALL) NOPASSWD:ALL), and
#   * makes /etc/passwd (0664) and /etc/shadow (0660) group-writable so an
#     arbitrary `-u <uid>` (which runs with gid 0) can append its own account
#     entry at container start (see entrypoint.sh).
# A world-/group-writable /etc/shadow and blanket NOPASSWD sudo would be a
# serious vulnerability in any real system. This is acceptable ONLY because the
# image is ephemeral, offline, and thrown away after the lab. DO NOT copy this
# pattern into a production image or any long-lived/networked container.
# ============================================================================
# Grant passwordless sudo. The workshop image is run two ways:
#   * as the default `student` user, and
#   * `docker run -u $(id -u)` (see `make run`), which yields an ARBITRARY uid with gid 0.
# The `ALL` rule covers both. Arbitrary uids have no /etc/passwd entry, which sudo
# refuses ("you do not exist in the passwd database"), so the entrypoint below adds
# one at container start. Making /etc/passwd writable by group root (gid 0) lets that
# entry be appended, since `-u <uid>` runs with gid 0.
RUN echo 'student ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/student \
    && echo 'ALL ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/all-users \
    && chmod 0440 /etc/sudoers.d/student /etc/sudoers.d/all-users \
    && chmod 0664 /etc/passwd \
    && chmod 0660 /etc/shadow

# --- non-root workshop user -------------------------------------------------
RUN useradd -m student && rpmdev-setuptree || true
WORKDIR /home/student
USER student
RUN rpmdev-setuptree

# --- bake the target SRPMs + their build deps in (offline) ------------------
USER root
RUN dnf -y --enablerepo=fedora-source,updates-source download --source bzip2 libxml2 --destdir=/home/student \
    && dnf -y builddep /home/student/bzip2-*.src.rpm /home/student/libxml2-*.src.rpm \
    && chown -R student:student /home/student \
    && dnf clean all

# --- build deps for the GitHub C/C++ example targets (offline build support) --
# The "pick a target" slide lists these upstream C/C++ repos for the warning-flag /
# hardening-flag track. Bake in their build dependencies so a cloned checkout builds
# without network at workshop time. Verified 2026-09: with these installed, each repo
# `cmake`/`./configure`-configures and compiles in the lab image.
#   * assimp, ImageMagick, freerdp : Fedora `builddep` pulls the authoritative
#     dependency set for each (KRB5, ICU, OpenSSL, zlib, PCSC, …).
#   * libde265 : not in Fedora's base source repos (lives in RPM Fusion), but it
#     builds from the base toolchain already present — no extra deps needed.
#   * libheif : deliberately NOT builddep'd. `builddep libheif` drags in
#     libaom-devel, whose Fedora-shipped CMake targets reference a static
#     /usr/lib64/libaom.a that Fedora does not package, which then breaks
#     libheif's find_package(AOM). libheif builds fine against the base toolchain
#     + libde265; configure it with `-DWITH_AOM_DECODER=OFF -DWITH_AOM_ENCODER=OFF`
#     to skip the optional (and broken-on-Fedora) AV1 codec.
#   * ffmpeg-free-devel : FreeRDP's upstream HEAD requires FFmpeg (AVCODEC/AVUTIL),
#     which the Fedora freerdp spec does not pull in via builddep — add it explicitly.
# (bzip2/libxml2 remain the primary offline targets; these extend the C/C++ menu.)
RUN dnf -y builddep assimp ImageMagick freerdp \
    && dnf -y install ffmpeg-free-devel \
    && dnf clean all

USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

# --- man pages for the workshop-relevant tools ------------------------------
# The base Fedora image sets `tsflags=nodocs`, so no package ships its man pages
# (`man git-commit`, `git commit --help`, `man gcc`, … all say "No manual entry").
# Restore docs for the tools participants will actually look up. Packages already
# present were installed nodocs, so a plain `install` is a no-op for their docs —
# they must be *reinstalled* with tsflags cleared to lay the man files down.
# git's man pages live in the separate git-core-doc package. Total cost ~30 MB.
RUN dnf -y --setopt=tsflags= install man-pages git-core-doc \
    && dnf -y --setopt=tsflags= reinstall \
        bash coreutils grep sed gawk findutils util-linux \
        git-core git-core-doc gcc clang make cmake rpm rpm-build \
        openssl nftables lynis systemd iproute checksec binutils \
    && dnf clean all

# --- reference docs in /doc (world-readable, for use in the container) ------
# Cheat sheets + the pylint config live in /doc so participants can read them
# inside the container. The slides reference `pylint --rcfile=/doc/.pylintrc`.
RUN mkdir -p /doc
COPY git-cheat-sheet.md shell-cheat-sheet.md rpm-cheat-sheet.md /doc/
COPY .pylintrc /doc/.pylintrc
RUN chmod -R a+rX /doc

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
