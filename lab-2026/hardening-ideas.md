# Hardening & hygiene ideas — what to change

## C / C++

**1. Turn on warnings** (a warning can be a bug the compiler already found):

```sh
-Wall -Wextra \
  -Wflex-array-member-not-at-end \
  -Wformat=2 -Wformat-security \
  -Wvla -Wshadow -Wstringop-overflow=4
```

Note: `-Wflex-array-member-not-at-end` is **not** in `-Wall`/`-Wextra` — add it
by name.

**2. Make warnings fatal** (stops new warnings creeping in):

```sh
-Werror
```

Adopt `-Werror` gradually: fix a warning class, then `-Werror=<that-class>`.

**3. Add hardening flags:** (can have performance impact)

```sh
-fstrict-flex-arrays=3 -ftrivial-auto-var-init=zero
```

**4. Fix the errors** the compiler now reports.

Apply flags in a build, e.g.:

```sh
make CFLAGS="-O2 -Wall -Wextra -fstrict-flex-arrays=3 -ftrivial-auto-var-init=zero"
# confirm the flag reached the compiler (NOT via checksec):
grep -- '-fstrict-flex-arrays' build.log
```

## Python

```sh
pylint --rcfile=.pylintrc <package>/
```

Read the findings and fix them. Focus on `W` (warning) and `E` (error). The lab
config already disables the noisy ones. Ignore the `C` (convention) and `I`
(info) categories at the beginning. 

## Why each hardening flag matters

- `-fstrict-flex-arrays=3`: lets FORTIFY bound trailing arrays correctly, so a
  fake `[1]` buffer can't hide a heap overflow.
- `-ftrivial-auto-var-init=zero`: zero-initialises local variables, killing a
  class of uninitialised-memory (info-leak) bugs.
- `-Wall -Wextra -Werror`: the cheapest win: stop shipping code the compiler
  already knows is questionable.
