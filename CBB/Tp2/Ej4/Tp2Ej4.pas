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
	Dim: 20;
type
	tipoPelicula = record
		codigo: integer;
		nombre: String[50];
		genero: String[50];
		director: String[50];
		duracion: integer;
		fecha: integer;
		cantidadAsistentes: integer;
	end;
	tipoMaestro = record
		datos: tipoPelicula;
		totalAsistentesSemana: integer;
	end;
	
	archDetalles = File of tipoPelicula;
	archMaestro = File of tipoMaestro;
	arrTipoPeliculas = array [1..Dim] of tipoPelicula;
	arrArchDetalles = File of tipoPelicula;
	
	
	
BEGIN
	
	
END.

