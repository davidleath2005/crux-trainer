#!/usr/bin/env bash
# Module: 10 — System Networking Configuration
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_10_networking() {
    show_chapter_header "Chapter 10" "System Networking" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 10.1 — set hostname ────────────────────────────────────────────
    show_step 1 "Set the system hostname"
    show_tip "The hostname is the name your machine uses to identify itself on the network. In CRUX, the hostname is set in /etc/rc.conf via the HOSTNAME variable."

    echo ""
    printf "  Enter the desired hostname (e.g. cruxbox): "
    local hostname
    read -r hostname
    hostname="${hostname:-cruxbox}"
    save_progress "HOSTNAME" "$hostname"

    run_or_type "nano /etc/rc.conf" \
        "Open /etc/rc.conf to configure the hostname and other system settings. Set HOSTNAME=\"${hostname}\". This file is the central CRUX init configuration file." \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "/etc/rc.conf is the heart of CRUX's BSD-style init system. It controls hostname, timezone, services to start at boot (SERVICES array), and network configuration."

    mark_step_complete "10.1"

    # ── Step 10.2 — configure /etc/hosts ───────────────────────────────────
    show_step 2 "Configure /etc/hosts"
    show_tip "/etc/hosts maps hostnames to IP addresses locally, before DNS is consulted. At minimum, your own hostname should resolve to 127.0.0.1 (loopback)."

    echo ""
    echo -e "  ${BOLD}Typical /etc/hosts:${RESET}"
    cat <<EOF

  127.0.0.1   localhost
  127.0.1.1   ${hostname}
  ::1         localhost ip6-localhost ip6-loopback

EOF

    run_or_type "nano /etc/hosts" \
        "Open /etc/hosts and add entries for your hostname. Replace 'cruxbox' with '${hostname}' if needed." \
        "https://crux.nu/Main/Handbook3-8"

    mark_step_complete "10.2"

    # ── Step 10.3 — configure services in rc.conf ────────────────────────────
    show_step 3 "Enable network services"
    show_tip "CRUX uses a BSD-style init. Services are enabled by adding them to the SERVICES array in /etc/rc.conf. Service scripts live in /etc/rc.d/. There is no systemctl or rc-update — just edit the array."

    cat <<'EOF'

  CRUX service management:
  ─────────────────────────
  Edit /etc/rc.conf and set the SERVICES array:

    SERVICES=(syslog crond net dhcpcd)

  Available service scripts in /etc/rc.d/:
    net       — configure network interfaces (uses /etc/rc.d/net)
    dhcpcd    — DHCP client
    sshd      — OpenSSH server
    syslog    — system logger (syslog-ng or similar)
    crond     — cron daemon

  To start/stop services manually:
    /etc/rc.d/<service> start
    /etc/rc.d/<service> stop
    /etc/rc.d/<service> restart

  Note: There is no 'enable at boot' command. You add the service
  name to the SERVICES array in /etc/rc.conf directly.

EOF

    run_or_type "ls /etc/rc.d/" \
        "List available service scripts. These are the services you can add to the SERVICES array in /etc/rc.conf." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "nano /etc/rc.d/net" \
        "Open the net service script to configure your network interface. Set your interface name and configure static IP or DHCP as needed."

    pause_and_continue
    mark_step_complete "10.3"

    log_success "Module 10 — System networking complete."
}
