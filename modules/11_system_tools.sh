#!/usr/bin/env bash
# Module: 11 — System Tools
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_11_system_tools() {
    show_chapter_header "Chapter 11" "System Tools Installation" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 11.1 — system logger ────────────────────────────────────────────
    show_step 1 "Install a system logger"
    show_tip "The system logger collects messages from the kernel and running services, writing them to log files in /var/log. Without a logger, important messages are lost after reboot."

    show_menu "Choose a system logger" \
        "syslog-ng — modern, powerful logger (recommended)" \
        "sysklogd  — classic, minimal logger"
    local logger_choice="$MENU_CHOICE"

    case "$logger_choice" in
        1)
            run_or_type "prt-get depinst syslog-ng" \
                "Install syslog-ng, a modern and highly configurable system logger." \
                "https://crux.nu/Main/Handbook3-8"
            run_or_type "nano /etc/rc.conf" \
                "Add 'syslog-ng' to the SERVICES array in /etc/rc.conf to enable it at boot."
            ;;
        2)
            run_or_type "prt-get depinst sysklogd" \
                "Install sysklogd, the traditional Unix system logger." \
                "https://crux.nu/Main/Handbook3-8"
            run_or_type "nano /etc/rc.conf" \
                "Add 'syslog' to the SERVICES array in /etc/rc.conf to enable it at boot."
            ;;
    esac
    mark_step_complete "11.1"

    # ── Step 11.2 — cron daemon ──────────────────────────────────────────────
    show_step 2 "Install a cron daemon (optional)"
    show_tip "Cron runs scheduled tasks at specified times. Useful for automated maintenance like log rotation and package updates. On minimal systems, you can skip it."

    printf "  Install a cron daemon? [Y/n]: "
    local install_cron
    read -r install_cron
    if [[ "${install_cron,,}" != "n" ]]; then
        run_or_type "prt-get depinst dcron" \
            "Install dcron, a compact and reliable cron daemon compatible with standard cron syntax." \
            "https://crux.nu/Main/Handbook3-8"
        run_or_type "nano /etc/rc.conf" \
            "Add 'crond' to the SERVICES array in /etc/rc.conf to enable dcron at boot."
    fi
    mark_step_complete "11.2"

    # ── Step 11.3 — filesystem tools ─────────────────────────────────────────
    show_step 3 "Install filesystem tools"
    show_tip "Filesystem utility packages provide tools like e2fsck for checking and repairing filesystems. Install the tools that match the filesystem you chose in Module 03."

    local chosen_fs
    chosen_fs=$(load_progress "CHOSEN_FS")
    chosen_fs="${chosen_fs:-ext4}"

    case "$chosen_fs" in
        ext4)
            run_or_type "prt-get depinst e2fsprogs" \
                "Install e2fsprogs: tools for ext2/ext3/ext4 filesystems including e2fsck, resize2fs, and tune2fs." \
                "https://crux.nu/Main/Handbook3-8"
            ;;
        xfs)
            run_or_type "prt-get depinst xfsprogs" \
                "Install xfsprogs: tools for XFS filesystems including xfs_repair and xfs_growfs."
            ;;
        btrfs)
            run_or_type "prt-get depinst btrfs-progs" \
                "Install btrfs-progs: tools for Btrfs filesystems including btrfs check and btrfs balance."
            ;;
    esac

    run_or_type "prt-get depinst dosfstools" \
        "Install dosfstools (mkfs.fat, fsck.fat) for FAT filesystem management. Required if you have a FAT32 EFI partition."

    mark_step_complete "11.3"

    log_success "Module 11 — System tools installation complete."
}
