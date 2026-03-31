{
	Se desea actualizar un archivo maestro a partir de 500 archivos
	detalle de votos de localidades.
	
	Cada archivo detalle contiene código de provincia, código
	de localidad, cantidad de votos válidos, cantidad de votos en
	blanco y cantidad de votos anulados. El archivo se encuentra
	ordenado por código de provincia y código de localidad.

		El archivo maestro tiene código de provincia,
	nombre de provincia, cantidad total de votos válidos, cantidad
	total de votos en blanco y cantidad total de votos anulados.
	El archivo se encuentra ordenado por código de provincia.

		Realizar la actualización de archivo maestro con la
	información de los archivos detalles. Además al final se debe
	informar en un archivo de texto denominado
	cantidad_votos_04_07_2023.txt la cantidad de archivos procesados,
	la cantidad total de votos válidos, cantidad total de votos en
	blanco y cantidad total de votos anulados de los archivos
	detalles con el siguiente formato:

	Cantidad de archivos procesados : ___
	Cantidad Total de votos: __
	Cantidad de votos válidos: __
	Cantidad de votos anulados: __
	Cantidad de votos en blanco: __
	Se debe realizar el programa completo con sus declaraciones de tipo.

}


program Adicional;

uses crt;

const
	ValorA = 9999;
	DimL = 500;
	NOM_ARCHIVO_SALIDA = 'cantidad_votos_04_07_2023.txt';

type
	cadenaCorta = String[50];
	tipoDetalle = record
		codProvincia: integer;
		codLocalidad: integer;
		cantVotosValidos: integer;
		cantVotosEnBlanco: integer;
		cantVotosAnulados: integer;
	end;
	
	tipoMaestro = record
		codProvincia: integer;
		nomProvincia: cadenaCorta;
		cantTotalVotosValidos: integer;
		cantTotalVotosEnBlanco: integer;
		cantTotalVotosAnulados: integer;
	end;
	
	archDetalle = File of tipoDetalle;
	archMaestro = File of tipoMaestro;
	arregloTipoDetalle = array[0..DimL] of tipoDetalle;
	arregloArchDetalle = array [0..DimL] of archDetalle;
	
	tipoResultado = record
		cantArchivosProcesados: integer;
		cantTotalVotos:integer;
		cantVotosValidos: integer;
		cantVotosEnBlanco: integer;
		cantVotosAnulados: integer;
	end;
	
// --------------- Modulos ---------------


procedure actualizarRegistroMaestro(var maestro: tipoMaestro; det: tipoDetalle);
	begin
		maestro.cantTotalVotosValidos := maestro.cantTotalVotosValidos + det.cantVotosValidos;
		maestro.cantTotalVotosEnBlanco := maestro.cantTotalVotosEnBlanco + det.cantVotosEnBlanco;
		maestro.cantTotalVotosAnulados := maestro.cantTotalVotosAnulados + det.cantVotosAnulados;
	end;



procedure Leer(var detalle: archDetalle; var act: tipoDetalle);
	begin
		if(not EoF(detalle))then
			read(detalle, act)
		else
			act.codProvincia:=ValorA;
	end;



{procedure minimo(var archDetalles: arregloArchDetalle; var arrResto: arregloTipoDetalle; var min: tipoDetalle);
	var
		i: integer;
		posMin: integer;
	begin
		min := arrResto[1];
		posMin:= 1;
		for i:=1 to DimL do begin
			if (arrResto[i].codLocalidad < min.codLocalidad) then begin
				min:= arrResto[i];
				posMin := i;
			end;
		end;
		leer(archDetalles[posMin], arrResto[posMin]);
	end;}
	
procedure minimo(var archDetalles: arregloArchDetalle; var arrResto: arregloTipoDetalle; var min: tipoDetalle);
	var
		i, posMin: integer;
	begin
		min.codProvincia := ValorA;
		
		for i:=1 to DimL do begin
			if (arrResto[i].codProvincia < min.codProvincia) or
			((arrResto[i].codProvincia = min.codProvincia) and 
				(arrResto[i].codLocalidad < min.codLocalidad)) then
			begin
				min := arrResto[i];
				posMin := i;
			end;
		end;
	
		if (min.codProvincia <> ValorA) then
			leer(archDetalles[posMin], arrResto[posMin]);
	end;


	
procedure ActualizarResultado(var resultado: tipoResultado; act: tipoDetalle);
	begin
		resultado.cantVotosValidos:= resultado.cantVotosValidos + act.cantVotosValidos;
		resultado.cantVotosEnBlanco:= resultado.cantVotosEnBlanco + act.cantVotosEnBlanco;
		resultado.cantVotosAnulados:= resultado.cantVotosAnulados + act.cantVotosAnulados;
		resultado.cantTotalVotos:= resultado.cantTotalVotos + act.cantVotosValidos + act.cantVotosEnBlanco + act.cantVotosAnulados;
	end;



procedure Actualizar(var maestro: archMaestro; var detalles: arregloArchDetalle; var resultado: tipoResultado);
	var
		i: integer;
		min: tipoDetalle;
		actMaestro: tipoMaestro;
		restoDetalles: arregloTipoDetalle;
		
	begin
		resultado.cantArchivosProcesados:= DimL;
		resultado.cantTotalVotos:= 0;
		resultado.cantVotosValidos:= 0;
		resultado.cantVotosEnBlanco:= 0;
		resultado.cantVotosAnulados:= 0;
		
		reset(maestro);
		for i:=1 to DimL do begin
			reset(detalles[i]);
			leer(detalles[i], restoDetalles[i]);
		end;
		minimo(detalles, restoDetalles, min);
		read(maestro, actMaestro);
			
		while (min.codProvincia <> ValorA) do begin
			while (min.codProvincia <> actMaestro.codProvincia) do begin
				read(maestro, actMaestro);
			end;
			
			while(actMaestro.codProvincia = min.codProvincia) do begin
				actualizarResultado(resultado, min);
				actualizarRegistroMaestro(actMaestro, min);
				minimo(detalles, restoDetalles, min);
			end;
			
			seek(maestro, filepos(maestro)-1);
			write(maestro, actMaestro);
		end;
		
		for i:=1 to DimL do
			close(detalles[i]);
		close(maestro);
	end;



procedure exportarATXT(res: tipoResultado);
	var
		archTXT: text;
		aux: string;
	begin
		Assign(archTXT, NOM_ARCHIVO_SALIDA);
		rewrite(archTXT);
		str(res.cantArchivosProcesados, aux);
		writeln(archTXT, ('Cantidad de archivos procesados : ' + aux));
		str(res.cantTotalVotos, aux);
		writeln(archTXT, ('Cantidad Total de votos:  : ' + aux));
		str(res.cantVotosValidos, aux);
		writeln(archTXT, ('Cantidad de votos válidos:  : ' + aux));
		str(res.cantVotosAnulados, aux);
		writeln(archTXT, ('Cantidad de votos anulados:  : ' + aux));
		str(res.cantVotosEnBlanco,aux);
		writeln(archTXT, ('Cantidad de votos en blanco:  : ' + aux));
		
		close(archTXT);
	end;



// --------------- Prog Ppal ---------------
	
var
	i: integer;
	num: cadenaCorta;
	maestro: archMaestro;
	detalles: arregloArchDetalle;
	resultado: tipoResultado;
	
BEGIN
	resultado.cantArchivosProcesados:= 0;
	resultado.cantTotalVotos:= 0;
	resultado.cantVotosValidos:= 0;
	resultado.cantVotosEnBlanco:= 0;
	resultado.cantVotosAnulados:= 0;
		
	Assign(maestro, 'maestro.dat');
	For i:=1 to DimL do begin
		str(i, num);
		Assign(detalles[i], ('detalle' + num + '.dst'));
	end;
	
	Actualizar(maestro, detalles, resultado);
	
END.

