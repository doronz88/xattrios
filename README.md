Simple utility for querying the extended attributes of the given list of files.

# Installation

- Upload the `.deb` file found in the packages directory into the device.
- `apt install <deb file>`

# Usage

For using simply execute:

```shell
# for single file
xattrios /path/to/filename

# or you could specify multiple files like so
xattrios $(find /some/path)
```