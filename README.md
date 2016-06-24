## ctr-elf
#### Creates an ELF from a 3DS executable EXEFS

Run `ctrtool --contents=contents app{.cia, .ncch}`.
Then run `ctr-elf.sh` on the desired contents file.

`ctr-elf.sh`: extract exefs from file and convert to elf.
Simply run `ctr-elf.sh [path-to-file]`.

`exefs2elf.py`: convert exefs to elf file.
Place the program's exheader (`exh.bin`) and exefs folder (`exefs/`) inside `workdir/` and run.

#### Forked from [44670's patchrom](https://github.com/44670/patchrom)

Bugfixes by nedwill. At some point I'll make this much nicer, but I have
more pressing things to do atm.
