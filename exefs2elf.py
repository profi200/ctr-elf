# convert exefs to elf
import sys
import os
import struct
from subprocess import call
from tempfile import mkdtemp
from shutil import rmtree
from functools import partial

CTRTOOL = "./ctrtool"
CC = "arm-none-eabi-gcc"
CP = "arm-none-eabi-g++"
OC = "arm-none-eabi-objcopy"
LD = "arm-none-eabi-ld"

#ctrtool --contents=contents whatever.cia

#ctrtool -p --exefs=exefs.bin contents.0000.00000000
#ctrtool -t exefs --exefsdir=exefs --decompresscode exefs.bin

#ctrtool -p --romfs=romfs.bin contents.0000.00000000
#ctrtool -t romfs --romfsdir=romfs romfs.bin

def get_current_dir():
	return os.path.dirname(os.path.realpath(__file__))

def write_file(path, s):
	with open(path, "wb") as f:
		f.write(s)

def read_file(path):
	with open(path, "rb") as f:
		return f.read()

def page_align(address):
	return ((address + (0x1000 - 1)) / 0x1000) * 0x1000

def doit(tempdir, fn):
	exefs  = os.path.join(tempdir, 'exefs')
	exhbin = os.path.join(tempdir, 'exh.bin')
	e2elf  = os.path.join(tempdir, 'e2elf.ld')
	code   = os.path.join(exefs, 'code.bin')

	final_name = os.path.basename(fn)
	if '.' in final_name:
		final_name = final_name.split('.')[-1]
	final_name += ".elf"
	final = os.path.join(get_current_dir(), final_name)

	call([CTRTOOL, "-x", "--exefsdir=" + exefs, fn])
	call([CTRTOOL, "-x", "--exheader=" + exhbin, fn])

	with open(exhbin, "rb") as f:
		exh = f.read(64)

	# exheader:
	#   0x10: .text CSI
	#   0x20: .ro CSI
	#   0x30: .data CSI
	#   0x3c: .bss size
	# CSI:
	#   0x00: addr
	#   0x04: physical region size in pages
	#   0x08: section size in bytes
	(textBase, textSize, roSize, rwSize, bssSize) = struct.unpack('16x I4xI4x 4x4xI4x 4x4xII', exh)
	#bssSize = page_align(bssSize)

	print("textBase: {:08x}".format(textBase))
	print("textSize: {:08x}".format(textSize))
	print("roSize:   {:08x}".format(roSize))
	print("rwSize:   {:08x}".format(rwSize))
	print("bssSize:  {:08x}".format(bssSize))

	if (textBase != 0x100000):
		print('WARNING: textBase mismatch, might be an encrypted exheader file.')

	with open(code, "rb") as f:
		text = f.read(textSize)
		ro = f.read(roSize)
		rw = f.read(rwSize)

	with open('e2elf.ld', 'r') as f:
		ldscript = f.read()

	ldscript = ldscript.replace('%memorigin%', str(textBase))
	ldscript = ldscript.replace('%bsssize%', str(bssSize))
	write_file(e2elf, ldscript)

	write_file(os.path.join(exefs, 'text.bin'), text)
	write_file(os.path.join(exefs, 'ro.bin'), ro)
	write_file(os.path.join(exefs, 'rw.bin'), rw)

	objfiles = []
	for desc, sec_name in (('text', 'text'), ('ro', 'rodata'), ('rw', 'data')):
		call([OC, "-I", "binary", "-O", "elf32-littlearm", "--rename-section",
				  ".data=."+sec_name,
					os.path.join(exefs, desc+".bin"),
					os.path.join(exefs, desc+".o")])
		objfiles.append(os.path.join(exefs, desc + ".o"))

	call([LD, '--accept-unknown-input-arch', '-T', e2elf, '-o', final] + objfiles)

def main():
	if len(sys.argv) != 2:
		print("Usage: {} [input file]".format(sys.argv[0]))
		exit()

	fn = sys.argv[1]

	tempdir = mkdtemp()
	if not tempdir:
		print("[-] Failed to make temporary directory.")
		exit()

	doit(tempdir, fn)
	rmtree(tempdir)

if __name__ == '__main__':
	main()
