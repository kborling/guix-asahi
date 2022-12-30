(define-module (gnu system images asahi64)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix build-system gnu)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu image)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages nano)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages linux)
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

(define asahi64-barebones-os
  (operating-system
   (inherit installation-os)
   (kernel asahi-linux)
   (services
    (cons*
     (operating-system-user-services installation-os)))
   (packages
    (append (list git curl nano emacs)
            (operating-system-packages installation-os)))))

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
