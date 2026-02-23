#!/usr/bin/env bash
# Module: 09 — fstab Generation
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_09_fstab() {
    show_chapter_header "Chapter 9" "Generating /etc/fstab" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 9.1 — explain fstab ────────────────────────────────────────────
    show_step 1 "Understanding /etc/fstab"
    show_tip "/etc/fstab tells the kernel which filesystems to mount at boot and where to mount them. Errors in fstab can prevent the system from booting. Using UUIDs is more reliable than device names like /dev/sda3, which can change."

    local root_part boot_part swap_part chosen_fs
    root_part=$(load_progress "ROOT_PART")
    boot_part=$(load_progress "BOOT_PART")
    swap_part=$(load_progress "SWAP_PART")
    chosen_fs=$(load_progress "CHOSEN_FS")
    root_part="${root_part:-/dev/sda1}"
    chosen_fs="${chosen_fs:-ext4}"

    echo ""
    run_or_type "blkid" \
        "Show UUIDs and filesystem types for all block devices. Copy the UUID values for use in /etc/fstab." \
        "https://crux.nu/Main/Handbook3-8"

    echo ""
    echo -e "  ${BOLD}Example /etc/fstab entries:${RESET}"
    cat <<'EOF'

  # <device>                                <mnt>   <type>  <opts>         <dump> <pass>
  UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /       ext4    defaults       0      1
  UUID=yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy none    swap    sw             0      0
  UUID=zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz /boot/efi vfat defaults,noatime 0  2

  # /proc, /sys, /dev are mounted automatically by the init scripts in CRUX
  # but you may add tmpfs entries:
  tmpfs                                     /tmp    tmpfs   defaults,size=512m 0  0

  Notes:
  • pass=1 for root (fsck runs first)
  • pass=2 for other partitions (fsck runs after root)
  • pass=0 to skip fsck (for swap, proc, etc.)

EOF
    pause_and_continue
    mark_step_complete "09.1"

    # ── Step 9.2 — create fstab ─────────────────────────────────────────────
    show_step 2 "Create /etc/fstab"
    show_tip "Edit /etc/fstab manually using the UUID values from blkid. Make sure every mounted partition from your disk setup has a corresponding fstab entry."

    echo ""
    echo -e "  ${BOLD}Your disk configuration from Module 03:${RESET}"
    echo "  Root partition : ${root_part} (${chosen_fs})"
    [[ -n "$boot_part" ]] && echo "  Boot partition : ${boot_part} (vfat/EFI)"
    [[ -n "$swap_part" ]] && echo "  Swap partition : ${swap_part}"
    echo ""

    run_or_type "nano /etc/fstab" \
        "Open /etc/fstab in nano. Add entries for each of your partitions using UUIDs from the blkid output above. Save with Ctrl+O, exit with Ctrl+X." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "cat /etc/fstab" \
        "Display the final /etc/fstab to verify it looks correct before rebooting."

    mark_step_complete "09.2"

    log_success "Module 09 — fstab generation complete."
}
