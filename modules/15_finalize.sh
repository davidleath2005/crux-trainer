#!/usr/bin/env bash
# Module: 15 — Finalize and Reboot
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_15_finalize() {
    show_chapter_header "Chapter 15" "Finalize and Reboot" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 15.1 — show installation summary ────────────────────────────────
    show_step 1 "Installation summary"

    local hostname username chosen_fs target_disk timezone bl_choice
    hostname=$(load_progress "HOSTNAME")
    username=$(load_progress "USERNAME")
    chosen_fs=$(load_progress "CHOSEN_FS")
    target_disk=$(load_progress "TARGET_DISK")
    timezone=$(load_progress "TIMEZONE")
    bl_choice=$(load_progress "BOOTLOADER")

    local bootloader_label
    case "$bl_choice" in
        1) bootloader_label="GRUB2" ;;
        2) bootloader_label="LILO"  ;;
        *) bootloader_label="Unknown" ;;
    esac

    echo ""
    echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${GREEN}║  🎉  CRUX Installation Summary                          ║${RESET}"
    echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${BOLD}${GREEN}║${RESET}  Hostname    : ${hostname:-not set}"
    echo -e "${BOLD}${GREEN}║${RESET}  User        : ${username:-not set}"
    echo -e "${BOLD}${GREEN}║${RESET}  Filesystem  : ${chosen_fs:-ext4}"
    echo -e "${BOLD}${GREEN}║${RESET}  Bootloader  : ${bootloader_label}"
    echo -e "${BOLD}${GREEN}║${RESET}  Boot mode   : ${HW_BOOT_MODE:-unknown}"
    echo -e "${BOLD}${GREEN}║${RESET}  Target disk : ${target_disk:-unknown}"
    echo -e "${BOLD}${GREEN}║${RESET}  Timezone    : ${timezone:-UTC}"
    echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    mark_step_complete "15.1"

    # ── Step 15.2 — exit chroot, unmount, and reboot ─────────────────────────
    show_step 2 "Exit chroot, unmount filesystems, and reboot"
    show_tip "Before rebooting, exit the chroot and unmount all filesystems cleanly. This ensures filesystem journals are flushed and no data is lost."

    run_or_type "exit" \
        "Exit the chroot environment and return to the live CD shell." \
        "https://crux.nu/Main/Handbook3-8"

    echo ""
    echo -e "  ${YELLOW}Run the following commands from the live CD shell (outside chroot):${RESET}"
    echo ""
    echo -e "  ${GREEN}\$ umount -R /mnt${RESET}"
    echo -e "  ${GREEN}\$ reboot${RESET}"
    echo ""

    run_or_type "umount -R /mnt" \
        "Recursively unmount all filesystems mounted under /mnt. This includes /mnt/proc, /mnt/sys, /mnt/dev, and any EFI partition."

    echo ""
    echo -e "${BOLD}${CYAN}  ╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}  ║  🎉  Congratulations! CRUX installation complete!   ║${RESET}"
    echo -e "${BOLD}${CYAN}  ╠══════════════════════════════════════════════════════╣${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  First-boot checklist:                                ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  ✔ Log in as root (or your new user)                  ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  ✔ Verify network: ping crux.nu                       ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  ✔ Sync ports: ports -u                               ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  ✔ Upgrade system: prt-get sysup                      ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  ✔ Review /var/log/messages for issues                ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ╠══════════════════════════════════════════════════════╣${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  CRUX-specific post-reboot tips:                      ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  • Enable services in /etc/rc.conf SERVICES array     ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  • Use 'prt-get depinst' to install new software       ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  • New kernel? Re-run 'lilo' or 'grub-mkconfig'       ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ║${RESET}  • Read: https://crux.nu/Main/Handbook3-8             ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}  ╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""

    printf "  Type %bReboot%b to restart into your new CRUX system: " "${BOLD}" "${RESET}"
    local input
    read -r input
    if [[ "$input" == "Reboot" || "$input" == "reboot" ]]; then
        log_info "Rebooting..."
        reboot
    else
        log_info "Run 'reboot' when you are ready to restart."
    fi
    mark_step_complete "15.2"

    log_success "Module 15 — Finalization complete. Enjoy your CRUX system!"
}
