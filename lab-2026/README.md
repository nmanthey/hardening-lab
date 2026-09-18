# Raising the Security Bar — hands-on material

Welcome! This folder is **yours to keep**. It has everything you need to follow
the workshop and to keep contributing afterwards. You can either load a pre-built
container image (`festival-hardening-lab-f41.tar.gz`, if you were given one) or
build it yourself from the `Dockerfile` here.

## What's here

| File | What it is |
|------|------------|
| `README.md` | this file |
| `Makefile` | `make import` + `make run` to use the lab; `make build` + `make export` to build it yourself |
| `Dockerfile` | recipe for the lab image (used by `make build`) |
| `entrypoint.sh` | container entrypoint (registers your user so `sudo` works) |
| `git-cheat-sheet.md` | the git commands you'll use (clone, branch, diff, commit, patch/PR) |
| `shell-cheat-sheet.md` | Linux shell basics (moving around, searching, build + redirect) |
| `rpm-cheat-sheet.md` | rpm & rpmbuild: get a package's source, rebuild it, add hardening flags |
| `.pylintrc` | the Python linter config — baked into the image at `/doc/.pylintrc`, and here for take-home use |
| `package-ideas.md` | packages you can pick as a target — C/C++ and Python |
| `hardening-ideas.md` | the compiler warnings & hardening flags to add, and the pylint task |

> The same cheat sheets and `.pylintrc` are also inside the container in `/doc`.

## 1. Get the container

Either **load the pre-built image** you were given (fastest, no network):

```sh
make import      # = gunzip -c festival-hardening-lab-f41.tar.gz | docker load
```

…or **build it yourself** from the Dockerfile in this directory (needs network):

```sh
make build       # = docker build --network host -t festival-hardening-lab:f41 .
make export      # optional: write festival-hardening-lab-f41.tar.gz to share
```

(You need Docker installed. Once the image exists, the lab itself needs no
network — the tools and the bzip2/libxml2 sources are baked in.)

## 2. Open a shell in the container

```sh
make run
```

This drops you into a shell inside the lab, with your current directory mounted
so files you create are visible on your real machine too.

## 3. The workshop flow

1. **Measure** what already protects a shipped binary:
   `checksec /usr/bin/bzip2`, `hardening-check /usr/bin/bzip2`,
   `systemd-analyze security --offline=true /usr/lib/systemd/system/sshd.service`,
   `ss -tulpn`, `sudo lynis audit system`.
2. **Pick** a package (see `package-ideas.md`) and get its source
   (an RPM via `dnf download --srpm <pkg>`, or a git clone — see
   `git-cheat-sheet.md`).
3. **Add** a protection or fix a finding (see `hardening-ideas.md`).
4. **Rebuild** and confirm the flag reached the compiler
   (`grep -- '-fstrict-flex-arrays' build.log` — *not* via `checksec`).
5. **Re-measure** — the bar moved.
6. **Upstream** it (optional): a git pull request, a patch by email, or a
   distro package update. See `git-cheat-sheet.md`.

## 4. Take it home

You don't need the container to keep going: pick a project you use on GitHub,
fork it, and run the same moves:

- **Python:** clone it, run `pylint --rcfile=.pylintrc <package>/`, fix a
  finding, open a pull request.
- **C/C++:** build it, add `-Wall -Wextra -Werror` (or a hardening flag like
  `-fstrict-flex-arrays=3`), fix what the compiler now rejects, open a PR.

Start small: one warning, one file, one PR. The project's CI proves your fix.
