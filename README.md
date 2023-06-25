# PapayaRX

## Developement

### Creating container image
At the time of writing there are two images available for developement purposes.
+ Ubuntu image
+ Arch image
The former (Ubuntu) benefits from quick setup, since all dependencies (mainly gnuradio) are installed from ubuntu offical repo. 
Good solution for "I need to setup and test this quickly". However, less control over exact library versions.

The latter (Arch) image fetches most libs sources and compiles it by itself (Gnuradio and its dependencies compilation is main point of interest). 
It can take a bit to complete compilation, but we benefit from knowing what's happening under the hood, and we can dig easier if something (especially related to GR) crashes.

**Steps (Invoke as non-root user unless stated otherwise!):**
1. Create _volume_ for exhibiting lib header files installed inside the container to the host-ran IDE.
`podman volume create <lib_vol_name>`
2. Mount volume
```
podman unshare
podman volume mount <lib_vol_name>
exit
```
3. Create symbolic link to the volume `ln -s $(podman volume inspect --format "{{.Mountpoint}}" <lib_vol_name>) $(git rev-parse --show-toplevel)/podman/devel/headers`
4. Enter `podman/devel/<flavour>/` directory and run:
`podman build --tag ubuntu_quick:latest --stdin ./`
5. Embrace in patience and guide ubuntu's dpkg installers whenever needed by hitting `y`, `[enter]` etc.

Once image has been built successfuly, you can move to launching container from its image.

### Launching container
**Steps (Invoke as non-root user unless stated otherwise!):**
1. Run
`podman run --rm -it --userns keep-id --mount type=volume,source=<lib_vol_name>,destination=/shared_libs ubuntu_quick:latest bash`
- replace `<git_proj_dir>` with the actual local git project directory, e.g. `~/git_repos/PapayaRX/`
- replace `<lib_vol_name>` with your _volume_ name (the one used for exporting header files)
- If the host user you're running the container has UID other than 1000 (issue `id` to check) use `--userns nomap` instead of `--userns keep-id`, or configure UID/GID mappings so `dev` container user _UID_/_GID_ matches your host non-root user.