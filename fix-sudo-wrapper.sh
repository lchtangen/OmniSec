#!/system/bin/sh
# Fix: replace /usr/bin/sudo with a non-hanging wrapper
KALI=/data/local/nhsystem/kalifs
ORIG_SUDO=$KALI/usr/bin/sudo.orig
WRAPPER=$KALI/usr/bin/sudo

# Back up original sudo if not already backed up
if [ ! -f "$ORIG_SUDO" ]; then
    cp "$WRAPPER" "$ORIG_SUDO"
    echo "Backed up original sudo to sudo.orig"
fi

# Create a wrapper that bypasses FQDN/PAM hang
cat > /data/local/tmp/sudo.wrapper << 'SUDOWRAP'
#!/bin/sh
# Wrapper for sudo that avoids FQDN/PAM hangups in Android chroot
# When called as "sudo -E PATH=... su -l" or "sudo su"
# we optimize for the NetHunter use case

# If just checking version, use real sudo
case "$*" in
    -V|--version)
        exec /usr/bin/sudo.orig -V
        ;;
esac

# Extract command to run
CMD=""
SKIP=0
for arg in "$@"; do
    if [ $SKIP -eq 1 ]; then
        # skip the arg after -E or -e
        SKIP=0
        continue
    fi
    case "$arg" in
        -E|-e|-H|-P|-S|-n|-v|-k|-K|-r|-T|-g|-p|-t|-U|-u)
            SKIP=1
            ;;
        -l|-h|--help)
            exec /usr/bin/sudo.orig "$@"
            ;;
        su)
            # sudo su -> become root directly
            exec /bin/su -l root
            ;;
        -l|-i|--login)
            # sudo -i or --login
            shift $((OPTIND))
            exec /bin/su -l root "$@"
            ;;
        *)
            # Anything else: try running as root via /bin/su
            if [ -z "$CMD" ]; then
                CMD="$arg"
            else
                CMD="$CMD $arg"
            fi
            ;;
    esac
done

if [ -n "$CMD" ]; then
    exec /bin/su -l root -c "$CMD"
else
    # Default: just give a root shell
    exec /bin/su -l root
fi
SUDOWRAP

cp /data/local/tmp/sudo.wrapper "$WRAPPER"
chmod 755 "$WRAPPER"
echo "sudo wrapper installed"

# Test
echo "=== Testing sudo wrapper ==="
timeout 8 /system/bin/busybox_nh chroot "$KALI" /usr/bin/sudo whoami 2>&1
RC=$?
echo "exit: $RC"

if [ $RC -eq 0 ]; then
    echo "SUDO WRAPPER: PASS"
else
    echo "SUDO WRAPPER: FAIL - restoring original"
    cp "$ORIG_SUDO" "$WRAPPER"
fi

echo "=== Additional test: sudo su ==="
timeout 8 /system/bin/busybox_nh chroot "$KALI" /usr/bin/sudo su -c whoami 2>&1
echo "exit: $?"

echo "=== done ==="
