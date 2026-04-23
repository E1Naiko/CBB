{
		Una zapatería cuenta con 20 locales de ventas. Cada local de ventas envía un listado
	con los calzados vendidos indicando: código de calzado, número y cantidad vendida
	del mismo.
	
		El archivo maestro almacena la información de cada uno de los calzados que se
	venden, para ello se registra el código de calzado, número, descripción, precio unitario,
	color, el stock de cada producto y el stock mínimo.
		
		Escriba el programa principal con la declaración de tipos necesaria y realice un
	proceso que reciba los 20 detalles y actualice el archivo maestro con la información
	proveniente de los archivos detalle. Tanto el maestro como los detalles se encuentran
	ordenados por el código de calzado y el número.
	
		Además, se deberá informar qué calzados no tuvieron ventas y cuáles quedaron por
	debajo del stock mínimo. Los calzados sin ventas se informan por pantalla, mientras
	que los calzados que quedaron por debajo del stock mínimo se deben informar en un
	archivo de texto llamado calzadosinstock.txt.
	
	Nota: tenga en cuenta que no se realizan ventas si no se posee stock.
}

program tp2Ej3;

const
	CANT_DETALLES = 20;
	ValorA = 9999;
	NOM_ARCHIVO_SALIDA = 'calzadosinstock.txt';

type
	cadCorta = String[50];
	
	tipoDetalle = record
		codCalzado: integer;
		num: integer;
		cantVendida: integer;
	end;
	
	tipoMaestro = record
		codCalzado: integer;
		num: integer;
		descripcion: cadCorta;
		precioUnidad: real;
		color: cadCorta;
		stockActual: integer;
		stockMinimo: integer;
	end;
	
	archMaestro = File of tipoMaestro;
	archDetalle = File of tipoDetalle;
	arrArchDetalle = array [1..CANT_DETALLES] of archDetalle;
	arrTipoDetalle = array [1..CANT_DETALLES] of tipoDetalle;
	
	listaVenta = record
		ant: ^listaVenta;
		dato: tipoMaestro;
		sig: ^listaVenta;
	end;
	
	tipoLista = record
		pri: ^listaVenta;
		ult: ^listaVenta;
	end;
	
function esBajoStock(master: tipoMaestro): boolean;
	begin
		esBajoStock := master.stockActual < master.stockMinimo;
	end;

procedure noTuvoVentas(det: tipoDetalle);
	begin
		if (det.cantVendida = 0) then
			writeln(' -  El elemento ID°', det.codCalzado, ' no tuvo ventas.');
	end;


procedure actualizarRegistroMaestro(var maestro: tipoMaestro; det: tipoDetalle);
	begin
		maestro.stockActual:= maestro.stockActual - det.cantVendida;
	end;

procedure Leer(var detalle: archDetalle; var act: tipoDetalle);
	begin
		if(not EoF(detalle))then
			read(detalle, act)
		else
			act.codCalzado := ValorA;
	end;
	
procedure minimo(var archDetalles: arrArchDetalle; var arrResto: arrTipoDetalle; var min: tipoDetalle);
	var
		i, posMin: integer;
	begin
		min.codCalzado := ValorA;
		
		for i:= 1 to CANT_DETALLES do begin
			if (arrResto[i].codCalzado < min.codCalzado) then
			begin
				min := arrResto[i];
				posMin := i;
			end;
		end;
	
		if (min.codCalzado <> ValorA) then
			leer(archDetalles[posMin], arrResto[posMin]);
	end;

procedure exportarATXT(pri: tipoLista);
	var
		archTXT: text;
		aux: string;
		lista: ^listaVenta;
		act: tipoMaestro;
	begin
		
		lista := pri.pri;
		Assign(archTXT, NOM_ARCHIVO_SALIDA);
		rewrite(archTXT);
		
		while (lista<>nil) do begin
			act := lista^.dato;
			
			str(act.codCalzado, aux);
			writeln(archTXT, ('Codigo de calzado :    ' + aux));
			str(act.num, aux);
			writeln(archTXT, (' --- Numero : 		  ' + aux));
			writeln(archTXT, (' --- Descripcion :     ' + act.descripcion));
			str(act.precioUnidad, aux);
			writeln(archTXT, (' --- Precio x Unidad : ' + aux));
			writeln(archTXT, (' --- Color : 		  ' + act.color));
			str(act.stockActual, aux);
			writeln(archTXT, (' --- Stock Actual : 	  ' + aux));
			str(act.stockMinimo, aux);
			writeln(archTXT, (' --- Stock Minimo : 	  ' + aux));
			
			lista:= lista^.sig;
		end;
		
		close(archTXT);
		lista:= pri.pri;
	end;
	
procedure agregarAlFinal(actMaestro: tipoMaestro; var lista: tipoLista);
	var
		nue: ^listaVenta;
	begin
		new(nue);
		nue^.dato := actMaestro;
		nue^.sig := nil;
		nue^.ant := nil;
		
		if (lista.pri = nil) then begin
			// lista vacía
			lista.pri := nue;
			lista.ult := nue;
		end
		else begin
			// lista con elementos
			nue^.ant := lista.ult;
			lista.ult^.sig := nue;
			lista.ult := nue;
		end;
	end;
	
procedure Actualizar(var maestro: archMaestro; var detalles: arrArchDetalle);
	var
		i: integer;
		min: tipoDetalle;
		actMaestro: tipoMaestro;
		restoDetalles: arrTipoDetalle;
		lista: tipoLista;
		
	begin
		lista.pri := nil;
		lista.ult := nil;
		
		reset(maestro);
		for i:=1 to CANT_DETALLES do begin
			reset(detalles[i]);
			leer(detalles[i], restoDetalles[i]);
		end;
		minimo(detalles, restoDetalles, min);
		read(maestro, actMaestro);
			
		while (min.codCalzado <> ValorA) do begin
			while (min.codCalzado <> actMaestro.codCalzado) do begin
				read(maestro, actMaestro);
			end;
			
			while(actMaestro.codCalzado = min.codCalzado) do begin
				actualizarRegistroMaestro(actMaestro, min);
				
				if (esBajoStock(actMaestro)) then
					agregarAlFinal(actMaestro, lista);
				
				noTuvoVentas(min);
				
				minimo(detalles, restoDetalles, min);
			end;
			
			seek(maestro, filepos(maestro)-1);
			write(maestro, actMaestro);
		end;
		
		for i:=1 to CANT_DETALLES do
			close(detalles[i]);
		close(maestro);
	end;
	
var
	i: integer;
	master: archMaestro;
	det: arrArchDetalle;
	cad: cadCorta;

BEGIN
	Assign(master, 'maestro.dat');
	for i:=1 to CANT_DETALLES do begin
		Str(i, cad);
		Assign(det[i], ('detalle' + cad + '.dat'));
	end;
	
	Actualizar(master, det);
END.
