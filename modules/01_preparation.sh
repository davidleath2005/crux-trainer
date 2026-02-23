#!/usr/bin/env bash
# Module: 01 — Preparation
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_01_preparation() {
    show_chapter_header "Chapter 1" "Preparation" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 1.1 — verify root ──────────────────────────────────────────────
    show_step 1 "Verify we are running as root"
    show_tip "All installation commands require root privileges. The CRUX live CD boots you as root automatically."
    check_root
    log_success "Running as root."
    mark_step_complete "01.1"

    # ── Step 1.2 — check date/time ──────────────────────────────────────────
    show_step 2 "Verify system date and time"
    show_tip "An incorrect system clock causes SSL certificate errors when downloading files. Always check the date before continuing."

    run_or_type "date" \
        "Display the current system date and time. Verify it looks correct." \
        "https://crux.nu/Main/Handbook3-8"

    echo ""
    printf "  Does the date look correct? [Y/n]: "
    local date_ok
    read -r date_ok
    if [[ "${date_ok,,}" == "n" ]]; then
        run_or_type "ntpd -gq" \
            "Synchronise the system clock using NTP (Network Time Protocol). The -g flag allows large time corrections; -q quits after the first sync." \
            "https://crux.nu/Main/Handbook3-8"
    fi
    mark_step_complete "01.2"

    # ── Step 1.3 — overview ─────────────────────────────────────────────────
    show_step 3 "CRUX installation overview"
    show_tip "CRUX is a lightweight, source-based Linux distribution targeted at experienced users. Understanding the big picture helps you follow the details."
    cat <<'EOF'

  CRUX 3.8 Installation Overview
  ────────────────────────────────
  1. Configure the network
  2. Partition & format the target disk (install target: /mnt)
  3. Run the ISO's built-in 'setup' script to copy packages
  4. Mount pseudo-filesystems and chroot into /mnt
  5. Configure the ports tree (/usr/ports/) and prt-get
  6. Set timezone and locale
  7. Compile the Linux kernel manually (make menuconfig)
  8. Generate /etc/fstab
  9. Configure networking (hostname, /etc/rc.conf)
  10. Install additional system tools
  11. Install and configure a bootloader (LILO or GRUB)
  12. Create users
  13. Reboot into your new CRUX system!

  Key CRUX concepts:
  • Package manager: pkgmk / pkgadd / prt-get
  • Ports tree: /usr/ports/{core,opt,contrib,xorg}/
  • Init system: BSD-style rc with /etc/rc.conf
  • Services: enabled via SERVICES array in /etc/rc.conf
  • No systemd, no OpenRC

EOF
    pause_and_continue
    mark_step_complete "01.3"

    log_success "Module 01 — Preparation complete."
}
