#!/usr/bin/env bash
# Module: 14 — Post-Installation
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_14_post_install() {
    show_chapter_header "Chapter 14" "Post-Installation" \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "Post-installation is where most CRUX users spend the most time. CRUX gives you a minimal base — you add exactly what you need. This module guides you through the most important steps."

    show_menu "Post-installation sub-modules" \
        "14.1 — Update ports tree and system" \
        "14.2 — Install essential packages" \
        "14.3 — Create custom ports" \
        "14.4 — System hardening" \
        "14.5 — Troubleshooting guide" \
        "Run all sub-modules in sequence"

    local sub_choice="$MENU_CHOICE"

    case "$sub_choice" in
        1) _module_14_1_update ;;
        2) _module_14_2_essential_packages ;;
        3) _module_14_3_custom_ports ;;
        4) _module_14_4_hardening ;;
        5) _module_14_5_troubleshooting ;;
        6)
            _module_14_1_update
            _module_14_2_essential_packages
            _module_14_3_custom_ports
            _module_14_4_hardening
            _module_14_5_troubleshooting
            ;;
    esac

    log_success "Module 14 — Post-installation complete."
}

# ────────────────────────────────────────────────────────────────────────────
# 14.1 — Update ports tree and system
# ────────────────────────────────────────────────────────────────────────────
_module_14_1_update() {
    show_chapter_header "14.1" "Update Ports Tree and System" \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "The first thing to do after booting your new CRUX system is update the ports tree and upgrade any outdated packages. New CRUX ISOs are released periodically; some packages on the ISO may already have newer versions available."

    # Sync ports tree
    run_or_type "ports -u" \
        "Synchronise all active ports collections from the CRUX servers. This downloads updated Pkgfiles but does not compile anything yet." \
        "https://crux.nu/Main/Handbook3-8"

    # Show what can be upgraded
    run_or_type "prt-get diff" \
        "Compare installed package versions against the ports tree. Shows a list of packages that have newer versions available." \
        "https://crux.nu/Main/Handbook3-8"

    # Upgrade the system
    show_tip "'prt-get sysup' upgrades all outdated packages. For a fresh install this may take a while if many packages on the ISO are out of date."

    run_or_type "prt-get sysup" \
        "Upgrade all installed packages that have newer versions available in the ports tree. Equivalent to 'emerge -uDN @world' on Gentoo." \
        "https://crux.nu/Main/Handbook3-8"

    # Run rejmerge for configuration file conflicts
    run_or_type "rejmerge" \
        "Review and merge configuration file changes that were blocked by existing files during the upgrade. rejmerge shows diffs and lets you accept or reject each change." \
        "https://crux.nu/Main/Handbook3-8"

    mark_step_complete "14.1"
}

# ────────────────────────────────────────────────────────────────────────────
# 14.2 — Essential post-install packages
# ────────────────────────────────────────────────────────────────────────────
_module_14_2_essential_packages() {
    show_chapter_header "14.2" "Essential Post-Install Packages" \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "CRUX's base system is intentionally minimal. Here we install the most commonly needed packages for a usable desktop or server. Each category is optional — install what you need."

    # ── Xorg ──────────────────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Xorg (X Window System) ─────────────────────────────────${RESET}"
    show_tip "Xorg provides the X Window System, which is required for graphical applications and most desktop environments. It is a large install — xorg-server plus drivers. Make sure 'xorg' is enabled in prt-get.conf first."

    printf "  Install Xorg? [Y/n]: "
    local install_xorg
    read -r install_xorg
    if [[ "${install_xorg,,}" != "n" ]]; then
        run_or_type "prt-get depinst xorg-server" \
            "Install the Xorg X11 server with all its dependencies. This is the foundation for any graphical environment." \
            "https://crux.nu/Main/Handbook3-8"

        run_or_type "prt-get depinst xorg-xrandr xorg-xinit xorg-xauth" \
            "Install Xorg utilities: xrandr (display management), xinit (start X sessions), xauth (X authentication)."
    fi

    # ── Window Managers ───────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Window Managers ─────────────────────────────────────────${RESET}"
    echo ""
    cat <<'EOF'
  Window manager options:
  ─────────────────────────
  i3      — tiling WM, keyboard-driven, highly configurable
            Install: prt-get depinst i3

  openbox — floating WM, lightweight, good for beginners
            Install: prt-get depinst openbox

  dwm     — suckless tiling WM, configured by editing source code
            Install: prt-get depinst dwm

  fluxbox — fast, lightweight, traditional floating WM
            Install: prt-get depinst fluxbox

EOF
    printf "  Install a window manager? [Y/n]: "
    local install_wm
    read -r install_wm
    if [[ "${install_wm,,}" != "n" ]]; then
        show_menu "Choose a window manager" \
            "i3      — tiling, keyboard-driven" \
            "openbox — floating, lightweight" \
            "dwm     — suckless tiling" \
            "fluxbox — fast, traditional floating" \
            "Skip (configure manually later)"
        case "$MENU_CHOICE" in
            1)
                run_or_type "prt-get depinst i3" \
                    "Install the i3 tiling window manager and its utilities (i3bar, i3status)."
                ;;
            2)
                run_or_type "prt-get depinst openbox" \
                    "Install the Openbox floating window manager. Lightweight and highly configurable."
                ;;
            3)
                run_or_type "prt-get depinst dwm" \
                    "Install dwm from suckless.org. It is configured by editing config.h and recompiling."
                ;;
            4)
                run_or_type "prt-get depinst fluxbox" \
                    "Install Fluxbox, a fast and lightweight window manager."
                ;;
            5)
                log_info "Skipping window manager installation."
                ;;
        esac
    fi

    # ── Terminal Emulators ────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Terminal Emulators ──────────────────────────────────────${RESET}"
    printf "  Install a terminal emulator? [Y/n]: "
    local install_term
    read -r install_term
    if [[ "${install_term,,}" != "n" ]]; then
        show_menu "Choose a terminal emulator" \
            "xterm     — minimal, always available" \
            "st        — suckless simple terminal" \
            "alacritty — GPU-accelerated, modern" \
            "rxvt-unicode (urxvt) — lightweight, scriptable"
        case "$MENU_CHOICE" in
            1)
                run_or_type "prt-get depinst xterm" \
                    "Install xterm, the classic X11 terminal emulator. Minimal but always reliable."
                ;;
            2)
                run_or_type "prt-get depinst st" \
                    "Install st (simple terminal) from suckless.org. Configured by editing source and recompiling."
                ;;
            3)
                run_or_type "prt-get depinst alacritty" \
                    "Install Alacritty, a GPU-accelerated terminal emulator. Requires a GPU and OpenGL support."
                ;;
            4)
                run_or_type "prt-get depinst rxvt-unicode" \
                    "Install rxvt-unicode (urxvt), a lightweight and highly scriptable terminal emulator."
                ;;
        esac
    fi

    # ── Web Browsers ──────────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Web Browsers ────────────────────────────────────────────${RESET}"
    show_tip "Building Firefox or Chromium from source takes a very long time (1-4 hours on modern hardware, much longer on older hardware). Text browsers like lynx or links are fast to compile."

    printf "  Install a web browser? [Y/n]: "
    local install_browser
    read -r install_browser
    if [[ "${install_browser,,}" != "n" ]]; then
        show_menu "Choose a browser (compile times approximate)" \
            "firefox   — full-featured (⚠ 2-4 hours to compile)" \
            "chromium  — Google Chrome open-source base (⚠ 3-5 hours)" \
            "links     — text browser, very fast" \
            "lynx      — classic text browser"
        case "$MENU_CHOICE" in
            1)
                log_warn "Firefox will take a very long time to compile! Ensure you have at least 4 GB RAM and plenty of disk space (8+ GB)."
                run_or_type "prt-get depinst firefox" \
                    "Install Mozilla Firefox. This compiles from source and takes 2-4 hours on modern hardware. Plan accordingly."
                ;;
            2)
                log_warn "Chromium requires significant resources to compile. Ensure 8+ GB RAM and 10+ GB free disk space."
                run_or_type "prt-get depinst chromium" \
                    "Install Chromium, the open-source base for Google Chrome. Very long compile time."
                ;;
            3)
                run_or_type "prt-get depinst links" \
                    "Install Links, a text-mode web browser. Fast to compile and useful on headless systems."
                ;;
            4)
                run_or_type "prt-get depinst lynx" \
                    "Install Lynx, the classic text-mode web browser."
                ;;
        esac
    fi

    # ── Text Editors ──────────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Text Editors ────────────────────────────────────────────${RESET}"
    printf "  Install additional text editors? [Y/n]: "
    local install_editor
    read -r install_editor
    if [[ "${install_editor,,}" != "n" ]]; then
        show_menu "Choose a text editor" \
            "vim   — improved vi, highly capable" \
            "nano  — beginner-friendly terminal editor" \
            "emacs — extensible editor (large compile)"
        case "$MENU_CHOICE" in
            1)
                run_or_type "prt-get depinst vim" \
                    "Install Vim, the improved version of vi. Highly configurable and available in nearly every CRUX ports tree."
                ;;
            2)
                run_or_type "prt-get depinst nano" \
                    "Install GNU nano, a simple and friendly terminal text editor."
                ;;
            3)
                run_or_type "prt-get depinst emacs" \
                    "Install GNU Emacs, the extensible, customizable, free text editor (and much more)."
                ;;
        esac
    fi

    # ── Audio ─────────────────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Audio ───────────────────────────────────────────────────${RESET}"
    printf "  Install audio support? [Y/n]: "
    local install_audio
    read -r install_audio
    if [[ "${install_audio,,}" != "n" ]]; then
        run_or_type "prt-get depinst alsa-utils" \
            "Install ALSA utilities (amixer, alsamixer, aplay) for basic audio control. ALSA is built into the Linux kernel and works without a sound server." \
            "https://crux.nu/Main/Handbook3-8"

        show_menu "Install an optional sound server?" \
            "No sound server — ALSA only is fine for many setups" \
            "PulseAudio — compatibility layer, desktop-friendly" \
            "PipeWire   — modern replacement for PulseAudio"
        case "$MENU_CHOICE" in
            1) log_info "Using ALSA directly — no sound server." ;;
            2)
                run_or_type "prt-get depinst pulseaudio" \
                    "Install PulseAudio, a sound server that provides per-application volume control and Bluetooth audio support."
                ;;
            3)
                run_or_type "prt-get depinst pipewire pipewire-pulse" \
                    "Install PipeWire, a modern multimedia framework that replaces both PulseAudio and JACK."
                ;;
        esac
    fi

    # ── Fonts ─────────────────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Fonts ───────────────────────────────────────────────────${RESET}"
    printf "  Install fonts for graphical applications? [Y/n]: "
    local install_fonts
    read -r install_fonts
    if [[ "${install_fonts,,}" != "n" ]]; then
        run_or_type "prt-get depinst xorg-font-dejavu-ttf" \
            "Install the DejaVu TrueType fonts. These are high-quality, widely-used fonts that cover a large Unicode range." \
            "https://crux.nu/Main/Handbook3-8"

        run_or_type "prt-get depinst liberation-fonts" \
            "Install Liberation fonts — metric-compatible replacements for common Microsoft fonts."
    fi

    mark_step_complete "14.2"
}

# ────────────────────────────────────────────────────────────────────────────
# 14.3 — Creating custom ports
# ────────────────────────────────────────────────────────────────────────────
_module_14_3_custom_ports() {
    show_chapter_header "14.3" "Creating Custom Ports" \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "One of CRUX's great features is how easy it is to create custom ports. A port is just a directory with a Pkgfile. You can maintain a private ports collection for software not in the official trees."

    cat <<'EOF'

  Creating a port from scratch:
  ──────────────────────────────
  1. Create a directory:
       mkdir -p /usr/ports/mylocal/mypackage

  2. Create a Pkgfile:

     # Description: My custom package
     # URL:          https://example.com/mypackage
     # Maintainer:   Your Name, your@email.com
     # Depends on:   somelib

     name=mypackage
     version=1.0.0
     release=1

     source=(https://example.com/$name-$version.tar.gz)

     build() {
       cd $name-$version
       ./configure --prefix=/usr
       make
       make DESTDIR=$PKG install
     }

  3. Add your collection to prt-get.conf:
       prtdir /usr/ports/mylocal

  4. Build and install:
       cd /usr/ports/mylocal/mypackage
       pkgmk -d      # download source and build
       pkgadd mypackage#1.0.0-1.pkg.tar.gz

  Key pkgmk options:
  ─────────────────────
  pkgmk          — build package (sources must be present)
  pkgmk -d       — download sources then build
  pkgmk -f       — ignore footprint mismatch
  pkgmk -u       — update .footprint file
  pkgmk -uf      — update footprint and force install
  pkgmk -c       — clean up built package files
  pkgmk -kw      — keep working directory after build (for debugging)

EOF

    run_or_type "nano /etc/pkgmk.conf" \
        "Open /etc/pkgmk.conf to configure the package builder. Key settings:
  CFLAGS='-march=native -O2 -pipe'   — compiler flags for your CPU
  MAKEFLAGS='-j$(nproc)'             — parallel make jobs
  PKGMK_SOURCE_DIR='/var/cache/pkgmk/sources'  — where to cache downloaded sources
  PKGMK_PACKAGE_DIR='/var/cache/pkgmk/packages' — where to store built packages" \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "Setting CFLAGS to '-march=native' optimizes packages for your specific CPU. The -O2 flag provides a good balance of speed and compile time. -pipe avoids temporary files, speeding up builds."

    cat <<'EOF'

  Recommended /etc/pkgmk.conf:
  ──────────────────────────────
  export CFLAGS="-march=native -O2 -pipe"
  export CXXFLAGS="$CFLAGS"
  export MAKEFLAGS="-j$(nproc)"
  PKGMK_SOURCE_DIR="/var/cache/pkgmk/sources"
  PKGMK_PACKAGE_DIR="/var/cache/pkgmk/packages"
  PKGMK_WORK_DIR="$PWD/work"
  PKGMK_COMPRESSION_MODE="gz"

EOF

    pause_and_continue
    mark_step_complete "14.3"
}

# ────────────────────────────────────────────────────────────────────────────
# 14.4 — System hardening
# ────────────────────────────────────────────────────────────────────────────
_module_14_4_hardening() {
    show_chapter_header "14.4" "System Hardening" \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "CRUX's minimal default install means there are fewer attack vectors. These steps help further secure your system."

    # ── Firewall ──────────────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Firewall ────────────────────────────────────────────────${RESET}"
    show_tip "CRUX does not install a firewall by default. For any internet-facing system, install iptables or nftables and configure a basic ruleset."

    printf "  Install a firewall? [Y/n]: "
    local install_fw
    read -r install_fw
    if [[ "${install_fw,,}" != "n" ]]; then
        show_menu "Choose a firewall tool" \
            "iptables — classic, widely documented" \
            "nftables — modern replacement for iptables"
        case "$MENU_CHOICE" in
            1)
                run_or_type "prt-get depinst iptables" \
                    "Install iptables for firewall rule management." \
                    "https://crux.nu/Main/Handbook3-8"
                echo ""
                echo -e "  ${BOLD}Basic iptables rules (drop inbound, allow established):${RESET}"
                cat <<'EOF'
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT ACCEPT
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # SSH
  iptables-save > /etc/iptables/iptables.rules
EOF
                echo ""
                ;;
            2)
                run_or_type "prt-get depinst nftables" \
                    "Install nftables, the modern Linux firewall framework."
                ;;
        esac
    fi

    # ── SSH hardening ─────────────────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── SSH Hardening ───────────────────────────────────────────${RESET}"
    printf "  Configure SSH hardening? [Y/n]: "
    local harden_ssh
    read -r harden_ssh
    if [[ "${harden_ssh,,}" != "n" ]]; then
        run_or_type "prt-get depinst openssh" \
            "Install OpenSSH server and client."

        echo ""
        echo -e "  ${BOLD}Recommended /etc/ssh/sshd_config settings:${RESET}"
        cat <<'EOF'
  PermitRootLogin no           # disable direct root SSH login
  PasswordAuthentication no    # use key-based auth only (after adding your key)
  PubkeyAuthentication yes
  MaxAuthTries 3
  LoginGraceTime 30
  AllowUsers yourusername      # restrict login to specific users
EOF
        echo ""

        run_or_type "nano /etc/ssh/sshd_config" \
            "Edit the SSH daemon configuration. Apply the hardening settings shown above. If you are not using key-based auth yet, keep PasswordAuthentication yes until you have added your SSH key."

        show_tip "Generate an SSH key pair on your workstation with 'ssh-keygen -t ed25519', then copy it to the server with 'ssh-copy-id user@server' before disabling password authentication."
    fi

    # ── Regular update workflow ───────────────────────────────────────────
    echo ""
    echo -e "  ${BOLD}${CYAN}─── Regular Update Workflow ─────────────────────────────────${RESET}"
    echo ""
    cat <<'EOF'
  Recommended weekly update routine for CRUX:
  ─────────────────────────────────────────────
  1. ports -u               — sync the ports tree
  2. prt-get diff           — review what will be upgraded
  3. prt-get sysup          — upgrade all outdated packages
  4. rejmerge               — handle any config file conflicts
  5. prt-get depinst <new>  — install any new packages you want

  If you compiled a new kernel:
  6. lilo   (if using LILO)  — re-write the bootloader
     OR grub-mkconfig -o /boot/grub/grub.cfg  (if using GRUB)

EOF
    pause_and_continue
    mark_step_complete "14.4"
}

# ────────────────────────────────────────────────────────────────────────────
# 14.5 — Troubleshooting
# ────────────────────────────────────────────────────────────────────────────
_module_14_5_troubleshooting() {
    show_chapter_header "14.5" "Troubleshooting" \
        "https://crux.nu/Main/Handbook3-8"

    cat <<'EOF'

  Common CRUX issues and solutions:
  ────────────────────────────────────

  BUILD FAILURES
  ──────────────
  Problem: pkgmk fails with "Footprint mismatch"
  Solution: Run 'pkgmk -uf' to update the footprint and force install.
            NEW entries = extra files built (usually harmless).
            MISSING entries = expected files not built (check build log).

  Problem: Build fails with missing dependency
  Solution: Check 'Depends on:' in the Pkgfile. Install missing deps:
            prt-get depinst <dep>

  Problem: Source download fails (404 / connection error)
  Solution: The upstream URL may have changed. Check the port maintainer's
            page or search for the new URL. Edit the Pkgfile source= line.

  Problem: "ERROR: Building '/usr/ports/.../foo.pkg.tar.gz' failed"
  Solution: Check /var/log/pkgbuild.log or re-run with:
            pkgmk -d 2>&1 | tee /tmp/build.log

  KERNEL PANICS / BOOT ISSUES
  ────────────────────────────
  Problem: Kernel panic "VFS: Unable to mount root fs on unknown block"
  Solution: Your kernel is missing the driver for your disk controller
            or filesystem. Recompile with the correct modules.
            CONFIG_SATA_AHCI, CONFIG_EXT4_FS, etc.

  Problem: System boots but hangs at "Loading initial ramdisk"
  Solution: CRUX does not use an initramfs by default. Compile all
            required drivers (disk, fs) directly into the kernel [*],
            not as modules [M].

  Problem: LILO error "LI" on boot
  Solution: Run 'lilo' again from inside the chroot after verifying
            /etc/lilo.conf is correct.

  NETWORK ISSUES
  ──────────────
  Problem: Network interface not coming up at boot
  Solution: Check /etc/rc.d/net — verify the interface name and
            ensure 'net' is in the SERVICES array in /etc/rc.conf.

  Problem: "command not found: dhcpcd"
  Solution: Install dhcpcd: prt-get depinst dhcpcd

  XORG ISSUES
  ────────────
  Problem: "Fatal server error: no screens found"
  Solution: Install the correct video driver for your GPU:
            AMD/ATI:  prt-get depinst xf86-video-ati
            NVIDIA:   prt-get depinst xf86-video-nouveau (or nvidia)
            Intel:    prt-get depinst xf86-video-intel
            VirtualBox: prt-get depinst xf86-video-vmware

  Problem: Keyboard/mouse not working in X
  Solution: Install input drivers:
            prt-get depinst xf86-input-evdev xf86-input-libinput

  FOOTPRINT MISMATCHES
  ─────────────────────
  Problem: pkgmk reports NEW files in footprint
  Explanation: Your build produced extra files (often optional features
               were compiled in because a library was detected).
  Solution: pkgmk -uf   — update footprint and force install.
            This is safe for NEW entries. MISSING entries need investigation.

  USEFUL DIAGNOSTIC COMMANDS
  ────────────────────────────
  dmesg | tail -50          — recent kernel messages
  cat /var/log/messages     — system log (if syslog installed)
  pkginfo -i                — list all installed packages
  pkginfo -f <file>         — which package installed this file
  lspci                     — list PCI devices (useful for driver selection)
  lsusb                     — list USB devices
  lsmod                     — list loaded kernel modules
  modprobe <module>         — load a kernel module manually

EOF
    pause_and_continue
    mark_step_complete "14.5"
}
