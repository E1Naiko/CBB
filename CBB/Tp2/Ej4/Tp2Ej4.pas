{
   Tp2Ej4.pas
   
			4. Una cadena de cines de renombre desea administrar la
		asistencia del público a las diferentes películas que se
		exhiben actualmente. Para ello cada cine genera semanalmente
		un archivo indicando: código de película, nombre de la película,
		género, director, duración, fecha y cantidad de asistentes a
		la función. Se sabe que la cadena tiene 20 cines. Escriba las
		declaraciones necesarias y un procedimiento que reciba los
		20 archivos y un String indicando la ruta del archivo maestro y
		genere el archivo maestro de la semana a partir de los 20
		detalles (cada película deberá aparecer una vez en el maestro
		con los datos propios de la película y el total de asistentes
		que tuvo durante la semana). Todos los archivos detalles vienen
		ordenados por código de película. Tenga en cuenta que en cada
		detalle la misma película aparecerá tantas veces como funciones
		haya dentro de esa semana.

}


program Tp2Ej4;
const
	Dim = 20;
	ValorA = 9999;
	
type
	cadena = String[50];
	tipoDetalle = record
		codigo,
		 duracion,
		 fecha,
		 cantidadAsistentes: integer;
		nombre, 
		 genero,
		 director: cadena;
		
	end;

	datosMaestro = record
		codigo,
		 duracion: integer;
		nombre,
		 genero,
		 director: cadena;
	end;

	tipoMaestro = record
		datos: datosMaestro;
		totalAsistentesSemana: integer;
	end;
	
	archDetalles = File of tipoDetalle;
	archMaestro = File of tipoMaestro;
	arrTipoDetalle = array [1..Dim] of tipoDetalle;
	arrArchDetalles = array [1..Dim] of archDetalles;
	
procedure Leer(var detalle: archDetalles; var act: tipoDetalle);
	begin
		if(not EoF(detalle))then
			read(detalle, act)
		else
			act.codigo := ValorA;
	end;
	
procedure minimo(var archDetalles: arrArchDetalles; var arrResto: arrTipoDetalle; var min: tipoDetalle);
	var
		i, posMin: integer;
	begin
		min.codigo := ValorA;
		posMin := -1;
		
		for i:= 1 to Dim do begin
			if (arrResto[i].codigo < min.codigo) then
			begin
				min := arrResto[i];
				posMin := i;
			end;
		end;
	
		if (min.codigo <> ValorA) then
			leer(archDetalles[posMin], arrResto[posMin]);
	end;
	
procedure innitMaestro(var nue: tipoMaestro; act: tipoDetalle);
	begin
		nue.datos.codigo	:= act.codigo;
		nue.datos.nombre	:= act.nombre;
		nue.datos.genero	:= act.genero;
		nue.datos.director  := act.director;
		nue.datos.duracion  := act.duracion;
		nue.totalAsistentesSemana := 0;
	end;
	
procedure generarMaestro(detalles: arrArchDetalles; nombreMaestro: cadena);
	var
		maestro: archMaestro;
		act: tipoMaestro;
		actCod: integer;
		min: tipoDetalle;
		restoDetalles: arrTipoDetalle;
		i: integer;
		
	begin
		Assign(maestro, nombreMaestro);
		rewrite(maestro);
		for i:=1 to Dim do begin
			reset(detalles[i]);
			leer(detalles[i], restoDetalles[i]);
		end;
		minimo(detalles, restoDetalles, min);
		actCod:= min.codigo;
		
		while (min.codigo <> ValorA) do begin
			innitMaestro(act, min);
			actCod:= min.codigo;
			
			while (min.codigo = actCod) do begin
				act.totalAsistentesSemana := act.totalAsistentesSemana + min.cantidadAsistentes;
				minimo(detalles, restoDetalles, min);
			end;
			write(maestro,act);
		end;
		
		for i:=1 to Dim do 
			close(detalles[i]);
		close(maestro);
	end;
	
var
	i: integer;
	strAux, maestro: cadena;
	det: arrArchDetalles;
	
BEGIN
	for i:=1 to Dim do begin
		str(i, strAux);
		strAux:= ('detalles' + strAux + '.dat');
		Assign(det[i], strAux);
	end;
	
	maestro:= 'maestro.dat';
	generarMaestro(det, maestro);
END.

