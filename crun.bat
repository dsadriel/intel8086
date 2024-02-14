rem script para MONTAR, LIGAR e executar o programa
rem USO: crun <nomeDoPrograma>
rem Não inclua a extensão do arquivo, ex.: se o arquivo se chama trabalho.asm use 'crun trabalho'
rescan
masm /Zi %1.asm,%1.obj,%1.lst,%1.crf;
link /CO %1.obj,,,,;
%1.exe