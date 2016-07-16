OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
OUTPUT_ARCH(arm)

MEMORY
{
    textregion : ORIGIN = %textbase%, LENGTH = %textlength%
    roregion : ORIGIN = %robase%, LENGTH = %rolength%
    rwregion : ORIGIN = %rwbase%, LENGTH = %rwlength%
}

PHDRS
{
    text PT_LOAD FLAGS(5);
    rodata PT_LOAD FLAGS(4);
    data PT_LOAD FLAGS(6);
    bss PT_LOAD;
}

SECTIONS
{
    .init : ALIGN(4)
    {
        __text_start = .;
        KEEP (*(.init))
    } >textregion :text

    .text : ALIGN (4)
    {

        *(.text*)
        *(.stub)
        *(.gnu.warning)
        *(.gnu.linkonce.t*)
        *(.glue_7)
        *(.glue_7t)
    } >textregion

    __text_end = .;

    .rodata :
    {
        *(.rodata)
        *all.rodata*(*)
        *(.roda)
        *(.rodata.*)
        *(.gnu.linkonce.r*)
        SORT(CONSTRUCTORS)
    } >roregion :rodata

    .data :
    {
        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d*)
    } >rwregion :data

    .bss :
    {
        . = . + %bsssize%;
    } >rwregion :bss

    __bss_end = .;
    __bss_end__ = .;

    _end = .;
    __end__ = .;
    PROVIDE (end = _end);

    .stack 0x80000 : { _stack = .; *(.stack) }
}
