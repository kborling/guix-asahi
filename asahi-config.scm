(use-modules (guix packages)
             (guix download)
             (guix build-system gnu))

(define-public asahi-linux
  (package
    (name "asahi-linux")
    (version "asahi-6.1-2")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/AsahiLinux/linux/archive/refs/tags/"
                    version ".tar.gz"))
              (sha256
                (base32
                 "a308564a13dd89144200a1058ad34ff8e26b0822e143fbeda0b3769a5fa1c60e"))))
    (license license:gpl2)
    (build-system gnu-build-system)
    (arguments
      `(#:phases
        (modify-phases %standard-phases
          (delete 'configure)
          (add-before 'build 'unpack-sources
            (lambda _
              (chdir version
                (system* "make" "defconfig")))))))
    (native-inputs `(("bash" ,bash)))
    (home-page "https://github.com/AsahiLinux/kernel")
    (synopsis "The Asahi Linux kernel")
    (description "The Asahi Linux kernel is a Linux kernel distribution based on the upstream Linux kernel, with additional patches and modifications for better support on certain devices.")))
