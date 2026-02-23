#!/usr/bin/env bash
# Module: 03 — Disk Partitioning, Formatting, and Mounting
# Handbook Reference: https://crux.nu/Main/Handbook3-8

# Exported after user selection
TARGET_DISK=""
BOOT_PART=""
SWAP_PART=""
ROOT_PART=""
# shellcheck disable=SC2034  # HOME_PART reserved for future separate-/home layout
HOME_PART=""
CHOSEN_FS="ext4"
SWAP_TYPE="partition"   # partition | file | none

module_03_disks() {
    show_chapter_header "Chapter 3" "Preparing the Disks" \
        "https://crux.nu/Main/Handbook3-8"

    require_live

    # ── Step 3.1 — select disk ──────────────────────────────────────────────
    show_step 1 "Select the target disk"
    show_tip "CRUX installs to /mnt (not /mnt/gentoo). All data on the chosen disk will be erased. Double-check the disk name before confirming."

    run_or_type "fdisk -l" \
        "List all disks and their partitions. Use this to identify the disk you want to install CRUX on." \
        "https://crux.nu/Main/Handbook3-8"

    echo ""
    if [[ ${#HW_DISKS[@]} -gt 0 ]]; then
        show_menu "Select the target disk for installation" "${HW_DISKS[@]}"
        TARGET_DISK="${HW_DISKS[$((MENU_CHOICE - 1))]}"
    else
        printf "  Enter the target disk (e.g. /dev/sda): "
        read -r TARGET_DISK
    fi
    log_info "Target disk: ${TARGET_DISK}"
    save_progress "TARGET_DISK" "$TARGET_DISK"
    mark_step_complete "03.1"

    # ── Step 3.2 — partition layout ─────────────────────────────────────────
    show_step 2 "Partition the disk"
    show_tip "GPT is recommended for UEFI systems and for disks > 2 TB. MBR (msdos) works on BIOS systems. CRUX traditionally keeps things simple — a boot partition, optional swap, and root."

    local swap_size="4G"

    if [[ "$HW_BOOT_MODE" == "uefi" ]]; then
        log_info "UEFI system detected — will use GPT + EFI System Partition."
        log_info "Partition plan:"
        echo "  ${TARGET_DISK}p1  512M  EFI System Partition  (FAT32, /boot/efi)"
        echo "  ${TARGET_DISK}p2  ${swap_size}  Linux swap"
        echo "  ${TARGET_DISK}p3  rest  Linux root  (mounted at /mnt)"
    else
        log_info "BIOS system detected — will use GPT with a BIOS boot partition."
        echo "  ${TARGET_DISK}1  1M    BIOS boot partition  (no filesystem)"
        echo "  ${TARGET_DISK}2  ${swap_size}  Linux swap"
        echo "  ${TARGET_DISK}3  rest  Linux root  (mounted at /mnt)"
    fi

    show_menu "Choose root filesystem" \
        "ext4  — mature, reliable, good all-rounder (recommended)" \
        "xfs   — great for large files and servers" \
        "btrfs — modern with snapshots and compression"
    case "$MENU_CHOICE" in
        1) CHOSEN_FS="ext4"  ;;
        2) CHOSEN_FS="xfs"   ;;
        3) CHOSEN_FS="btrfs" ;;
    esac

    show_menu "Choose swap type" \
        "Swap partition (traditional, recommended)" \
        "Swap file (flexible, created after mounting root)" \
        "No swap (not recommended for < 8 GB RAM)"
    case "$MENU_CHOICE" in
        1) SWAP_TYPE="partition" ;;
        2) SWAP_TYPE="file"      ;;
        3) SWAP_TYPE="none"      ;;
    esac

    save_progress "CHOSEN_FS" "$CHOSEN_FS"
    save_progress "SWAP_TYPE" "$SWAP_TYPE"

    confirm_destructive "All data on ${TARGET_DISK} will be permanently erased!" || return 1

    if [[ "$HW_BOOT_MODE" == "uefi" ]]; then
        run_or_type "parted -s ${TARGET_DISK} mklabel gpt" \
            "Create a new GPT partition table on ${TARGET_DISK}. This erases all existing partitions." \
            "https://crux.nu/Main/Handbook3-8"

        run_or_type "parted -s ${TARGET_DISK} mkpart ESP fat32 1MiB 513MiB" \
            "Create the 512 MiB EFI System Partition (ESP). FAT32 is required by the UEFI specification."

        run_or_type "parted -s ${TARGET_DISK} set 1 esp on" \
            "Mark the first partition as an EFI System Partition using the 'esp' flag."

        if [[ "$SWAP_TYPE" == "partition" ]]; then
            run_or_type "parted -s ${TARGET_DISK} mkpart primary linux-swap 513MiB 4609MiB" \
                "Create a 4 GiB swap partition."
            run_or_type "parted -s ${TARGET_DISK} mkpart primary ${CHOSEN_FS} 4609MiB 100%" \
                "Create the root partition using the rest of the disk."
        else
            run_or_type "parted -s ${TARGET_DISK} mkpart primary ${CHOSEN_FS} 513MiB 100%" \
                "Create the root partition using the rest of the disk."
        fi
    else
        run_or_type "parted -s ${TARGET_DISK} mklabel gpt" \
            "Create a new GPT partition table on ${TARGET_DISK}."

        run_or_type "parted -s ${TARGET_DISK} mkpart primary 1MiB 2MiB" \
            "Create a 1 MiB BIOS boot partition required by GRUB on GPT+BIOS systems."

        run_or_type "parted -s ${TARGET_DISK} set 1 bios_grub on" \
            "Mark the first partition as a BIOS boot partition."

        if [[ "$SWAP_TYPE" == "partition" ]]; then
            run_or_type "parted -s ${TARGET_DISK} mkpart primary linux-swap 2MiB 4098MiB" \
                "Create a 4 GiB swap partition."
            run_or_type "parted -s ${TARGET_DISK} mkpart primary ${CHOSEN_FS} 4098MiB 100%" \
                "Create the root partition."
        else
            run_or_type "parted -s ${TARGET_DISK} mkpart primary ${CHOSEN_FS} 2MiB 100%" \
                "Create the root partition."
        fi
    fi
    mark_step_complete "03.2"

    # ── Step 3.3 — format ───────────────────────────────────────────────────
    show_step 3 "Format the partitions"
    show_tip "Formatting creates a filesystem on each partition. We use mkfs tools matched to the filesystem type we chose."

    # Derive partition names (nvme uses p-suffix, others don't)
    local p=""
    if [[ "$TARGET_DISK" =~ nvme ]]; then
        p="p"
    fi

    if [[ "$HW_BOOT_MODE" == "uefi" ]]; then
        BOOT_PART="${TARGET_DISK}${p}1"
        run_or_type "mkfs.fat -F32 ${BOOT_PART}" \
            "Format the EFI System Partition as FAT32. The -F32 flag explicitly selects FAT32 over FAT16." \
            "https://crux.nu/Main/Handbook3-8"
        if [[ "$SWAP_TYPE" == "partition" ]]; then
            SWAP_PART="${TARGET_DISK}${p}2"
            ROOT_PART="${TARGET_DISK}${p}3"
        else
            ROOT_PART="${TARGET_DISK}${p}2"
        fi
    else
        # BIOS: p1 is bios_grub (no format)
        if [[ "$SWAP_TYPE" == "partition" ]]; then
            SWAP_PART="${TARGET_DISK}${p}2"
            ROOT_PART="${TARGET_DISK}${p}3"
        else
            ROOT_PART="${TARGET_DISK}${p}2"
        fi
    fi

    if [[ "$SWAP_TYPE" == "partition" && -n "$SWAP_PART" ]]; then
        run_or_type "mkswap ${SWAP_PART}" \
            "Set up the swap partition. mkswap writes the swap signature so Linux can use it as virtual memory." \
            "https://crux.nu/Main/Handbook3-8"
        run_or_type "swapon ${SWAP_PART}" \
            "Activate the swap partition immediately so the live system can use it during installation."
    fi

    case "$CHOSEN_FS" in
        ext4)
            run_or_type "mkfs.ext4 ${ROOT_PART}" \
                "Format the root partition as ext4. ext4 is mature and reliable — the default for most CRUX installations." \
                "https://crux.nu/Main/Handbook3-8"
            ;;
        xfs)
            run_or_type "mkfs.xfs ${ROOT_PART}" \
                "Format the root partition as XFS. XFS excels with large files and high-throughput workloads."
            ;;
        btrfs)
            run_or_type "mkfs.btrfs ${ROOT_PART}" \
                "Format the root partition as Btrfs. Btrfs supports snapshots, transparent compression, and checksums."
            ;;
    esac

    save_progress "BOOT_PART" "$BOOT_PART"
    save_progress "SWAP_PART" "$SWAP_PART"
    save_progress "ROOT_PART" "$ROOT_PART"
    mark_step_complete "03.3"

    # ── Step 3.4 — mount ────────────────────────────────────────────────────
    show_step 4 "Mount the partitions"
    show_tip "CRUX mounts the installation target at /mnt (not /mnt/gentoo). The CRUX setup script expects to find /mnt as the root."

    run_or_type "mount ${ROOT_PART} /mnt" \
        "Mount the root partition at /mnt. This is the CRUX installation target directory." \
        "https://crux.nu/Main/Handbook3-8"

    if [[ "$HW_BOOT_MODE" == "uefi" && -n "$BOOT_PART" ]]; then
        run_or_type "mkdir -p /mnt/boot/efi" \
            "Create the EFI mount point inside the new root filesystem."
        run_or_type "mount ${BOOT_PART} /mnt/boot/efi" \
            "Mount the EFI System Partition at /mnt/boot/efi."
    fi

    mark_step_complete "03.4"
    log_success "Module 03 — Disk preparation complete."
}
