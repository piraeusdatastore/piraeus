#!/bin/sh
# run all lvm commands in host namespace

if [ "$MAP_HOST_LVM" = 'true' ]; then
    cmdpath=$(command -v lvm)
    mv "$cmdpath" "${cmdpath}.distro"
    cat <<'EOF' > "$cmdpath"
#!/bin/sh
nsenter --target 1 --mount --uts --ipc --net --pid -- "$(basename $0)" "$@"
EOF
    chmod +x "$cmdpath"
fi