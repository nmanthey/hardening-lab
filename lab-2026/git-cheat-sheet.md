# git cheat sheet — hardening lab

A minimal git reference for the workshop: clone a package, make a change on your
own branch, review it, and prepare it for upstreaming. All commands below were
verified in the lab container.

## Get the code

```sh
git clone https://github.com/psf/requests.git   # download a repo + its history
cd requests
git clone --depth 20 <url>                       # shallow: only recent history (faster)
```

## Look around

```sh
git status                 # what changed / which branch you are on
git log --oneline -n 10    # recent commits (who changed what, and why)
git branch --show-current  # the branch you are on (clone default: main/master)
git show <commit>          # full diff + message of one commit
git blame <file>           # who last touched each line
```

## Work on your own branch (keep `main` clean)

```sh
git checkout -b hardening-fixes   # create + switch to a new branch
git switch main                   # switch back to an existing branch
git switch -                      # switch to the previous branch
```

## See and record your change

```sh
git diff                       # unstaged changes (what you edited)
git diff --staged              # changes already staged
git add <file>                 # stage a specific file  (prefer over `git add .`)
git commit -m "Fix a finding"  # record staged changes with a message
git commit -am "..."           # stage tracked files + commit in one step
```

Write a clear message: a short imperative subject ("Add -Wall to the build"),
a blank line, then *why* the change is needed.

## Turn a change into a patch (for email-based projects, e.g. the Linux kernel)

```sh
git format-patch -1                # make a .patch file from your last commit
git format-patch origin/main       # one patch per commit since main
# add your sign-off (the DCO: "I have the right to submit this")
git commit -s            # adds a "Signed-off-by:" line
git commit --amend -s    # add sign-off to the commit you just made
```

## Fork → push → pull request (for GitHub/GitLab projects)

```sh
# after forking in the web UI:
git remote add fork https://github.com/<you>/<project>.git
git push -u fork hardening-fixes   # push your branch to your fork
# then open the pull request from your fork in the web UI
```

## Undo (safe, non-destructive)

```sh
git restore <file>           # discard unstaged edits to a file
git restore --staged <file>  # unstage a file (keep the edit)
git revert <commit>          # make a NEW commit that undoes an old one
```

> Tip: `git <command> --help`, `git help <command>`, or `man git-<command>`
> explains every option (e.g. `git commit --help`).
