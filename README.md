# Intel Leak Checker

This spaghetti script checks if the trust of your computer's BIOS image is
affected by the [recent Intel
leak](https://hardenedvault.net/blog/2022-10-08-alderlake_fw-leak/).

It simply searches if the ROM image contains any of the keys leaked.
Since the respective private keys are part of the leak, anyone with those
keys could forge cryptographically valid BIOS images and your platform will
happily accept them.

**Warning:** I assume you know what you're doing.

## Usage

1. first, you need to extract the BIOS/UEFI ROM image from the SPI flash, which
   can be done with [Chipsec](https://chipsec.github.io) or other tools

```shell
$ sudo python chipsec_util.py spi dump rom.bin
...
$ ls rom.bin
rom.bin
```

2. next, you use the script included in this repository to search for the
   public keys that I pre-generated from the private ones.

```shell
$ ./checker.sh unaffected-rom.bin

No keys found: you may not be affected

$ ./checker.sh affected-rom.bin

Keys found: you're likely affected.

```

## For the curious

I generated the `keys/pubkeys.rsa` file as follows:

```shell
$ find path/to/leaked/code -type f -iname '*.pem' -exec file {} \; | \
    grep -i private | grep -vi public | grep -v Python | awk -F\: '{ print $1 }' | \
    while read f; \
        do openssl rsa -in "$f" -outform DER 2>/dev/null | \
            xxd -ps -c 0 | \
            tee -a pubkeys/keys.rsa ; \
        done
```
