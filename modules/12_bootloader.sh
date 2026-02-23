#!/usr/bin/env bash
# Module: 12 — Bootloader Configuration
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_12_bootloader() {
    show_chapter_header "Chapter 12" "Configuring the Bootloader" \
        "https://crux.nu/Main/Handbook3-8"

    local target_disk
    target_disk=$(load_progress "TARGET_DISK")
    target_disk="${target_disk:-/dev/sda}"

    # ── Step 12.1 — choose bootloader ────────────────────────────────────────
    show_step 1 "Choose and install a bootloader"
    show_tip "CRUX traditionally uses LILO (LInux LOader) but GRUB2 is also fully supported and recommended for UEFI systems. LILO is simpler and CRUX-native; GRUB2 offers more features."

    show_menu "Choose a bootloader" \
        "GRUB2 — recommended, supports UEFI and BIOS" \
        "LILO  — traditional CRUX bootloader, BIOS only"
    local bl_choice="$MENU_CHOICE"
    save_progress "BOOTLOADER" "$bl_choice"

    if [[ "$bl_choice" == "1" ]]; then
        # ── GRUB2 ────────────────────────────────────────────────────────────
        show_tip "GRUB2 auto-detects installed kernels and generates a boot menu. On UEFI systems it installs to the EFI partition; on BIOS it writes to the disk's boot record."

        run_or_type "prt-get depinst grub2" \
            "Install GRUB2 via the ports system. prt-get will compile it with the correct options." \
            "https://crux.nu/Main/Handbook3-8"

        if [[ "$HW_BOOT_MODE" == "uefi" ]]; then
            run_or_type "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=CRUX" \
                "Install GRUB2 to the EFI System Partition. --efi-directory points to where the EFI partition is mounted; --bootloader-id sets the EFI boot entry name." \
                "https://crux.nu/Main/Handbook3-8"
        else
            run_or_type "grub-install ${target_disk}" \
                "Install GRUB2 to the Master Boot Record (or GPT protective MBR) of ${target_disk}." \
                "https://crux.nu/Main/Handbook3-8"
        fi

        run_or_type "grub-mkconfig -o /boot/grub/grub.cfg" \
            "Generate the GRUB2 configuration file. This scans /boot for installed kernels and creates boot menu entries automatically."

        run_or_type "cat /boot/grub/grub.cfg | grep -A3 'menuentry'" \
            "Display the generated GRUB menu entries to verify your kernel was detected correctly."

    else
        # ── LILO ─────────────────────────────────────────────────────────────
        show_tip "LILO is installed on most CRUX systems by default. You only need to configure /etc/lilo.conf and run 'lilo' to write the bootloader. LILO must be re-run every time the kernel changes."

        echo ""
        echo -e "  ${BOLD}Example /etc/lilo.conf:${RESET}"
        cat <<EOF

  boot=${target_disk}
  compact

  image=/boot/vmlinuz
    root=/dev/sda3    # ← change to your root partition
    label=CRUX
    read-only

EOF

        run_or_type "nano /etc/lilo.conf" \
            "Open /etc/lilo.conf to configure LILO. Set 'boot' to your disk, 'image' to your kernel file in /boot, and 'root' to your root partition device." \
            "https://crux.nu/Main/Handbook3-8"

        run_or_type "lilo" \
            "Write the LILO bootloader to the boot sector. You must re-run 'lilo' every time you update the kernel or change lilo.conf." \
            "https://crux.nu/Main/Handbook3-8"

        show_tip "Remember: with LILO, if you compile a new kernel you MUST re-run 'lilo' after copying the kernel to /boot. Forgetting this step is a common mistake."
    fi

    mark_step_complete "12.1"

    # ── Step 12.2 — verify boot configuration ────────────────────────────────
    show_step 2 "Verify boot configuration"
    show_tip "Before rebooting, verify that the kernel image exists in /boot and the bootloader configuration references the correct kernel filename."

    run_or_type "ls -lh /boot" \
        "List all files in /boot. Verify the kernel image (vmlinuz or vmlinuz-<version>) is present." \
        "https://crux.nu/Main/Handbook3-8"

    mark_step_complete "12.2"

    log_success "Module 12 — Bootloader configuration complete."
}
