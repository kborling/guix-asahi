(define-module (gnu system images asahi64)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix build-system gnu)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu image)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages nano)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages bootloaders)
  #:use-module (gnu packages package-management)
  #:use-module (guix platforms arm)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services networking)
  #:use-module (gnu system)
  #:use-module (gnu system install)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system image)
  #:use-module (srfi srfi-26)
  #:export (asahi64-barebones-os
            asahi64-image-type
            asahi64-barebones-raw-image))

(define-public asahi-linux
  (package
   (inherit linux-libre-arm64-generic)
   (name "asahi-linux")
   (version "asahi-6.1-2")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/AsahiLinux/linux/archive/refs/tags/"
                  version ".tar.gz"))
            (sha256
             (base32
              "03n6l5grlxmkl3nznhz14846pqpq9z9ql1d1011192fx2d55c253"))))
   (license gpl2)
   (home-page "https://github.com/AsahiLinux/kernel")
   (synopsis "The Asahi Linux kernel")
   (description "The Asahi Linux kernel is a Linux kernel distribution based on the upstream Linux kernel, with additional patches and modifications for better support on certain devices.")))

;; (define-public u-boot-asahi64
;;   (make-u-boot-package "asahi64" "aarch64-linux"))

(define-public u-boot-asahi
  (let ((base (make-u-boot-package "asahi64" "aarch64-linux-gnu")))
    (package
     (inherit base)
     (name "u-boot-asahi")
     (version "asahi-v2022.10-1")
     (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/AsahiLinux/u-boot/archive/refs/tags/"
                                  version ".tar.gz"))
              (sha256 (base32
                       "02x90h89p1kv3d29mdhq22a88m68w4m1cwb45gj0rr85i2z8mqjq"))))
     (license gpl2)
     (build-system gnu-build-system)
     (arguments
      `(#:make-flags (list (string-append "CROSS_COMPILE="
                                          (assoc-ref %build-inputs "gcc")
                                          "/bin/aarch64-linux-gnu-"))
                     #:phases
                     (modify-phases %standard-phases
                                    (delete 'configure)
                                    (add-before 'build 'unpack-sources
                                                (lambda _
                                                  (chdir "u-boot-" version)
                                                  (system* "./bootstrap")))
                                    (add-before 'build 'patch-sources
                                                (lambda _
                                                  (substitute* "include/configs/asahi.h"
                                                               (("#define CONFIG_SYS_MMC_ENV_DEV 0")
                                                                "#define CONFIG_SYS_MMC_ENV_DEV 1")))))))
     (inputs
      `(("gcc" ,gcc-aarch64-linux-gnu)
        ("ncurses" ,ncurses)))
     (home-page "https://www.denx.de/wiki/U-Boot")
     (synopsis "Bootloader for Asahi Linux")
     (description "u-boot is a bootloader for embedded systems. This package is a custom version of u-boot specifically built for Asahi Linux."))))

  (define asahi64-barebones-os
    (operating-system
     ;; (inherit installation-os)
     (host-name "asahi")
     (timezone "America/New_York")
     (locale "en_US.utf8")

     (kernel asahi-linux)
     (initrd-modules '())
     ;; TODO: Add firmware
     ;; (bootloader (bootloader-configuration
     ;;              (bootloader grub-efi-bootloader)
     ;;              (targets '("/boot/efi"))
     ;;              (terminal-outputs '(console))))
     (bootloader (bootloader-configuration
                  (bootloader u-boot-asahi)
                  (targets '("/dev/sda"))))
     (file-systems (cons (file-system
                          (device (file-system-label "my-root"))
                          (mount-point "/")
                          (type "ext4"))
                         %base-file-systems))

     ;; (services
     ;;  (cons*
     ;;   (operating-system-user-services installation-os)))
     (services (cons*
                (service agetty-service-type
                         (agetty-configuration
                          (extra-options '("-L")) ; no carrier detect
                          (baud-rate "115200")
                          (term "vt100")
                          (tty "ttyS0")))
                (service dhcp-client-service-type)
                (service ntp-service-type)
                %base-services))
     (packages
      (append (list git curl nano emacs nss-certs)
              %base-packages))))
  ;; (operating-system-packages installation-os)))))

  (define asahi64-image-type
    (image-type
     (name 'asahi64-raw)
     (constructor (lambda (os)
                    (image
                     (inherit (raw-with-offset-disk-image))
                     (operating-system os)
                     (platform aarch64-linux))))))

  (define asahi64-barebones-raw-image
    (image
     (inherit
      (os+platform->image asahi64-barebones-os aarch64-linux
                          #:type asahi64-image-type))
     (name 'asahi64-barebones-raw-image)))

  ;; Return the default image.
  asahi64-barebones-raw-image
