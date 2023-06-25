# PapayaRX

## Developement

### Creating container image
At the time of writing there are two images available for developement purposes.
+ Ubuntu image
+ Arch image
The former (Ubuntu) benefits from quick setup, since all dependencies (mainly gnuradio) are installed from ubuntu offical repo. 
Good solution for "I need to setup and test this quickly". However, less control over exact library versions.

The latter (Arch) image fetches most lib sources and compiles it by itself (Gnuradio and its dependencies is main point of interest). 
It can take a bit to complete compilation, but we benefit from knowing what's happening under the hood, so we can dig easier if something (especially related to GR) crashes.

**Steps (invoke as non-root user unless stated otherwise!):**
1. Create _volume_ for exhibiting lib header files installed inside the container to the host-ran IDE.
`podman volume create <lib_vol_name>`
2. Mount volume
```
podman unshare
podman volume mount <lib_vol_name>
exit
```
3. Create symbolic link to the volume `ln -s $(podman volume inspect --format "{{.Mountpoint}}" <lib_vol_name>) $(git rev-parse --show-toplevel)/podman/devel/libs`
4. Enter `podman/devel/<flavour>/` directory and run:
`podman build --tag ubuntu_quick:latest --stdin ./`
5. Arm yourself with patience and guide ubuntu's debconfs whenever needed by hitting `y`, `[enter]` etc.

Once image has been built successfuly, you can move to launching container from its image.

### Launching container
**Steps (invoke as non-root user unless stated otherwise!):**
1. Run the following in the repository directory:
```
podman run --rm -it --userns keep-id \
 --mount type=volume,source=<lib_vol_name>,destination=/shared_libs \
 -v ./:/home/dev/PapayaRX ubuntu_quick:latest bash
```
- replace `<git_proj_dir>` with the actual local git project directory, e.g. `~/git_repos/PapayaRX/
- replace `<lib_vol_name>` with your _volume_ name (the one used for exporting header files)
- If the host user you're running the container has UID other than 1000, use `--userns nomap` instead of `--userns keep-id` or configure _UID_/_GID_ mappings so `dev` container user _UID_/_GID_ matches your host non-root user _UID_/_GID_.
2. On the first run, copy lib headers from the container's fs to `<lib_vol_name>`. In container issue:
```
cp -r --parents /usr/include/gnuradio/ /shared_libs/
cp -r --parents /usr/include/boost/ /shared_libs/
cp -r --parents /usr/include/SoapySDR/ /shared_libs/
cp -r --parents /usr/include/c++/ /shared_libs/
cp --parents /usr/include/* /shared_libs/ 2>/dev/null
```
_NOTE: This step is not mandatory, I use this to have references to header files from Eclipse ID running on host (outside container)._

### Building (Dev environment)
1. Go to project dir inside container: `cd ./PapayaRX`
2. Create `build` directory: `mkdir build`
3. Build Makefiles `cmake ..`
4. Build project `make -j8`
