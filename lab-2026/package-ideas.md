# Package ideas

Pick a package that matches your language and interest. Find more with:

```sh
dnf search all <pattern>      # search Fedora packages by name/summary/description
```

## C / C++

Two kinds of work: look at a flex-array problem, or harden a project.

**Packages**:

- `bzip2` pre-baked in the lab, easiest start
- `libxml2` pre-baked in the lab
- `expat` canonical parser (`block.s[1]`); note: upstream already migrated to `[]`
- `jansson` cleanest one-liner (`hashtable_pair.key[1]`)
- `json-c` `idata[1]` (nested memcpy)
- `sqlite` `DbClientData.zName[1]` ("MUST BE LAST")
- `libssh2` `sftp_packet.packet[1]`
- `libpng` `png_compression_buffer.output[1]`
- `lcms2` `cmsICCData.data[1]` (ICC parser of untrusted input)
- `e2fsprogs` 4× `[0]` flexible members

**Media/codec targets** (need network to clone; build deps baked into the lab):

- `assimp`, `libheif`, `libde265`, `imagemagick6`, `freerdp`
  - build `libheif` with `-DWITH_AOM_DECODER=OFF -DWITH_AOM_ENCODER=OFF`

**Candidates for `-Wall -Wextra -Werror`:**

- `libcbor`, `libyaml`, `libeconf`

## Python

Run `pylint` on it, fix what it flags:

- `impacket`, `certifi`, `lxml`,
  `python3-attrs`
- `requests`, `jinja2`,
  `pymongo`, `flask`, `paramiko`
- `six` (single file)
