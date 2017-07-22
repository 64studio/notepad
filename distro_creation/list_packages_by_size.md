# List installed packages by size.

This is useful when reducing the size of a distro.

```bash
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n
```
