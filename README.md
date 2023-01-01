# GUIX System on Apple Silicon
Experiment to have Guix System run on Apple Silicon hardware with the help of Asahi Linux kernel.

# Roadmap
- [x] Create package for Asahi Linux kernel.
- [x] Create package that contains base OS installer.
- [x] Add script to generate `.iso` files from installer.
- [ ] Create u-boot bootloader package that builds https://github.com/AsahiLinux/u-boot
- [ ] Add necessary firmware, packages, and configurations.
- [ ] Generate `.iso` containing Base OS + Asahi Linux kernel.
- [ ] Install `.iso` after installing Asahi: 'UEFI environment only (m1n1 + U-Boot + ESP)'.

# References
- https://github.com/AsahiLinux/linux

# Attributions
- https://github.com/SystemCrafters/guix-installer (Using build-iso.sh script to create `.iso' files)
