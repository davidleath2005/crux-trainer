#!/usr/bin/env bash
# Module: 13 — Users & Passwords
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_13_users() {
    show_chapter_header "Chapter 13" "Users & Passwords" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 13.1 — set root password ───────────────────────────────────────
    show_step 1 "Set the root password"
    show_tip "The root password was not set by the setup script. You must set it now before rebooting, otherwise you will be locked out of your new system."

    run_or_type "passwd root" \
        "Set the password for the root account. You will be prompted to enter and confirm the new password." \
        "https://crux.nu/Main/Handbook3-8"

    mark_step_complete "13.1"

    # ── Step 13.2 — create regular user ─────────────────────────────────────
    show_step 2 "Create a regular user account"
    show_tip "Running as root for daily tasks is dangerous. Create a regular user for everyday use. CRUX does not include sudo by default — install it via prt-get if you need it."

    echo ""
    printf "  Enter the new username: "
    local username
    read -r username
    save_progress "USERNAME" "$username"

    run_or_type "useradd -m -g users -G audio,video,cdrom,usb -s /bin/bash ${username}" \
        "Create user '${username}' with a home directory (-m), primary group 'users', added to common groups (-G), and bash as their shell." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "passwd ${username}" \
        "Set the password for '${username}'. You will be prompted to enter and confirm it."

    echo ""
    echo -e "  ${BOLD}Optional: install sudo for privilege escalation${RESET}"
    printf "  Install sudo? [y/N]: "
    local install_sudo
    read -r install_sudo
    if [[ "${install_sudo,,}" == "y" ]]; then
        run_or_type "prt-get depinst sudo" \
            "Install sudo, the tool that allows users to run commands as root with proper authentication and logging."

        run_or_type "visudo" \
            "Open the sudoers file safely. Uncomment or add: '${username} ALL=(ALL:ALL) ALL' to grant this user sudo access."
    fi

    mark_step_complete "13.2"

    log_success "Module 13 — Users & Passwords complete."
}
