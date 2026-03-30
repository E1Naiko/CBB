program tp2ej1_menu;

uses crt;

const
    dimF = 9;
    valorAlto = 9999;

type
    tipoFecha = record
        dia: 1..30;
        mes: 1..12;
        anio: integer;
    end;

    tipoDetalle = record
        codEmpleado: integer;
        fecha: tipoFecha;
        cantDiasLicenciaSolicitado: integer;
    end;

    tipoMaestro = record
        codEmpleado: integer;
        nombre: String[30];
        apellido: String[30];
        fechaNacimiento: tipoFecha;
        direccion: String[30];
        cantHijos: integer;
        telefono: integer;
        cantDiasCorrespondenVacacionesEnPeriodo: integer;
    end;

    vectorDetalle = array[0..dimF] of file of tipoDetalle;
    vectorReg = array[0..dimF] of tipoDetalle;

var
    mae: file of tipoMaestro;
    det: file of tipoDetalle;

{ ------------------------ GENERAR MAESTRO ------------------------ }
procedure generarMaestro();
var regM: tipoMaestro;
    i: integer;
begin
    assign(mae, 'maestro.dat');
    rewrite(mae);

    for i := 1 to 150 do begin
        regM.codEmpleado := i;

        str(i, regM.nombre);
        regM.nombre := 'Nombre' + regM.nombre;

        str(i, regM.apellido);
        regM.apellido := 'Apellido' + regM.apellido;

        regM.fechaNacimiento.dia := random(30) + 1;
        regM.fechaNacimiento.mes := random(12) + 1;
        regM.fechaNacimiento.anio := 1980 + random(25);

        str(i, regM.direccion);
        regM.direccion := 'Calle ' + regM.direccion;

        regM.cantHijos := random(4);
        regM.telefono := 100000 + random(900000);

        regM.cantDiasCorrespondenVacacionesEnPeriodo := 10 + random(20);

        write(mae, regM);
    end;

    close(mae);
end;

{ ------------------------ GENERAR DETALLE ------------------------ }
procedure generarDetalle(nombre: string);
var regD: tipoDetalle;
    cod: integer;
begin
    assign(det, nombre);
    rewrite(det);

    cod := 1 + random(150);

    while (cod <= 150) do begin
        regD.codEmpleado := cod;

        regD.fecha.dia := random(30) + 1;
        regD.fecha.mes := random(12) + 1;
        regD.fecha.anio := 2025;

        regD.cantDiasLicenciaSolicitado := 1 + random(15);

        write(det, regD);

        cod := cod + (1 + random(3));
    end;

    close(det);
end;

{ ------------------------ IMPRIMIR MAESTRO ------------------------ }
procedure imprimirMaestro();
var regM: tipoMaestro;
begin
    assign(mae, 'maestro.dat');
    reset(mae);

    writeln('--- MAESTRO ---');
    while not eof(mae) do begin
        read(mae, regM);
        writeln('Cod: ', regM.codEmpleado,
                ' | Nombre: ', regM.nombre, ' ', regM.apellido,
                ' | Vacaciones: ', regM.cantDiasCorrespondenVacacionesEnPeriodo);
    end;

    close(mae);
end;

{ ------------------------ IMPRIMIR DETALLE ------------------------ }
procedure imprimirDetalle(nombre: string);
var regD: tipoDetalle;
begin
    assign(det, nombre);
    reset(det);

    writeln('--- ', nombre, ' ---');
    while not eof(det) do begin
        read(det, regD);
        writeln('Cod: ', regD.codEmpleado,
                ' | Fecha: ', regD.fecha.dia, '/', regD.fecha.mes, '/', regD.fecha.anio,
                ' | Dias solicitados: ', regD.cantDiasLicenciaSolicitado);
    end;

    close(det);
end;

{ ------------------------ LEER ------------------------ }
procedure leer(var archivo: file of tipoDetalle; var dato: tipoDetalle);
begin
    if not eof(archivo) then
        read(archivo, dato)
    else
        dato.codEmpleado := valorAlto;
end;

{ ------------------------ MINIMO ------------------------ }
procedure minimo(var vDet: vectorDetalle; var vReg: vectorReg; var min: tipoDetalle);
var
    i, pos: integer;
begin
    min.codEmpleado := valorAlto;
    pos := -1;

    for i := 0 to dimF do begin
        if vReg[i].codEmpleado < min.codEmpleado then begin
            min := vReg[i];
            pos := i;
        end;
    end;

    if pos <> -1 then
        leer(vDet[pos], vReg[pos]);
end;

{ ------------------------ ACTUALIZAR MAESTRO ------------------------ }
procedure actualizarMaestro;
var
    vDet: vectorDetalle;
    vReg: vectorReg;
    i: integer;
    min: tipoDetalle;
    regM: tipoMaestro;
    nombre: string;
    totalDias: integer;
begin
    assign(mae, 'maestro.dat');
    reset(mae);

    { abrir detalles }
    for i := 0 to dimF do begin
        str(i, nombre);
        nombre := 'detalle' + nombre + '.dat';
        assign(vDet[i], nombre);
        reset(vDet[i]);
        leer(vDet[i], vReg[i]);
    end;

    minimo(vDet, vReg, min);

    while (min.codEmpleado <> valorAlto) do begin
        read(mae, regM);

        while regM.codEmpleado <> min.codEmpleado do
            read(mae, regM);

        totalDias := 0;

        while regM.codEmpleado = min.codEmpleado do begin
            totalDias := totalDias + min.cantDiasLicenciaSolicitado;
            minimo(vDet, vReg, min);
        end;

        regM.cantDiasCorrespondenVacacionesEnPeriodo :=
            regM.cantDiasCorrespondenVacacionesEnPeriodo - totalDias;

        seek(mae, filepos(mae) - 1);
        write(mae, regM);
    end;

    close(mae);

    for i := 0 to dimF do
        close(vDet[i]);
end;

{ ------------------------ MENU ------------------------ }
procedure menu();
var
    op, i: integer;
    nombreArchivo: string;
begin
    repeat
        clrscr;
        writeln('==== MENU ====');
        writeln('1. Generar archivos');
        writeln('2. Mostrar maestro');
        writeln('3. Mostrar detalles');
        writeln('4. Actualizar maestro');
        writeln('0. Salir');
        write('Opcion: ');
        readln(op);

        clrscr;

        case op of
            1: begin
                randomize;
                generarMaestro();
                for i := 0 to dimF do begin
                    str(i, nombreArchivo);
                    generarDetalle('detalle' + nombreArchivo + '.dat');
                end;
                writeln('Archivos generados.');
            end;

            2: imprimirMaestro();

            3: begin
                for i := 0 to dimF do begin
                    str(i, nombreArchivo);
                    imprimirDetalle('detalle' + nombreArchivo + '.dat');
                    readln;
                end;
            end;

            4: begin
                actualizarMaestro();
                writeln('Maestro actualizado.');
            end;
        end;

        writeln;
        writeln('ENTER para continuar...');
        readln;
    until op = 0;
end;

{ ------------------------ MAIN ------------------------ }
begin
    menu();
end.
