# 🐧 CRUX Trainer

> **An interactive, educational Bash script that guides you through a real CRUX Linux installation — step by step, following the official CRUX 3.8 Handbook.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Shell: Bash 4+](https://img.shields.io/badge/Shell-Bash%204%2B-blue.svg)](https://www.gnu.org/software/bash/)
[![Handbook: CRUX 3.8](https://img.shields.io/badge/Handbook-CRUX%203.8-orange.svg)](https://crux.nu/Main/Handbook3-8)

---

## What Is This?

**CRUX Trainer** is a fully interactive Bash script that walks you through installing CRUX Linux on real hardware. It is primarily an **educational tool** — every command is explained before it runs, you can choose to type each command yourself to practice, and the script tracks your progress so you can resume an interrupted session.

Unlike a fully automated installer, CRUX Trainer is designed to help you *understand* what you are doing at each step. When you finish, you will have both a working CRUX system and a solid grasp of how it was built — including the CRUX ports system, prt-get, and manual kernel compilation.

---

## Feature Highlights

- 📖 **Handbook-faithful** — follows the official [CRUX 3.8 Handbook](https://crux.nu/Main/Handbook3-8) chapter by chapter
- 🎓 **Educational** — every command comes with a plain-English explanation and a Handbook reference
- ⌨️ **Type-it-yourself mode** — practice commands by typing them yourself; the script validates your input before running it
- 💾 **Progress tracking** — saves your progress to `/tmp/crux-trainer-progress` so you can safely resume an interrupted installation
- 🖥️ **Hardware-aware** — auto-detects UEFI vs BIOS, NVMe vs SATA, CPU details, RAM, and network interfaces
- ⚠️ **Safe** — all destructive operations (partitioning, formatting) require extra confirmation
- 🔧 **CRUX-specific** — covers the ISO `setup` script, ports tree, prt-get, BSD-style init, and manual kernel compilation

---

## Interface Preview

```
╔══════════════════════════════════════════════════════════════════╗
║    ██████╗██████╗ ██╗   ██╗██╗  ██╗    ██╗     ██╗███╗   ██╗  ║
║   ██╔════╝██╔══██╗██║   ██║╚██╗██╔╝    ██║     ██║████╗  ██║  ║
║   ██║     ██████╔╝██║   ██║ ╚███╔╝     ██║     ██║██╔██╗ ██║  ║
║   ██║     ██╔══██╗██║   ██║ ██╔██╗     ██║     ██║██║╚██╗██║  ║
║   ╚██████╗██║  ██║╚██████╔╝██╔╝ ██╗    ███████╗██║██║ ╚████║  ║
║    ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝    ╚══════╝╚═╝╚═╝  ╚═══╝  ║
║                  T R A I N E R  v1.0                           ║
╚══════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────┐
│  📋 COMMAND                                                     │
│  $ prt-get depinst vim                                          │
├─────────────────────────────────────────────────────────────────┤
│  💡 EXPLANATION                                                 │
│  Install the vim port with all its dependencies resolved        │
│  automatically. prt-get downloads, compiles, and installs it.   │
├─────────────────────────────────────────────────────────────────┤
│  📖 HANDBOOK REFERENCE                                          │
│  https://crux.nu/Main/Handbook3-8                               │
└─────────────────────────────────────────────────────────────────┘

  [A] Auto-run    [T] Type it yourself    [S] Skip    [E] Explain more
  Choice:
```

---

## Requirements

- Booted from the **CRUX 3.8 ISO** on your target machine
- Internet connection (wired preferred)
- A target disk with at least **10 GB** of free space (20 GB recommended)
- Basic familiarity with the Linux command line

---

## Quick Start

1. **Boot the CRUX 3.8 ISO** on your target machine.

2. **Download CRUX Trainer:**
   ```bash
   curl -O https://raw.githubusercontent.com/davidleath2005/crux-trainer/main/crux-trainer.sh
   chmod +x crux-trainer.sh
   ```

3. **Run the trainer:**
   ```bash
   bash crux-trainer.sh
   ```

   The script will detect your hardware, check the environment, and guide you through each step interactively.

---

## Resuming an Interrupted Installation

If your session is interrupted, simply re-run the script:

```bash
bash crux-trainer.sh
```

The trainer will detect the saved progress file at `/tmp/crux-trainer-progress` and offer to resume from where you left off.

---

## Modules / Chapters

| Module | Title | Description |
|--------|-------|-------------|
| 01 | Preparation | Environment checks, date/time, overview |
| 02 | Network Configuration | Interface setup, DHCP, clock sync |
| 03 | Disk Partitioning & Formatting | Partition, format, mount at `/mnt` |
| 04 | CRUX Setup Script | Guide through the ISO's `setup` tool |
| 05 | Chroot Setup | Mount pseudo-fs and enter the chroot |
| 06 | Ports & prt-get | Configure ports tree, prt-get.conf, sync |
| 07 | Timezone & Locale | Set `/etc/localtime` and locale vars |
| 08 | Kernel Configuration | `make menuconfig`, compile, install |
| 09 | fstab Generation | Create `/etc/fstab` with UUIDs |
| 10 | System Networking | Hostname, `/etc/hosts`, `rc.conf` services |
| 11 | System Tools | Logger, cron, filesystem tools |
| 12 | Bootloader | GRUB2 or LILO configuration |
| 13 | Users & Passwords | Root password, user creation |
| 14 | Post-Installation | System updates, packages, custom ports, hardening, troubleshooting |
| 15 | Finalize & Reboot | Summary, unmount, reboot |

---

## Key CRUX Concepts Covered

### Package Management
```bash
# Low-level tools
pkgadd package.pkg.tar.gz   # install a package
pkgrm  package               # remove a package
pkginfo -i                   # list installed packages

# High-level prt-get
prt-get depinst vim          # install with dependencies
prt-get sysup                # upgrade all packages
prt-get search term          # search ports
prt-get diff                 # show upgradeable packages
```

### Ports Tree Structure
```
/usr/ports/
  core/    — base system (always active)
  opt/     — optional packages
  contrib/ — community packages
  xorg/    — X Window System
```

### BSD-style Init
```bash
# Services configured in /etc/rc.conf
SERVICES=(syslog-ng crond net dhcpcd sshd)

# Start/stop manually
/etc/rc.d/sshd start
/etc/rc.d/sshd stop
```

### Manual Kernel Compilation
```bash
cd /usr/src/linux
make menuconfig      # configure kernel
make -j$(nproc)      # compile
make modules_install # install modules
make install         # copy to /boot
```

---

## Customization Options

During the guided installation you will be asked to choose:

- **Filesystem**: ext4, xfs, or btrfs (pros and cons explained)
- **Swap**: partition, swapfile, or none
- **Bootloader**: GRUB2 (recommended, UEFI + BIOS) or LILO (traditional)
- **Ports collections**: core, opt, contrib, xorg
- **System logger**: syslog-ng or sysklogd
- **Window manager**: i3, openbox, dwm, or fluxbox (post-install)
- **Browser**: links/lynx (fast) or firefox/chromium (long compile)
- **Audio**: ALSA, PulseAudio, or PipeWire

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-improvement`)
3. Write shellcheck-clean Bash
4. Submit a pull request with a clear description of your changes

Please keep the educational spirit of the project — commands should always be explained, not just run silently.

---

## License

This project is licensed under the [MIT License](LICENSE). Copyright © 2026 davidleath2005.

---

## Links

- 📘 [Official CRUX 3.8 Handbook](https://crux.nu/Main/Handbook3-8)
- 🌐 [CRUX Linux](https://crux.nu/)
- 💬 [CRUX Mailing List](https://crux.nu/Main/MailingLists)
- 🔎 [CRUX Ports](https://crux.nu/portdb/)

---

## FAQ

**Is this safe to run on real hardware?**
Yes — but it will partition and format the disk you choose. Always back up important data. The script warns you explicitly before any destructive operation and requires you to type `YES` to confirm.

**Can I use this in a virtual machine?**
Absolutely. A VM is an excellent way to practice without risking data.

**Does CRUX compile everything from source?**
Not quite. The `setup` script copies pre-built packages from the ISO using `pkgadd`. After that, additional packages are compiled from source using the ports system. The kernel is always compiled manually.

**How long does the kernel compilation take?**
With a simple configuration: 10-20 minutes on modern hardware, longer on older machines or with many drivers enabled.

**Why does prt-get take so long?**
prt-get compiles packages from source. Browser like Firefox can take hours. Use `MAKEFLAGS="-j$(nproc)"` in `/etc/pkgmk.conf` to use all CPU cores.

**Is this an official CRUX project?**
No. This is an independent educational tool. Always consult the [official CRUX Handbook](https://crux.nu/Main/Handbook3-8) as the authoritative source.

---

## Credits & Acknowledgments

- The [CRUX developers and community](https://crux.nu/) for the clean, minimalist distribution
- Architecture inspired by [gentoo-trainer](https://github.com/davidleath2005/gentoo-trainer)
- All contributors to this project
