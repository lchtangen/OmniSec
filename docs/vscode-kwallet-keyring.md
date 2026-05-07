<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# VS Code KWallet Keyring

Date: 2026-05-07

Host desktop: KDE Plasma Wayland.

## Current State

VS Code is configured to use KWallet:

```text
~/.config/code-flags.conf
```

contains:

```text
--password-store=kwallet5
```

KWallet is enabled:

```sh
qdbus6 org.kde.kwalletd6 /modules/kwalletd6 org.kde.KWallet.isEnabled
```

Expected output:

```text
true
```

The FreeDesktop Secret Service endpoint used by many apps is active:

```sh
qdbus6 org.freedesktop.secrets /org/freedesktop/secrets org.freedesktop.DBus.Peer.Ping
```

Expected result: command exits successfully with no output.

## Restart VS Code

Close all VS Code windows, then launch again from KDE or terminal:

```sh
code
```

Verify the running process includes:

```text
--password-store=kwallet5
```

with:

```sh
ps -ef | rg 'visual-studio-code|password-store'
```

## Remote SSH Target

Use:

```text
arch-arm64
```

Open folder:

```text
/home/archlinux/workspace
```

VS Code secrets are stored on the desktop KWallet. The remote Arch chroot only runs the server and project tools.

## If VS Code Still Complains

1. Confirm KWallet is unlocked in KDE.
2. Restart VS Code after unlocking KWallet.
3. Confirm the `--password-store=kwallet5` flag is present in the running process.
4. If the issue is only Remote SSH password prompts, prefer SSH keys instead of saved passwords.

