# Intel Leak Checker

This spaghetti script checks if the trust of your computer's BIOS image is
affected by the [recent Intel
leak](https://hardenedvault.net/blog/2022-10-08-alderlake_fw-leak/).

It simply searches if the ROM image contains any of the keys leaked.
Since the respective private keys are part of the leak, anyone with those
keys could forge cryptographically valid BIOS images and your platform will
happily accept them.

**Warning:** I assume you know what you're doing.

**Warning 2**: The script was tested mainly on MacOS, in order for the script to work on Linux, make sure to have **`xxd` version 2022-01-14 (coming with [vim 8.2.4088](https://github.com/vim/vim/commit/c0a1d370fa655cea9eaa74f5e605b95825dc9de1)) or newer**, [see more details why here.](https://unix.stackexchange.com/a/706374/287583)

## Standalone Usage

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

## FwHunt Scanner

I created a FwHunt rule to perform the same check, so if you're a FwHunt user, you
can go that way:

1. Add [this rule](https://github.com/phretor/FwHunt/blob/main/rules/SupplyChain/IntelAlderLakeLeak.yml) to
   your FwHunt ruleset.

2. Run the `scan` command:

```shell
$ python fwhunt_scan_analyzer.py scan -r ../FwHunt/rules/Threats/IntelAlderLakeLeak.yml rom.bin
Scanner result IntelAlderLakeLeak (variant: default) FwHunt rule has been triggered and threat detected! (rom.bin)
```

If you're affected, you'll see the message above. Else, a reassuring, green message will appear.

## How to Generate the Patterens from Private Keys

Export the public key in modulus-exponent format (in hex string) and reverse it.

```bash
$ openssl rsa -modulus -noout -in privkey.pem | \
    awk -F= '{print $2}' | \
    python -c \
    'import sys; s = sys.stdin.read().strip().lower(); a = [s[i:i+2] for i in range(0, len(s), 2)]; a.reverse(); print("".join(a));'

```

## Credits & Thanks
- [Yegor Vasilenko](https://twitter.com/yeggorv) for [this](https://github.com/binarly-io/FwHunt/pull/7)

