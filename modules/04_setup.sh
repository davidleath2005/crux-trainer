#!/usr/bin/env bash
# Module: 04 — CRUX Setup Script
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_04_setup() {
    show_chapter_header "Chapter 4" "CRUX Setup Script" \
        "https://crux.nu/Main/Handbook3-8"

    require_live

    # ── Step 4.1 — explain setup ────────────────────────────────────────────
    show_step 1 "Understanding the CRUX setup script"
    show_tip "Unlike many distributions, CRUX ships an interactive 'setup' script on the ISO. This dialog-based tool copies packages from the ISO to your mounted /mnt target. It does NOT compile anything — it uses pkgadd to install pre-built packages."

    cat <<'EOF'

  What the CRUX 'setup' script does:
  ────────────────────────────────────
  • Uses the dialog(1) tool to present a menu-driven interface
  • Lets you select which package groups to install:
      - core   — the essential base system (always install this)
      - opt    — commonly used optional packages
      - xorg   — X Window System packages
  • Within each group you can select individual packages
  • Uses pkgadd to install each selected package to /mnt
  • Installs the package database so pkginfo/prt-get work

  Package management in CRUX:
  ────────────────────────────
  Low-level tools (direct package operations):
    pkgadd  <pkg.tar.gz>    — install a package
    pkgrm   <name>          — remove a package
    pkginfo -i              — list installed packages
    pkginfo -o <file>       — which package owns a file

  High-level tool (resolves dependencies, syncs ports):
    prt-get depinst <name>  — install with dependencies
    prt-get sysup            — upgrade all packages
    prt-get search <term>   — search available ports
    prt-get info   <name>   — show port information
    prt-get listinst        — list installed ports
    prt-get diff            — show upgradeable packages

  The ports tree (/usr/ports/):
  ──────────────────────────────
    core/   — base system ports (always active)
    opt/    — optional ports
    contrib/ — community-contributed ports
    xorg/   — X Window System ports

EOF
    pause_and_continue
    mark_step_complete "04.1"

    # ── Step 4.2 — run setup ────────────────────────────────────────────────
    show_step 2 "Run the CRUX setup script"
    show_tip "The setup script must be run from the CRUX live environment with /mnt already mounted. Make sure you completed Module 03 (disk partitioning and mounting) before running setup."

    echo ""
    echo -e "  ${BOLD}Before running setup, verify /mnt is mounted:${RESET}"
    run_or_type "mountpoint /mnt" \
        "Verify that /mnt is a mountpoint. If this fails, go back to Module 03 and mount your root partition." \
        "https://crux.nu/Main/Handbook3-8"

    echo ""
    echo -e "  ${YELLOW}${BOLD}The setup script is interactive (dialog-based).${RESET}"
    echo -e "  ${YELLOW}It will run in the current terminal.${RESET}"
    echo -e "  ${YELLOW}Use Space to select packages, Tab to navigate, Enter to confirm.${RESET}"
    echo ""
    show_tip "Select at minimum the 'core' package group. Install 'opt' for common tools. Add 'xorg' if you plan to use a graphical environment."

    run_or_type "setup" \
        "Launch the CRUX ISO setup script. This dialog-based tool copies packages from the live CD to /mnt. Select at least 'core'. Navigate with Tab/arrow keys, select with Space, confirm with Enter." \
        "https://crux.nu/Main/Handbook3-8"

    mark_step_complete "04.2"

    # ── Step 4.3 — verify installation ──────────────────────────────────────
    show_step 3 "Verify the installation"
    show_tip "After setup completes, verify that the core system files were installed correctly. Check that /mnt/etc and /mnt/bin exist and that the package database was created."

    run_or_type "ls /mnt/etc" \
        "List /mnt/etc to verify that configuration files were installed." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "pkginfo --root /mnt -i | head -20" \
        "List the first 20 installed packages in the new system. This confirms pkgadd ran successfully and the package database is intact."

    echo ""
    echo -e "  ${BOLD}Expected directories in /mnt after setup:${RESET}"
    echo "  /mnt/bin   — essential binaries"
    echo "  /mnt/etc   — configuration files"
    echo "  /mnt/lib   — essential libraries"
    echo "  /mnt/usr   — user programs, ports tree source"
    echo "  /mnt/var   — variable data (logs, databases)"
    echo ""
    pause_and_continue
    mark_step_complete "04.3"

    log_success "Module 04 — CRUX setup script complete."
}
