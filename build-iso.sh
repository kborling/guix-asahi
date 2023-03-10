#!/bin/sh

# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

die() {
    # **
    # Prints a message to stderr & exits script with non-successful code "1"
    # *

    printf '%s\n' "$@" >&2
    exit 1
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

# Build the image
printf 'Attempting to build the image...\n\n'
image=$(guix system image -t iso9660 --target=aarch64-linux-gnu --system=aarch64-linux './asahi64.scm') \
    || die 'Could not create image.'

release_tag=$(date +"%Y%m%d%H%M")
cp "${image}" "./asahi-guix-installer-${release_tag}.iso" ||
    die 'An error occurred while copying.'

printf 'Image was succesfully built: %s\n' "${image}"

# cleanup
unset -f die
unset -v image release_tag
