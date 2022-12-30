;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2020 Mathieu Othacehe <m.othacehe@gmail.com>
;;; Copyright © 2022 Gabriel Wicki <gabriel@erlikon.ch>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu system images asahi64)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages certs)
  #:use-module (guix platforms arm)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services networking)
  #:use-module (gnu system)
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
   (host-name "asahi")
   (timezone "America/New_York")
   (locale "en_US.utf8")
   (bootloader (bootloader-configuration
                (bootloader u-boot-asahi64-lts-bootloader)
                (targets '("/dev/vda"))))
   (initrd-modules '())
   (kernel asahi-linux)
   (file-systems (cons (file-system
                        (device (file-system-label "root"))
                        (mount-point "/")
                        (type "ext4"))
                       %base-file-systems))
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
   (packages (cons nss-certs %base-packages))))

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
