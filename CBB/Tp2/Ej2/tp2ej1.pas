{
   tp2ej1.pas
   
		1. El área de recursos humanos de un ministerio administra el personal del mismo
	distribuido en 10 direcciones generales.
	
	Entre otras funciones, recibe periódicamente un archivo detalle de cada una de las
	direcciones conteniendo información de las licencias solicitadas por el personal.
	Cada archivo detalle contiene información que indica: código de empleado, la fecha y
	la cantidad de días de licencia solicitadas.

												 El archivo maestro tiene información de
	cada empleado: código de empleado, nombre y apellido, fecha de nacimiento,
	dirección, cantidad de hijos, teléfono, cantidad de días que le corresponden de
	vacaciones en ese periodo.
	
							   Tanto el maestro como los detalles están ordenados por
	código de empleado. Escriba el programa principal con la declaración de tipos
	necesaria y realice un proceso que reciba los detalles y actualice el archivo maestro
	con la información proveniente de los archivos detalles.
														
															 Se debe actualizar la cantidad
	de días que le restan de vacaciones. Si el empleado tiene menos días de los que
	solicita deberá informarse en un archivo de texto indicando: código de empleado,
	nombre y apellido, cantidad de días que tiene y cantidad de días que solicita.

}


program tp2ej1;
const
	ERROR_EXCESO = 'ERROR - EXCESO DE DIAS SOLICITADOS';
	DIML = 10;
	
type
	cadenaCorta = String[20];
	cadenaLarga = String[50];
	
	tipoDetalle = record
		codEmpleado: integer;
		fecha: longint;
		cantidadDiasLicenciaSolicitadas: integer;
	end;
	
	tipoMaestro = record
		codEmpleado: integer;
		nombre: cadenaCorta;
		apellido: cadenaCorta;
		fechanacimiento: Longint;
		direccion: cadenaLarga;
		cantidadHijos: integer;
		telefono: Longint;
		cantidadDiasCorrespondenDeVacacionesEnEsePeriodo: integer;
	end;
	
	archMaestro = FILE of tipoMaestro;
	archDetalle = FILE of tipoDetalle;
	arregloArchDetalle = array [0..9] of archDetalle;
	
function devolverNombre(i: integer): cadenaCorta;
	var
		nom: cadenaCorta;
		numStr: cadenaCorta;
	begin
		str(i, numStr);
		nom:= 'detalle' + numStr + '.dat';
		devolverNombre:= nom;
	end;

procedure actualizarBDD(var maestro: archMaestro; var detalles: arregloArchDetalle);
	var
		i: integer;
		act: tipoMaestro;
		detAct: tipoDetalle;
		encontre: boolean;
	begin
		reset(maestro);
		for i:=0 to 9 do reset(detalles[i]);
		
		//   	Se debe actualizar la cantidad de días que le restan de vacaciones.
		// Si el empleado tiene menos días de los que solicita deberá informarse en
		// un archivo de texto indicando: código de empleado, nombre y apellido,
		// cantidad de días que tiene y cantidad de días que solicita.
		
		for i:=0 to 9 do begin
			while (not EOF(detalles[i])) do begin
				read(detalles[i], detAct);
				encontre:= false;
				while (not EOF(maestro) and not encontre) do begin
					read(maestro, act);
					if (act.codEmpleado = detAct.codEmpleado) then encontre:= true;
				end;
				if (encontre) then begin
					if (act.cantidadDiasCorrespondenDeVacacionesEnEsePeriodo<detAct.cantidadDiasLicenciaSolicitadas) then
						writeln(ERROR_EXCESO)
					else begin
						writeln(act.codEmpleado, ' DEBUG LO ENCONTRE');
					end;
				end else
				writeln('ERROR - USUARIO NO ENCONTRADO');
			end;
		end;
		
		close(maestro);
		for i:=0 to 9 do reset(detalles[i]);
	end;


var
	i: integer;
	maestro: archMaestro; 
	detalles: arregloArchDetalle;

BEGIN
	assign(maestro, 'maestro.dat');
	for i:=0 to 9 do assign(detalles[i], devolverNombre(i));
	
END.

