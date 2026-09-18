#!/bin/bash
# Ensure the current (possibly arbitrary) uid has an /etc/passwd entry so that
# tools which look up the invoking user work — most importantly sudo, which
# otherwise refuses with "you do not exist in the passwd database".
#
# When the image is run as `docker run -u $(id -u)`, the uid is arbitrary and has
# no passwd entry, but it runs with gid 0 (root group) and /etc/passwd is
# group-writable (see Dockerfile), so we can append an entry for it.
set -e

uid="$(id -u)"
if ! getent passwd "$uid" >/dev/null 2>&1; then
    home="${HOME:-/home/student}"
    printf 'labuser:x:%s:0:workshop user:%s:/bin/bash\n' "$uid" "$home" >> /etc/passwd 2>/dev/null || true
    # sudo's PAM stack runs `account required pam_unix.so`, which looks the user up
    # in /etc/shadow; without a shadow entry it fails with a PAM account error. Add a
    # locked-password shadow entry (login stays disabled; sudo is NOPASSWD anyway).
    printf 'labuser:!!:20000:0:99999:7:::\n' >> /etc/shadow 2>/dev/null || true
fi

exec "$@"
