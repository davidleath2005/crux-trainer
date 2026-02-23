#!/usr/bin/env bash
# Module: 06 — Ports & prt-get Configuration
# Handbook Reference: https://crux.nu/Main/Handbook3-8

module_06_ports() {
    show_chapter_header "Chapter 6" "Ports & prt-get Configuration" \
        "https://crux.nu/Main/Handbook3-8"

    # ── Step 6.1 — ports tree overview ──────────────────────────────────────
    show_step 1 "Understanding the CRUX ports tree"
    show_tip "The CRUX ports system is inspired by BSD ports. Each 'port' is a directory containing a Pkgfile (build recipe) and optional patches. You build ports locally with pkgmk, then install with pkgadd."

    cat <<'EOF'

  Ports tree structure: /usr/ports/
  ───────────────────────────────────
  /usr/ports/core/       — base system (maintained by CRUX team)
  /usr/ports/opt/        — optional packages (maintained by CRUX team)
  /usr/ports/contrib/    — community-contributed packages
  /usr/ports/xorg/       — X Window System packages

  Each port directory looks like this:
  /usr/ports/opt/vim/
    Pkgfile           — build recipe (name, version, source, build())
    .footprint         — expected files list (for verification)
    .md5sum            — checksums for source archives

  Pkgfile format:
  ───────────────
  # Description: Description of the software
  # URL:          Upstream homepage
  # Maintainer:   Name, email
  # Depends on:   dep1 dep2

  name=vim
  version=9.1.0
  release=1

  source=(https://example.com/$name-$version.tar.gz)

  build() {
    cd $name-$version
    ./configure --prefix=/usr
    make
    make DESTDIR=$PKG install
  }

  Key variables in Pkgfile:
    $name     — port name
    $version  — package version
    $release  — build release number
    $SRC      — directory where sources are extracted
    $PKG      — directory where files should be installed
    $PKGMK_SOURCE_DIR — where source tarballs are cached

EOF
    pause_and_continue
    mark_step_complete "06.1"

    # ── Step 6.2 — configure prt-get.conf ───────────────────────────────────
    show_step 2 "Configure prt-get.conf and enable ports collections"
    show_tip "prt-get.conf controls which ports collections are active and how packages are built. By default only 'core' and 'opt' are enabled. You should enable 'contrib' and optionally 'xorg' for a fuller system."

    echo ""
    echo -e "  ${BOLD}Current /etc/prt-get.conf (key settings):${RESET}"
    echo ""
    cat <<'EOF'
  # prtdir — each line adds a ports collection directory
  prtdir /usr/ports/core
  prtdir /usr/ports/opt
  # prtdir /usr/ports/contrib   ← uncomment to enable
  # prtdir /usr/ports/xorg      ← uncomment to enable

  # makecommand — tool used to build ports (default: pkgmk)
  makecommand pkgmk

  # addcommand — tool used to install packages (default: pkgadd)
  addcommand pkgadd

  # runscripts — run pre/post-install scripts
  runscripts yes
EOF
    echo ""

    run_or_type "nano /etc/prt-get.conf" \
        "Open /etc/prt-get.conf in nano. Uncomment the 'prtdir /usr/ports/contrib' line to enable community packages. Add 'prtdir /usr/ports/xorg' if you want X11 packages. Save with Ctrl+O, exit with Ctrl+X." \
        "https://crux.nu/Main/Handbook3-8"

    show_tip "The order of 'prtdir' lines matters. If the same port exists in multiple collections, the first listed wins. core should always come before opt, which should come before contrib."

    mark_step_complete "06.2"

    # ── Step 6.3 — configure ports rsync files ──────────────────────────────
    show_step 3 "Configure ports rsync files"
    show_tip "Each ports collection has an rsync configuration file in /etc/ports/. These tell the 'ports -u' command where to sync from. The files are named <collection>.rsync."

    echo ""
    echo -e "  ${BOLD}Ports rsync configuration files:${RESET}"
    run_or_type "ls /etc/ports/" \
        "List the rsync configuration files for each ports collection." \
        "https://crux.nu/Main/Handbook3-8"

    echo ""
    echo -e "  ${BOLD}Example /etc/ports/core.rsync:${RESET}"
    cat <<'EOF'
  [rsync]
  host=crux.nu
  collection=/ports/3.8/core
  destination=/usr/ports/core
EOF
    echo ""
    echo -e "  ${BOLD}To enable the contrib collection, create /etc/ports/contrib.rsync:${RESET}"
    echo ""

    run_or_type "cat /etc/ports/contrib.rsync.inactive" \
        "View the inactive contrib rsync configuration. If this file exists, rename it to .rsync to enable syncing the contrib collection."

    printf "  Enable the contrib collection? [Y/n]: "
    local enable_contrib
    read -r enable_contrib
    if [[ "${enable_contrib,,}" != "n" ]]; then
        run_or_type "mv /etc/ports/contrib.rsync.inactive /etc/ports/contrib.rsync" \
            "Rename the contrib rsync file to activate it. The 'ports -u' command will now sync the contrib collection." \
            "https://crux.nu/Main/Handbook3-8"
    fi

    mark_step_complete "06.3"

    # ── Step 6.4 — sync ports and demonstrate prt-get ───────────────────────
    show_step 4 "Sync ports tree and explore prt-get"
    show_tip "'ports -u' downloads the latest port metadata (Pkgfiles) from the CRUX servers using rsync. This updates /usr/ports/ but does NOT compile or install anything. It is equivalent to 'apt update' on Debian."

    run_or_type "ports -u" \
        "Synchronise all active ports collections. This downloads the latest Pkgfiles and metadata. Run this before installing new packages or upgrading the system." \
        "https://crux.nu/Main/Handbook3-8"

    echo ""
    echo -e "  ${BOLD}Common prt-get subcommands:${RESET}"
    cat <<'EOF'

  prt-get search <term>        — search port names and descriptions
  prt-get info <name>          — show detailed port info
  prt-get depends <name>       — show dependencies
  prt-get depinst <name>       — install port with all dependencies
  prt-get listinst             — list all installed ports
  prt-get diff                 — show ports with available upgrades
  prt-get sysup                — upgrade all outdated ports
  prt-get remove <name>        — remove a port

  Low-level pkgmk/pkgadd workflow:
    cd /usr/ports/opt/vim
    pkgmk -d               — download sources and build the package
    pkgadd vim#9.1.0-1.pkg.tar.gz  — install the built package
    pkgmk -uf              — rebuild ignoring footprint mismatch

  Footprint mismatches:
    A footprint mismatch means the built package contains files not
    listed in .footprint. This often happens when optional features
    are compiled in. Use 'pkgmk -uf' to update the footprint and
    force the install. NEW entries are usually harmless; MISSING
    entries may indicate a build failure.

EOF

    run_or_type "prt-get search vim" \
        "Search for the 'vim' port by name. This searches all active ports collections defined in prt-get.conf." \
        "https://crux.nu/Main/Handbook3-8"

    run_or_type "prt-get info vim" \
        "Show detailed information about the vim port: version, description, dependencies, and maintainer."

    pause_and_continue
    mark_step_complete "06.4"

    log_success "Module 06 — Ports & prt-get configuration complete."
}
