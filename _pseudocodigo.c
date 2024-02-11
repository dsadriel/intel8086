// T Intel

void main(){
	

	char* inputFName = iConsole ? iConsole : "a.in";
	char* outputFName = oConsole ? oConsole : "a.out";
	int tension = vConsole ? atoi(vConsole) : 127;
	
	/*	Opcao [-i] sem parametro
		Opcao [-o] sem parametro
		Opcao [-v] sem parametro
		Parametro da opção [-v] deve ser 127 ou 220*/
		
	
	FILE* f = fopen(inputFName, "r");
	char* currentLine;
	int totalTime = 0;
	int tensionQuality = 0;
	int noTension = 0;
	int errorCount = 0;
	
	/*	2) Ler e interpretar as informações do arquivo de dados de entrada.
			i) Caso o arquivo de dados de entrada tenha linhas inválidas, seu programa deve
			informar na tela o número de TODAS as linhas onde foi identificado o erro e o
			conteúdo correspondente. Então, o programa deve encerrar.*/
	while((currentLine = readLine()) != EOF 
			|| strcmp_(toLower(currentLine), "fim") == 0){
		totalTime++;
		
		//3) Processar os dados do arquivo de dados.
		//Extracts the tension values from the string
		getValuesFromString(currentLine, &t1, &t2, &t3);
		if(t1 = -1 || t2 = -1 || t3 = -1){
			errorCount++
			printf("Linha %d inválido: %s", totalTime, currentLine)
		};
		
		// Checks if the tension is bellow the minimum 
		if(t1 + t2 + t3 < 30)
			noTension++;
		
		// Checks if the tension is in the proper range
		if(|t1 - tension| < 10 && |t2 - tension| < 10 &&  |t3 - tension| < 10)
			tensionQuality++;
		
	}
	
	fclose(f);
	
	if(errorCount != 0)
		return;
	
	//4) Gerar relatório de informações na tela.

	// Prints the result to the screen
	printResult(NULL);
	/*"Arquivo de entrada: %s\n"
	"Arquivo de saida: %s\n"
	"Valor da Tensão: %d\n"
	"Tempo total de medições: (hh:mm)|(mm:ss)"*/
	
	//5) Gerar arquivo de relatório.
			
	f = fopen(outputFName, "w");

	printResult(f);	
	// Prints the result to the file
	/*"Arquivo de entrada: %s\n"
	"Arquivo de saida: %s\n"
	"Valor da Tensão: %d\n"
	"Tempo total de medições: (hh:mm)|(mm:ss)"
	"Qualidade da tensão: (hh:mm)|(mm:ss)"
	"Sem tensão: (hh:mm)|(mm:ss)",*/

	fclose(f);
	
	//6) Encerrar seu programa.
	// Ends the program
	return;
}


void formatTime(int t:AX){
	if(t <= 60)
		return t;
	if(t > 3600)
		t /= 60;
	
	int l = t/60;
	int r = t%60;
	
	return //l:r
}

void toLower(char *c:AX){
	while(*c != '\0'){
		if(*c >= 'a' && *c <= 'z')
			*c = *c - 32;
	}
}

int:BX strcmp_(char *a:AX, char *b:AX){
	BX = 0;
	
	while(*b != '\0'){
		BX -= *b;
		b++;
	}
	
	while(*a != '\0'){
		BX += *b;
		a++;
	}
	
	//return BX
}

void parseLine(char *l:bx){
	
	// Busca o primeiro valor
	while(*l < '0'){
		if(*l = ','){
			error = 1;
			return;
		}
		l++;
	}

	stringBuffer2 = l;

}