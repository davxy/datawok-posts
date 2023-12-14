+++
title = "Linux Workstation Tools"
date = "2022-12-18"
modified = "2023-07-23"
tags = ["system","tooling"]
+++

Discovering the right tools can significantly improve your productivity and user
experience on any operating system. In this post, I'll share some of my go-to
tools that I personally use on my workstation to enhance my workflow.


## System

- `iproute2`: IP routing utilities
- `sudo`: Provide limited super user privileges to specific users
- `rsync`: fast, versatile, remote (and local) file-copying tool
- `openssh`: secure shell client and server (metapackage)
- `btrfs-progs`: btrfs filesystem utilities
- `cpupower`: tool to examine and tune power savings
- `fwupd`: daemon to allow session software to update firmware
- `intel-ucode/amd-ucode`: microcode update files for intel/amd cpus
- `libpulse`: general-purpose sound server
- `alsa-utils`: advanced linux sound architecture utilities:w
- `bash-completion`: programmable completion for the bash shell
- `bluez`: daemons for the bluetooth protocol stack
- `cifs-utils`: cifs filesystem utilities
- `cups`: common unix printing system
- `pipewire`: audio and video processing engine multimedia server
- `wireplumber`: session/policy manager implementation for pipewire
- `tlp`: optimize laptop battery life
- `noto-fonts-emoji`: google noto emoji fonts
- `ttf-jetbrains-mono-nerd`: patched font jetbrains mono
- `ttf-font-awesome`: iconic fonts designed for bootstrap
- `snapper`: btrfs snapshots management tool
- `snap-pac`: pacman hooks to use snapper to create btrfs snapshots
- `wpa_supplicant`: utility for WPA wireless networks key negotiation
- `yay`: pacman wrapper and AUR helper
- `polkit`: toolkit for controlling system-wide provileges
- `gnome-keyring`: stores passwords and encryption keys
- `libsecret`: library for storing passwords and other secrets
- `ufw`: uncomplicated firewall

## Utilities

- `ripgrep`: recursively searches directories for a regex pattern
- `eza`: modern replacement for ls
- `fzf`: general-purpose command-line fuzzy finder
- `bat`: cat clone with syntax highlighting and git integration
- `gnupg`: free implementation of openpgp standard
- `alacritty`: gpu-accelerated terminal emulator
- `ranger`: console file manager with vi keybindings
- `broot`: console file manager with integrated fzf
- `trash-cli`: command line trashcan utility
- `zoxide`: faster way to navigate filesystem
- `oath-toolkit`: tool for one-time password authentication systems
- `cryptsetup`: tool for transparent encryption of block devices using dm-crypt
- `bottom`: graphical process/system monitor for the terminal
- `helix`: modern modal editor
- `zellij`: terminal multiplexer
- `wdiff`: Compares two files word by word
- `jq`: command line json processor
- `libnotify`: library for sending desktop notifications
- `neofetch`: cli system information tool
- `starship`: rust friendly bash prompt
- `scdaemon`: to present yubikey as a smart card to the os
- `yubikey-manager`: cli for configuring yubikey
- `yubikey-personalization`: personalization library and tool
- `wol`: wake on lan tool

## Desktop

- `hyprland`: dynamic tiling wayland compositor
- `hyprpaper`: wayland wallpaper utility
- `waybar`: wayand bar for sway and wlroots based compositors (`waybar-hyprland-git`)
- `greetd`: wayland login manager
- `mako`: lightweight notification daemon for wayland
- `xdg-utils`: desktop integration utilities 
- `xdg-desktop-portal`: desktop integration portals for sandboxed apps
- `xdg-user-dirs`: common user directories
- `fuzzel`: application launcher for wayland
- `swaylock`: screen locker for wayland (`swaylock-effets`)
- `imv`: image viewer for wayland
- `grim`: screenshot utilities for wayland
- `gammastep`: adjust display color temperature
- `bitwarden`: password manager
- `brigthtnessctl`: brightness control tool
- `firefox`: web browser
- `greetd-tuigreet`: console UI greeter for greetd
- `vlc`: media player
- `wayvnc`: VNC server for wlroots-based wayland compositors
- `waypipe`: forward wayland applications via ssh
- `wob`: overlay volume/backlight/progress bar for wayland
- `wtype`: generate keyboard/mouse input events
- `zathura`: document viewer
- `zathura-pdf-poppler`: pdf support for zathura using the poppler engine
- `rofimoji`: a character picker for rofi/wofi
- `protonmail-bridge-nogui`: proton-mail support tool
- `pavucontrol`: pulse-audio volume control
- `seahorse`: gnome application for managing pgp keys and secrets
- `slurp`: select a region in a wayland compositor
- `swayidle`: idle management daemon for wayland
- `thunderbird`: mail and news reader
- `wdisplays`: display configurator for wlroots compositors

## Development

- `clang`: C, C++ and Objective-C compiler (LLVM based), clang binary
- `git`: fast, scalable, distributed version control system
- `lldb`: Next generation, high-performance debugger
- `make`: utility for directing compilation
- `clang`: C language family frontend for LLVM
- `rustup`: rust programming language toolchain installer
- `gitui`: terminal based git ui
- `meld`: graphical tool to diff and merge files
- `git-delta`: syntax-highlighting pager for git
- `protobuf`: protocol buffers compiler and utilities

## Containers and Virtualization

- `docker-compose`: define and run multi-container Docker applications with YAML
- `docker`: linux container runtime
- `virt-manager`: desktop application for managing virtual machines
- `libvirt`: api for controlling virtualization engines

## Crypto

- `ledger-udev` (aur): udev rules to connect a ledger wallet
- `ledger-live-bin` (aur): ledger hardware wallet gui


## Notes

### Polkit

Polkit is required by `virt-manager` if the user is not in the `libvirt` group.

1. start `virt-manager`
2. start polkit agent: `pkttyagent --process $(pgrep virt-manager)`

### Gnome Keyring

Some applications (e.g. element, proton-agent, etc) stores user credentials
using the Gnome keyring.

By default, the keyring prompts for password as soon as an application using it
requires unlocking the keyring.

We can unlock the keyring on login using the same login credentials.
Refer to the `3.1 PAM step` in the Arch Linux GNOME keyring
[docs](https://wiki.archlinux.org/title/GNOME/Keyring).
