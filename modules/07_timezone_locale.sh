#!/usr/bin/env bash
# Module: 07 — Timezone & Locale
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_07_timezone_locale() {
    show_chapter_header "Chapter 7" "Timezone & Locale" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 7.1 — set timezone ─────────────────────────────────────────────
    show_step 1 "Set the system timezone"
    show_tip "CRUX sets the timezone by creating a symlink from /etc/localtime to the appropriate file in /usr/share/zoneinfo/. Common timezones: America/New_York, Europe/London, Asia/Tokyo."

    echo ""
    printf "  Enter your timezone (e.g. America/New_York): "
    local tz
    read -r tz
    tz="${tz:-UTC}"
    save_progress "TIMEZONE" "$tz"

    run_or_type "ln -sf /usr/share/zoneinfo/${tz} /etc/localtime" \
        "Create a symlink from /etc/localtime to your chosen timezone file. This tells the system your local offset from UTC." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "date" \
        "Verify the current date and time now reflects the correct timezone."

    mark_step_complete "07.1"

    # ── Step 7.2 — set locale ───────────────────────────────────────────────
    show_step 2 "Configure locale"
    show_tip "CRUX uses /etc/profile.d/locale.sh or direct environment variables in /etc/environment for locale settings. Locale affects language, character encoding, and number/date formatting."

    echo ""
    echo -e "  ${BOLD}Set locale environment variables in /etc/environment:${RESET}"
    echo ""
    cat <<'EOF'
  Example /etc/environment:
  ──────────────────────────
  LANG=en_US.UTF-8
  LC_COLLATE=C
EOF
    echo ""

    run_or_type "nano /etc/environment" \
        "Open /etc/environment to set locale variables. Add LANG=en_US.UTF-8 (or your preferred locale). LC_COLLATE=C keeps sorting consistent in scripts." \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "UTF-8 is the recommended encoding. It supports all Unicode characters and is required by many modern applications."

    mark_step_complete "07.2"

    log_success "Module 07 — Timezone & Locale complete."
}
