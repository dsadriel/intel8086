

|**UNIVERSIDADE FEDERAL DO RIO GRANDE DO SUL INSTITUTO DE INFORMÁTICA – INFORMÁTICA APLICADA INF01108 - Arquitetura e Organização de Computadores I – 2023/2**|
| :-: |

<div style="text-align:center">
Trabalho de Programação – Processador RAMSES</div>


# Geral

Você deverá desenvolver um programa para ser executado no ambiente DOSBOX, capaz de ler um arquivo que tem medições de tensão (voltagem) efetuadas nos 3 (três) fios que levam energia elétrica para uma empresa. Cada um destes fios transmite uma das fases de tensão fornecidas pela concessionária de energia.

Seu programa deverá processar os dados fornecidos no arquivo com as tensões elétricas das três fases e gerar um relatório sobre os valores lidos.

# Chamada do Programa

Para solicitar a execução de seu programa, o usuário deverá fornecer, junto com o nome do programa, na linha de comando, alguns parâmetros que serão usados para determinar a sua forma de operação.

Supondo que seu programa tenha o nome de “prog”, em exemplo de linha de comando é a seguinte:

```
prog -i FILE_IN -o FILE_OUT -v TENSAO
```
Os parâmetros que aparecem na linha de comando são os seguintes:

- “-i”, seguido do nome do arquivo de dados com as medições de tensão (representado por FILE_IN no exemplo). Se esse parâmetro não existir na linha de comando, o  programa deve usar “a.in” com o nome do arquivo de dados;
- “-o”, seguido do nome do arquivo de relatório a ser gerado pelo programa (representado por FILE_OUT no exemplo). Se esse parâmetro não existir na linha de comando, o programa deve usar “a.out” como o nome do arquivo de relatório;
- “-v”, seguido de um valor de tensão, que pode ser “127” ou “220” (representado por TENSAO no exemplo). Se esse parâmetro não existir na linha de comando, o programa deve usar o valor “127” como a tensão.

Observar que os parâmetros “-i”, “-o” e “-v”, seguidos dos correspondentes parâmetros, podem aparecer em qualquer ordem na linha de comando.

# Formato dos dados no arquivo de dados

As informações no arquivo de dados estão organizadas em linhas de texto onde cada linha contém as informações medidas nas fases da tensão elétrica. O tempo entre uma destas medições (representada por uma linha) é 1 segundo. Portanto, a primeira linha corresponde ao tempo “0” (zero), a segunda ao tempo “1”, a terceira ao tempo “2”, e assim por diante.

O final das linhas de texto pode ser identificado por um caractere 00DH (Carriage Return), ou um caractere 00AH (Line Feed), ou ainda por um par de caracteres 00DH 00AH, seguidos, em qualquer ordem.

O contador de linhas do arquivo de dados deve ser incrementado sempre que for encontrado um caractere 00AH.

O final das linhas de medições pode ser identificado por uma das seguintes situações: 

- Uma linha com a palavra “fim” (insensível ao caso);
- O final do arquivo propriamente dito.

As linhas que contém medidas são formadas por três números inteiros separados por vírgula.

Pode haver espaços em branco ou TABs no meio das informações das linhas, exceto no meio dos números.

Os números representam valores de tensão elétrica, e são válidos apenas valores entre “0” e “499”.

Por exemplo, as três linhas abaixo são válidas. Veja os espaços em torno do valor 119 e TAB antes do 123.

```
120,130,
121, 119 , 125
123, 124, 128
```
Caso a informação em uma das linhas de texto não esteja em acordo com o especificado acima, esta linha será considerada INVÁLIDA.

# Cálculo do seu programa

Seu programa deve efetuar os seguintes cálculos sobre os dados lidos do arquivo de dados de entrada:

**1) Qualidade da Tensão** : seu programa deve determinar o tempo total que a tensão das fases está adequada. A tensão está adequada quando as três fases estiverem com os seguintes valores:

- Se a tensão selecionada na linha de comando for 127, a tensão estará adequada quando estiver entre 117 e 137, inclusive estes valores;
- Se a tensão selecionada na linha de comando for 220, a tensão estará adequada quando estiver entre 210 e 230, inclusive estes valores.

**2) Sem tensão** : seu programa deve determinar o tempo total que não há tensão. Considera-se que não há tensão quando as três fases estiverem abaixo de 10.

# O que seu programa deve fazer?

Seu programa deve seguir o seguinte algoritmo:

1) Ler e interpretar as informações da linha de comando.
i) Caso a linha de comando tenha informações inválidas, seu programa deve informar o erro e encerrar.
2) Ler e interpretar as informações do arquivo de dados de entrada.
i) Caso o arquivo de dados de entrada tenha linhas inválidas, seu programa deve informar na tela o número de TODAS as linhas onde foi identificado o erro e o conteúdo correspondente. Então, o programa deve encerrar.
3) Processar os dados do arquivo de dados.
4) Gerar relatório de informações na tela.
5) Gerar arquivo de relatório.
6) Encerrar seu programa.

Mensagens de erros a serem usadas nas várias situações indicadas:

Opcao [-i] sem parametro

Opcao [-o] sem parametro

Opcao [-v] sem parametro

Parametro da opção [-v] deve ser 127 ou 220

Linha < _número da linha_ > inválido: < _conteúdo da linha_ >

# Relatório na tela

Quando não houver erros na linha de comandos e no arquivo de dados de entrada, seu programa deve colocar na tela as seguintes informações:

- Informações consideradas para cada um dos parâmetros da linha de comando;
- Tempo total de medições (número de linhas). Lembrar que cada medição (cada linha do arquivo de dados de entrada) corresponde a 1 segundo.

Caso o número de segundos seja maior ou igual a 60, você deverá informar os minutos e segundos separados por “:”. Caso o número de segundos seja maior do que 3600, você deverá informar as horas, minutos e segundos, separadas por “:”

# Relatório no arquivo de saída

Quando não houver erros na linha de comandos e no arquivo de dados de entrada, seu programa deve colocar no arquivo de relatório de saída as seguintes informações:


- Informações consideradas para cada um dos parâmetros da linha de comando;
- Tempo total de medições, lembrando que cada medição (cada linha do arquivo de  dados de entrada) corresponde a 1 segundo.
- Tempo obtido para o valor calculado da “Qualidade da Tensão” (ver Cálculo do seu programa)
- Tempo obtido para o valor calculado de “Sem Tensão” (ver Cálculo do seu programa)

Caso o número de segundos seja maior ou igual a 60, você deverá informar os minutos e segundos separados por “:”. Caso o número de segundos seja maior do que 3600, você deverá informar as horas, minutos e segundos, separadas por “:”

# Entregáveis: o que deve ser entregue?

Deverá ser entregue, via Moodle da disciplina, APENAS o arquivo fonte de sua implementação da especificação apresentada, escrito na linguagem simbólica de montagem dos processadores 8086 da Intel (arquivo .ASM). Além disso, esse programa fonte deverá conter comentários descritivos da implementação.

Para a correção, o programa será montado usando o montador MASM 6.11 no ambiente DosBox 0.74 e executado com diferentes arquivos da dados de entrada e linhas de comando.

A nota final do trabalho será proporcional às funcionalidades que forem atendidas pelo programa.

O trabalho deverá ser entregue até a data prevista, conforme programado no MOODLE. Não será aceita a entrega de trabalhos após a data estabelecida.

# Observações

Recomenda-se a troca de ideias entre os alunos. Entretanto, a identificação de cópias de trabalhos acarretará na aplicação do Código Disciplinar Discente e a tomada das medidas cabíveis para essa situação (tanto o trabalho original quanto os copiados receberão nota zero).

O professor da disciplina reserva-se o direito, caso necessário, de solicitar uma demonstração do programa, onde o aluno será arguido sobre o trabalho como um todo. Nesse caso, a nota final do trabalho levará em consideração o resultado da demonstração.

# Como obter a linha de comando?

O string de texto escrito na “linha de comando” pode ser lido por um programa escrito em assembler. Esse string está no PSP – Program Segment Prefix, que se encontra em um segmento específico da memória. Nesse segmento, o string pode ser encontrado a partir do offset 81H. O final do string é identificado pelo byte CR (0DH).

No offset 80H do PSP pode-se encontrar o tamanho do string digitado na linha de comando, em bytes.

O segmento onde se encontra o PSP está presente nos registradores DS e ES, logo no início da execução do programa.

Entretanto, quando se usa o modo simplificado do MASM (com as diretivas “ponto”), o DS será carregado com o segmento de dados do programa. Assim, a informação do PSP só estará presente no registrador ES.

O trecho de programa abaixo permite copiar o string digitado na linha de comando para um buffer no segmento de dados do programa. Para isso, você deve fazer o seguinte?

1) Colocar o trecho de programa abaixo no “startup” do programa;
2) Criar, no segmento de dados de seu programa, um buffer com o número de bytes que
poderá aparecer na linha de comando. Esse buffer deve ser identificado pelo nome
“CMDLINE”;
3) Observar que, ao terminar a execução do trecho de código abaixo, o registrador AX
terá o tamanho do string copiado para o buffer CMDLINE.

```assembly
push ds ; Salva as informações de segmentos
push es

mov ax,ds ; Troca DS com ES para poder usa o REP MOVSB
mov bx,es
mov ds,bx
mov es,ax

mov si,80h ; Obtém o tamanho do string da linha de comando e coloca em CX
mov ch,
mov cl,[si]
mov ax,cx ; Salva o tamanho do string em AX, para uso futuro

mov si,81h ; Inicializa o ponteiro de origem

lea di,CMDLINE ; Inicializa o ponteiro de destino

rep movsb

pop es ; retorna as informações dos registradores de segmentos
pop ds
```

# Tabela de interrupções do DOS
[Tabela de interrupções](http://bbc.nvg.org/doc/Master%20512%20Technical%20Guide/m512techb_int21.htm)
[Tabela de interrupções](http://www.ctyme.com/intr/int-21.htm)