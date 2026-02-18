# distrobox-ecl
My Distrobox arch's container for Common LISP / ECL with Wayland, Mesa and NVIDIA driver.

# Build and Run

```sh
podman build -t distrobox-ecl .
distrobox stop distrobox-ecl --yes ; distrobox rm distrobox-ecl --yes
distrobox create -n distrobox-ecl \
    --image distrobox-ecl \
    --home ~/Distroboxes/archlinux/home \
    --nvidia \
    --additional-flags "--env WAYLAND_DISPLAY=$WAYLAND_DISPLAY --env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/user/1000/wayland-0"
```
