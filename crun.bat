rem script to ASSEMBLE, LINK, and execute the program
rem USAGE: crun <programName>
rem Do not include the file extension, e.g.: if the file is named trabalho.asm use 'crun trabalho'
rescan
masm /Zi %1.asm,%1.obj,%1.lst,%1.crf;
link /CO %1.obj,,,,;
%1.exe