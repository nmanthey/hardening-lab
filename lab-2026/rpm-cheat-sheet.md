# rpm & rpmbuild cheat sheet — hardening lab

Working with Fedora packages: get a package's source, unpack it, rebuild it
(optionally with extra hardening flags), and inspect the result. All commands
below were verified in the lab container.

## The mental model

A Fedora **source RPM** (`.src.rpm`) = the pristine upstream tarball **+ the
distro's patches + a `.spec` recipe**. `rpmbuild` applies the patches and builds
**binary RPMs** from it. The `~/rpmbuild/` tree is where all of this happens.

```
~/rpmbuild/
  SPECS/     the .spec recipe
  SOURCES/   upstream tarball + distro patches
  BUILD/     unpacked, patched, buildable source (after -bp)
  RPMS/      finished binary RPMs (after -bb/-ba)
  SRPMS/     finished source RPMs
```

## 1. Get a source package

```sh
dnf download --srpm bzip2          # fetch bzip2's .src.rpm (offline in the lab)
dnf download --source bzip2        # classic dnf spelling of the same thing
rpm -q --qf '%{VERSION}\n' bzip2   # what version is installed?
```

## 2. Set up the build tree & unpack

```sh
rpmdev-setuptree                   # create ~/rpmbuild/{SPECS,SOURCES,BUILD,...}
rpm -i bzip2-*.src.rpm             # install the SRPM: spec -> SPECS/, sources -> SOURCES/
#   note: `rpm -i` on a .src.rpm does NOT install a package; it just lays out the tree
rpm2cpio bzip2-*.src.rpm | cpio -idmv   # alternative: extract without the tree
```

## 3. Assemble the real (patched) source

```sh
rpmbuild -bp ~/rpmbuild/SPECS/bzip2.spec
#   -bp = "build prep": unpack tarball + apply distro patches
#   -> patched, buildable tree under ~/rpmbuild/BUILD/bzip2-*/bzip2-*/
```

## 4. Rebuild the whole package

```sh
rpmbuild --rebuild bzip2-*.src.rpm              # one-shot: prep -> build -> package
rpmbuild -ba ~/rpmbuild/SPECS/bzip2.spec        # build from a spec: binary + source RPMs
rpmbuild -bb ~/rpmbuild/SPECS/bzip2.spec        # binary RPMs only
rpmbuild --rebuild --nocheck libxml2-*.src.rpm  # skip %check (faster; note you skipped tests)
#   finished binaries land in ~/rpmbuild/RPMS/<arch>/
```

## 5. Rebuild WITH extra hardening flags

```sh
# inject flags via --define 'optflags ...' (append to the distro defaults):
BASE=$(rpm --eval %{optflags})     # the distro's default compiler flags
rpmbuild --rebuild \
  --define "optflags $BASE -fstrict-flex-arrays=3 -ftrivial-auto-var-init=zero" \
  bzip2-*.src.rpm

# confirm the flags actually reached the compiler (NOT via checksec):
grep -- '-fstrict-flex-arrays' ~/rpmbuild/BUILD/*/build.log
```

Bump the version so the rebuilt RPM is distinguishable from the stock one:

```sh
rpmdev-bumpspec -c "Add flex-array + auto-var-init hardening" bzip2.spec
```

## 6. Inspect packages & the spec

```sh
rpm -qp --qf '%{NAME} %{VERSION}-%{RELEASE}\n' *.rpm   # query an RPM file
rpm -qlp bzip2-*.rpm           # list files a binary RPM would install
rpm -qip bzip2-*.rpm           # info (summary, license, size) of an RPM file
rpm --eval %{optflags}         # show the distro's default build flags
rpm --eval %{_topdir}          # show ~/rpmbuild
rpmspec -P ~/rpmbuild/SPECS/bzip2.spec   # print the spec with macros expanded
```

## Extract a built binary from an RPM (no install needed)

```sh
mkdir out && cd out
rpm2cpio ~/rpmbuild/RPMS/*/bzip2-1*.rpm | cpio -idmu   # unpack the RPM payload
find . -name bzip2 -type f                             # locate the binary
```

> Tip: `man rpm`, `man rpmbuild`, `rpmbuild --help`. The lab reference files
> (this sheet, the git and shell sheets, the pylint config) live in `/doc`.
