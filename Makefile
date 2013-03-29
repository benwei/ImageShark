
all:
	ibtool --export-strings-file file.strings ImageShark/en.lproj/MainMenu.xib

clean:
	rm -f file.strings
