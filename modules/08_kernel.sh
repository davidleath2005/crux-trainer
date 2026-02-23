#!/usr/bin/env bash
# Module: 08 — Kernel Configuration
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_08_kernel() {
    show_chapter_header "Chapter 8" "Kernel Configuration & Compilation" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 8.1 — overview ──────────────────────────────────────────────────
    show_step 1 "CRUX kernel compilation overview"
    show_tip "CRUX always compiles the kernel manually. There is no distribution kernel or genkernel equivalent. This gives you full control over what drivers and features are included, producing a lean, custom kernel."

    cat <<'EOF'

  CRUX kernel compilation workflow:
  ───────────────────────────────────
  1. Install kernel sources via prt-get
  2. cd /usr/src/linux-<version>
  3. make menuconfig          — configure the kernel interactively
  4. make -j<cores>           — compile (can take 15-60 minutes)
  5. make modules_install     — install kernel modules to /lib/modules/
  6. make install             — copy kernel image to /boot/
  7. Configure bootloader to point at new kernel

  Tips for make menuconfig:
  • Press / to search for options
  • Press ? for help on the current option
  • [*] = built-in, [M] = module, [ ] = disabled
  • Enable the drivers for YOUR hardware
  • At minimum: your disk controller, filesystem, network card

EOF
    pause_and_continue
    mark_step_complete "08.1"

    # ── Step 8.2 — install kernel sources ───────────────────────────────────
    show_step 2 "Install kernel sources"
    show_tip "CRUX ships the kernel sources in the 'core' ports collection. If you installed 'core' via setup, the kernel sources may already be available. Otherwise, install them via prt-get."

    run_or_type "prt-get depinst linux" \
        "Install the Linux kernel sources. prt-get will resolve dependencies and build/install the kernel source package." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "ls /usr/src/" \
        "List the contents of /usr/src/ to find the kernel source directory name."

    mark_step_complete "08.2"

    # ── Step 8.3 — configure, compile, and install ──────────────────────────
    show_step 3 "Configure, compile, and install the kernel"
    show_tip "Use 'make menuconfig' to configure which drivers and features to build. Enable everything your hardware needs. When in doubt, build it as a module [M] rather than omitting it."

    local cores="${HW_CPU_CORES:-1}"

    echo ""
    echo -e "  ${BOLD}Navigate to the kernel source directory:${RESET}"
    run_or_type "cd /usr/src/linux" \
        "Change into the kernel source directory. The setup script may have created a 'linux' symlink, or use the full versioned directory name." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "make menuconfig" \
        "Open the interactive kernel configuration menu. Use arrow keys to navigate, Space to toggle options ([*]=built-in, [M]=module), / to search, ? for help. Enable all drivers needed for your hardware." \
        "https://crux.nu/Main/Handbook3-8" \
        "Essential options to enable:
  - Disk: CONFIG_ATA, CONFIG_SATA_AHCI (for SATA), CONFIG_NVME_CORE (for NVMe)
  - Filesystem: CONFIG_EXT4_FS (or your chosen fs)
  - Network: your NIC driver (check 'lspci' output)
  - USB: CONFIG_USB_HID, CONFIG_USB_SUPPORT
  - UEFI: CONFIG_EFI, CONFIG_EFI_STUB (for UEFI boot)
  - Initrd: CONFIG_BLK_DEV_INITRD if using an initramfs"

    run_or_type "make -j${cores}" \
        "Compile the kernel using ${cores} parallel jobs. This can take 15-60 minutes depending on your configuration and hardware speed."

    run_or_type "make modules_install" \
        "Install the compiled kernel modules to /lib/modules/<kernel-version>/. These are loaded on demand by the kernel."

    run_or_type "make install" \
        "Copy the kernel image (vmlinuz), System.map, and .config to /boot. The bootloader will need to know the kernel filename."

    run_or_type "ls /boot" \
        "List /boot to verify the kernel image was installed. Note the filename (e.g. vmlinuz-6.x.y) for the bootloader configuration."

    mark_step_complete "08.3"

    log_success "Module 08 — Kernel compilation complete."
}
