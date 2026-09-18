# shell cheat sheet — hardening lab

A minimal Linux shell reference for the workshop. Covers moving around, finding
things, reading files, and the build/redirect patterns the lab slides use.

## Move around & look

```sh
pwd                 # where am I?
ls -l               # list files (long form); -a also shows hidden (dotfiles)
cd ~/rpmbuild       # change directory (~ = your home)
cd -                # jump back to the previous directory
tree -L 2           # directory tree, 2 levels deep (if installed)
```

## Read & search files

```sh
less <file>                 # page through a file (q to quit, / to search)
cat <file>                  # dump a whole file
head -n 20 <file>           # first 20 lines;  tail -n 20  = last 20
tail -f build.log           # follow a log as it grows
grep -- '-fstrict-flex-arrays' build.log   # find a pattern (-- ends options)
grep -rn "pattern" .        # recursive, with line numbers
```

## Wildcards (globbing)

```sh
ls ~/rpmbuild/BUILD/bzip2-*/       # * = any characters
cd ~/rpmbuild/BUILD/bzip2-*/bzip2-*/   # chain globs to descend nested dirs
ls *.log                            # everything ending in .log
```

## Run tools, capture output

```sh
make                         # run the default build
make 2>&1 | tee build.log    # run, show output AND save it to a file
make |& tee build.log        # bash shorthand for `2>&1 | tee`
make CFLAGS="-O2 -Wall"      # pass a variable into the build
command > out.log 2>&1       # redirect stdout + stderr to a file
command 2>/dev/null          # discard errors
```

`2>&1` means "send errors (fd 2) to the same place as normal output (fd 1)".
`tee` writes to a file *and* the screen at once.

## Chaining commands

```sh
a && b     # run b only if a succeeded
a || b     # run b only if a failed
a ; b      # run a then b regardless
a | b      # pipe a's output into b
$(cmd)     # substitute a command's output, e.g.  cd $(git rev-parse --show-toplevel)
```

## Privileges & packages (Fedora)

```sh
sudo <cmd>                    # run as root (passwordless in this lab image)
dnf search all <pattern>      # find packages by name/summary/description
dnf download --srpm <pkg>     # fetch a source RPM
dnf provides <path-or-cmd>    # which package ships a given file/binary
rpm -q --qf '%{VERSION}\n' <pkg>   # query an installed package
```

## Handy

```sh
history                 # commands you have run
!!                      # repeat the last command (e.g.  sudo !!)
Ctrl-r                  # search command history interactively
Ctrl-c                  # stop the running command
man <cmd>  /  <cmd> --help   # documentation for a command
```

> The lab reference files (this sheet, the git sheet, the pylint config) live in
> `/doc` inside the container.
