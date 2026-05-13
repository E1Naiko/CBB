{
	1. Se cuenta con un archivo que almacena información sobre especies
	de plantas originarias de Europa, de cada especie se almacena:
	código especie, nombre vulgar, nombre científico, altura promedio,
	descripción y zona geográfica. El archivo no está ordenado por
	ningún criterio. Realice un programa que elimine especies de
	plantas trepadoras. Para ello se recibe por teclado los códigos
	de especies a eliminar.
	
	a. Implemente una alternativa para borrar especies, que
	inicialmente marque los registros a borrar y posteriormente
	compacte el archivo, creando un nuevo archivo sin
	los registros eliminados.

	b. Implemente otra alternativa donde para quitar los registros se
	deberá copiar el último registro del archivo en la posición del
	registro a borrar y luego eliminar del archivo el último registro
	de forma tal de evitar registros duplicados.

	Nota: Las bajas deben finalizar al recibir el código 100000
}
{
Type
	persona= record
		ape:st20;
		nom:st20;
		fecNac:longint;
	end;
	archivo = file of persona;
Procedure BajaFisica(var a:archivo; apellido,nombre: String);
	Var
		posBorrar:integer;
		rp,aux: per;
		apellido, nombre: st20;
	begin
		reset(a);
		readln(apellido);
		readln(nombre);
		rp.ape= ‘zzz’;
		rp.nom=‘zzz’;		
		while (not eof(a) and ((rp.ape <> apellido) and (rp.nom <> nombre))) do
			read(a,rp);
		if(rp.ape = apellido) and (rp.nom=nombre)then begin
			posBorrar:= filepos(a)-1;
			seek(a,filesize(a)-1);		
			read(a,aux);
			seek(a, posBorrar);		
			write(a,aux);
			seek(a,filesize(a)-1);
			truncate(a);
		end,
		close(a);
	end;
}
{
Type
	persona= record
		ape:st20;
		nom:st20;
		fecNac:longint;
	end;
	archivo=file of persona;
	
Procedure BajaLogica(var a: archivo; apellido,nombre: String);
	Var
		posBorrar:integer;
		rp:persona;
		apellido, nombre: st20;
	begin
		reset(a);
		readln(apellido); readln(nombre);
		rp.ape= ‘zzz’; rp.nom=‘zzz’;
		while (not eof(a) and ((rp.ape <> apellido) and (rp.nom<>nombre))) do
			read(a,rp);
		If(rp.ape = apellido) and (rp.nom=nombre)then begin
			posBorrar:=filepos(a)-1;
			rp.ape=“@”
			seek(a, posBorrar);
			write(a,rp);
		end;
		close(a);
	end;
}

program tp3ej1;
const
	FIN= 10000;
	BORRAR= -420;
	
type
	tipoEspecie = record
		cod: integer;
		nomVulgar: String[50];
		nomCientifico: String[50];
		altPromedio: real;
		desc: String[50];
		zona: String[50];
	end;
	
	archEspecie = file of tipoEspecie;
	
procedure BajaLogica(var a: archEspecie; cod: integer);
	var
		posBorrar: integer;
		rp: tipoEspecie;
		
	begin
		reset(a);
		rp.cod:= cod;
		while (not eof(a)) and (rp.cod <> cod) do
			read(a, rp);
		if (rp.cod = cod) then begin
			posBorrar:= filepos(a)-1;
			rp.cod:= BORRAR;
			seek(a, posBorrar);
			write(a,rp);
		end;
		close(a);
	end;
	
procedure alternativaA(var a, nue: archEspecie);
	var
		act:tipoEspecie;
	begin
		reset(a);
		rewrite(nue);
		while (not eof(a)) do begin
			read(a, act);
			if (act.cod<>BORRAR) then
				write(nue, act);
		end;
		close(a);
		close(nue);
	end;
	
procedure alternativaB(var a: archEspecie; cod: integer); // baja fisica de 1 unico recorrido
	var
		posBorrar, borrados: integer;
		rp, aux: tipoEspecie;
	begin
		reset(a);
		borrados:= 0;
		rp.cod:= -999;
		while(not eof(a)) do begin
			while(not eof(a)) and (rp.cod <> cod) do
				read(a,rp);
			if (rp.cod = BORRAR) then begin
				borrados:= borrados + 1;
				posBorrar:= filepos(a)-1;
				seek(a, filesize(a)-borrados-1);
				read(a, aux);
				seek(a, posBorrar);
				write(a,aux);
				seek(a, filesize(a)-1);
			end;
			rp.cod:= -999;
		end;
		seek(a, filesize-borrados);
		truncate(a);
		close(a);
	end;
var
	codAct: integer;
	especies: archEspecie;
BEGIN
	assign(especies, 'especies.dat');
	assign(especies, 'especies2.dat');
	
	writeln('Ingrese un codigo:');
	readln(codAct);
	while (codAct <> FIN) do begin
		BajaLogica(especies, codAct);
		writeln('Ingrese otro codigo o ', FIN, ' para terminar:');
		readln(codAct);
	end;
	alternativaA(especies, nue);
	alternativaB(especies, BORRAR);
END.

