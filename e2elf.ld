OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
OUTPUT_ARCH(arm)

MEMORY
{
    memregion : ORIGIN = %memorigin%, LENGTH = 100000K
}

__memregion_start = ORIGIN(memregion);
__memregion_top = ORIGIN(memregion) + LENGTH(memregion);

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
        /*. = ALIGN(4);   REQUIRED. LD is flaky without it. */
    } >memregion :text

    .plt :
    {
        *(.plt)
    } >memregion = 0xff

    .text : ALIGN (4)
    {

        *(.text*)
        *(.stub)
        /* .gnu.warning sections are handled specially by elf32.em.  */
        *(.gnu.warning)
        *(.gnu.linkonce.t*)
        *(.glue_7)
        *(.glue_7t)
    } >memregion

    __text_end = .;

    .rodata :
    {
        *(.rodata)
        *all.rodata*(*)
        *(.roda)
        *(.rodata.*)
        *(.gnu.linkonce.r*)
        SORT(CONSTRUCTORS)
    } >memregion :rodata

    .ARM.extab : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >memregion
    __exidx_start = .;
    .ARM.exidx : { *(.ARM.exidx* .gnu.linkonce.armexidx.*) } >memregion
    __exidx_end = .;

/* Ensure the __preinit_array_start label is properly aligned.  We
   could instead move the label definition inside the section, but
   the linker would then create the section even if it turns out to
   be empty, which isn't pretty. */
    . = ALIGN(32 / 8);
    PROVIDE (__preinit_array_start = .);
    .preinit_array : { KEEP (*(.preinit_array)) } >memregion : data
    PROVIDE (__preinit_array_end = .);
    PROVIDE (__init_array_start = .);
    .init_array : { KEEP (*(.init_array)) } >memregion : data
    PROVIDE (__init_array_end = .);

    .data ALIGN(4) :
    {
        __data_start = ABSOLUTE(.);
        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d*)
        CONSTRUCTORS
        __data_end = ABSOLUTE(.);
    } >memregion : data

    .bss ALIGN(4) :
    {
        . = . + %bsssize%;
    } >memregion : bss

    __bss_end = .;
    __bss_end__ = .;

    _end = .;
    __end__ = .;
    PROVIDE (end = _end);

    /* Stabs debugging sections.  */
    .stab 0 : { *(.stab) }
    .stabstr 0 : { *(.stabstr) }
    .stab.excl 0 : { *(.stab.excl) }
    .stab.exclstr 0 : { *(.stab.exclstr) }
    .stab.index 0 : { *(.stab.index) }
    .stab.indexstr 0 : { *(.stab.indexstr) }
    .comment 0 : { *(.comment) }

    /*  DWARF debug sections.
        Symbols in the DWARF debugging sections are relative to the beginning
        of the section so we begin them at 0.  */
    /* DWARF 1 */
    .debug          0 : { *(.debug) }
    .line           0 : { *(.line) }
    /* GNU DWARF 1 extensions */
    .debug_srcinfo  0 : { *(.debug_srcinfo) }
    .debug_sfnames  0 : { *(.debug_sfnames) }
    /* DWARF 1.1 and DWARF 2 */
    .debug_aranges  0 : { *(.debug_aranges) }
    .debug_pubnames 0 : { *(.debug_pubnames) }
    /* DWARF 2 */
    .debug_info     0 : { *(.debug_info) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_macinfo  0 : { *(.debug_macinfo) }
    /* SGI/MIPS DWARF 2 extensions */
    .debug_weaknames 0 : { *(.debug_weaknames) }
    .debug_funcnames 0 : { *(.debug_funcnames) }
    .debug_typenames 0 : { *(.debug_typenames) }
    .debug_varnames  0 : { *(.debug_varnames) }

    .stack 0x80000 : { _stack = .; *(.stack) }
    /* These must appear regardless of  .  */
}
