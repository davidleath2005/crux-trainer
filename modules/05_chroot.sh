#!/usr/bin/env bash
# Module: 05 — Chroot Setup
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_05_chroot() {
    show_chapter_header "Chapter 5" "Chroot Setup" \
        "https://crux.nu/Main/Handbook3-8"

    require_live

    # ── Step 5.1 — copy DNS info ────────────────────────────────────────────
    show_step 1 "Copy DNS information"
    show_tip "We copy /etc/resolv.conf so the chroot environment can resolve DNS names. Without this, network access inside the chroot will fail."

    run_or_type "cp /etc/resolv.conf /mnt/etc/resolv.conf" \
        "Copy DNS resolver configuration into the new root so network access works inside the chroot." \
        "https://crux.nu/Main/Handbook3-8"

    mark_step_complete "05.1"

    # ── Step 5.2 — mount pseudo-filesystems ─────────────────────────────────
    show_step 2 "Mount pseudo-filesystems"
    show_tip "The pseudo-filesystems (proc, sys, dev) give chrooted processes access to kernel and device information. Without them, many programs inside the chroot will fail."

    run_or_type "mount --bind /dev /mnt/dev" \
        "Bind-mount /dev into the chroot so device nodes are accessible inside." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "mount --bind /tmp /mnt/tmp" \
        "Bind-mount /tmp so temporary files from the live environment are accessible."

    run_or_type "mount -t proc proc /mnt/proc" \
        "Mount the proc pseudo-filesystem. It exposes kernel and process information to programs."

    run_or_type "mount -t sysfs sysfs /mnt/sys" \
        "Mount sysfs, which provides a view of the kernel object tree including device and driver info."

    mark_step_complete "05.2"

    # ── Step 5.3 — enter chroot ─────────────────────────────────────────────
    show_step 3 "Enter the chroot environment"
    show_tip "chroot changes the apparent root directory for the process. After this command, '/' refers to /mnt. All subsequent installation commands operate on the new CRUX system."

    echo ""
    echo -e "  ${YELLOW}${BOLD}IMPORTANT:${RESET} The next command will enter the chroot."
    echo -e "  ${YELLOW}You will need to re-run the remaining modules from inside the chroot.${RESET}"
    echo -e "  ${YELLOW}After entering, run the crux-trainer.sh script again.${RESET}"
    echo ""

    run_or_type "chroot /mnt /bin/bash" \
        "Change root into /mnt running /bin/bash. From this point, all commands operate on the new CRUX system. Run the trainer script again inside the chroot to continue." \
        "https://crux.nu/Main/Handbook3-8"

    mark_step_complete "05.3"
    log_success "Module 05 — Chroot setup complete."
}
