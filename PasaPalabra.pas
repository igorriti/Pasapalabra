program Pasapalabras;
{Este programa se trata de una implementacion operacional del juego Pasapalabra, en el mismo el usuario
tiene 6 opciones que le permiten realizar ciertas acciones como por ejemplo ver la lista de los jugadores,agregar un jugador,jugar,entre otras...}
uses crt;

const
    
    MaxTop10 = 9;
    MinTop10 = 0;
    
type
    // Arbol que contiene el nombre de los jugadores y sus victorias
    Arbol = ^nodoarbol;
    
    nodoarbol = record
        Nombre : String[20];
        Wins : Integer;  //wins = victorias
        Ant,Sig : Arbol;
        end;
    

    reg_Jugador = record
        Nombre : String[20];
        Wins : Integer; 
        Eliminado : Boolean;
        end;
    
    //Archivo que contiene el nombre de los jugadores y sus victorias
    Jugadores = file of reg_jugador;
    
    reg_palabra = record
    	nro_set : integer;
    	letra : char;
    	palabra : string;
    	consigna : string
    	end;
    
    //Archivo que contiene la letras, palabras y consignas a dar a los jugadores
    Palabras = file of reg_palabra; 
    
    //Arreglo que apunta a los nodos de un arbol ( va a estar ordenado segun las wins de cada jugador de forma descendente)
    ArrTop10 = array [MinTop10..MaxTop10] of Arbol;
    
    
    PuntLista = ^nodolista;
    
    EnuEstado = (Pendiente,Acertada,Errada);
    
    nodolista = record
        Letra:Char;
        Palabra: String;
        Consigna : String;
        Estado : EnuEstado ; // Los estados seran Pendiente, Acertada y errada
        Sig : PuntLista;
        end;
        
        
    reg_Partida = record
        Nombre : String[20];
        Rosco : PuntLista;  //Lista circular
        end;
        
    //Arreglo que contiene el nombre del jugador y su correspondiente rosco.
    ArrPartida = array [1..2] of reg_Partida;

procedure InsertaJugadoresArbol (var ArbolJugadores : Arbol; Nombre : String ; Wins: Integer);
//Este procedimiento se encarga de insertar jugadores en los nodos del arbol(ordenado por nombre)

begin
    if (ArbolJugadores = nil) then
        begin
            new(ArbolJugadores);
            ArbolJugadores^.Ant:= nil;
            ArbolJugadores^.Sig:= nil;
            ArbolJugadores^.Nombre:= Nombre;
            ArbolJugadores^.Wins:= Wins;
        end
    else
        begin
            if (ArbolJugadores^.Nombre < Nombre) then
                InsertaJugadoresArbol(ArbolJugadores^.Sig, Nombre,Wins)
            else
                InsertaJugadoresArbol(ArbolJugadores^.Ant, Nombre,Wins);
        end;
end;

procedure LLenaArbol ( var ArbolJugadores : Arbol; var ArchJugadores : Jugadores);
//Este procedimiento se encarga de llenar el ArbolJugadores en base al archivo que contiene los jugadores y sus wins
var
    Ficha : reg_Jugador;
    
begin
    While not EOF(ArchJugadores) do
        begin
            Read(ArchJugadores,Ficha);
            
            If Ficha.Eliminado=False then //Si ficha.Eliminado es igual a True significa que el jugador esta borrado y no debe ser tomado en cuenta (Borrado logico)
                InsertaJugadoresArbol(ArbolJugadores,Ficha.Nombre,Ficha.Wins);
        end;
end;
            
    
procedure ImprimeJugadores ( ArbolJugadores : Arbol);
//Este procedimiento imprime la lista de jugadores de forma in order    
begin

    If ArbolJugadores<>Nil then
        begin    
            ImprimeJugadores(ArbolJugadores^.Ant);
             Textcolor(1);
             Write('Jugador: ');
             TextColor(15);
             Write(ArbolJugadores^.Nombre);
             TextColor(2);
             Write('  Partidas ganadas: ');
             TextColor(15);
             WriteLn(ArbolJugadores^.Wins);
            ImprimeJugadores(ArbolJugadores^.Sig);
        end;
    
    exit;
    
end;

procedure InsertaEnArreglo ( NodoAinsertar : Arbol ; Var Diez_Maximos_Ganadores : ArrTop10; Pos : integer);
//Este procedimiento se encarga de insertar cada nodo del arbol en el arreglo de forma que quede ordenado descendentemente segun las victorias de cada jugador
//Si hay dos jugadores con la misma cantidad de victorias se los ordena segun nombre
var
    i : Integer;

begin
    If Pos<11 then
        begin
            If Diez_Maximos_Ganadores[Pos]=Nil then
                begin
                    New(Diez_Maximos_Ganadores[Pos]);
                    Diez_Maximos_Ganadores[Pos]:=NodoAinsertar
                end
            else
                If Diez_Maximos_Ganadores[Pos]^.Wins <NodoAinsertar^.Wins then
                    begin
                        Diez_Maximos_Ganadores[MaxTop10]:=Nil;
                        For i:=MaxTop10 downto Pos+1 do Diez_Maximos_Ganadores[i]:=Diez_Maximos_Ganadores[i-1]; //Corrimiento hacia derecha
                        Diez_Maximos_Ganadores[Pos]:=NodoAinsertar;
                    end
                else
                    InsertaEnArreglo(NodoAinsertar,Diez_Maximos_Ganadores,Pos+1);
        end;
end;

procedure RecorreArbol (ArbolJugadores : Arbol; Var Diez_Maximos_Ganadores : ArrTop10);
//Este procedimiento se encarga de recorrer el arbol de forma In-order y seleccionar cada nodo para insertarlo en el arreglo 


begin
    If ArbolJugadores<>Nil then
        begin    
            RecorreArbol(ArbolJugadores^.Ant,Diez_Maximos_Ganadores);
            InsertaEnArreglo(ArbolJugadores,Diez_Maximos_Ganadores,0);
            RecorreArbol(ArbolJugadores^.Sig,Diez_Maximos_Ganadores);
        end;
end;
    
procedure  ImprimeTop10 (ArbolJugadores : Arbol); 
//Este procedimiento se encarga de imprimir el top 10 de los jugadores segun su cantidad de victorias
var
    Diez_Maximos_ganadores : ArrTop10;
    i : Integer;
    
begin
    
    For i:=MinTop10 to MaxTop10 do Diez_Maximos_ganadores[i]:=Nil;
        RecorreArbol(ArbolJugadores,Diez_Maximos_Ganadores);
    For i:=MinTop10 to MaxTop10 do 
        begin
            If Diez_Maximos_ganadores[i]<>Nil then
                begin
                    TextColor(1);
                    Write('Jugador: ');
                    TextColor(15);
                    Write(Diez_Maximos_ganadores[i]^.Nombre);
                    TextColor(2);
                    Write('  Partidas ganadas: ');
                    TextColor(15);
                    WriteLn(Diez_Maximos_ganadores[i]^.Wins);

                    
                end;
        end;
    
end;

function EstaEnArbol (ArbolJugadores : Arbol ;  Buscado : String) : Boolean;
//Esta funcion verifica si un jugador esta en el arbol o no. Devuelve True si esta en el arbol y False si no.
begin
    
    If ArbolJugadores<>Nil then
        begin
            If ArbolJugadores^.Nombre=Buscado then
                EstaEnArbol:=True
            else
                begin
                    If ArbolJugadores^.Nombre>Buscado then
                        EstaEnArbol:=EstaEnArbol(ArbolJugadores^.Ant,Buscado)
                    else
                        EstaEnArbol:=EstaEnArbol(ArbolJugadores^.Sig,Buscado)
                end;
        
        end
    else
        EstaEnArbol:=False;
end;


procedure EliminaNodo (var ArbolJugadores : Arbol; Buscado : String);
//Este procedimiento se encarga de eliminar un jugador del ArbolJugadores.
var
    Aux,Suc,Aux2 : Arbol;
    
begin
    If ArbolJugadores<>nil then 
        begin
            If Buscado<ArbolJugadores^.Nombre then
                EliminaNodo(ArbolJugadores^.Ant, Buscado)
            else
                if BUscado>ArbolJugadores^.Nombre then
                    EliminaNodo(ArbolJugadores^.Sig,Buscado)
                else
                    begin
                        Aux:=ArbolJugadores;
                        If (ArbolJugadores^.Sig=Nil) then  
                            begin
                                ArbolJugadores:=ArbolJugadores^.Ant;
                            end
                        else
                            If ArbolJugadores^.Sig^.Ant = Nil then  
					            begin
						            ArbolJugadores^.Sig^.Ant := ArbolJugadores^.Ant;
						            ArbolJugadores:=ArbolJugadores^.Sig;
					            end
                            else                                    //Si tiene dos hijos se elige el nodo mas a la izquierda del sub arbol derecho
                                begin 
                                    Aux2:=ArbolJugadores^.Sig;		
					                While Aux2^.Ant^.Ant <>Nil do
	                                      Aux2:=Aux2^.Ant;
						    	    Suc:=Aux2^.Ant;
							        Aux2^.Ant:=Suc^.Sig;
				                    Suc^.Ant := ArbolJugadores^.Ant;
							        Suc^.Sig := ArbolJugadores^.Sig;
				                    ArbolJugadores:=Suc;

                                end;
                        Dispose(Aux);
                            
                    end;
        end;                    
end;

procedure EliminaDeArch (var ArchJugadores : Jugadores; Buscado : String);
//Este procedimiento se encarga de eliminar un jugador de ArchJugadores

var
    Ficha : reg_Jugador;
    i : Integer;
    
begin
    i:=0;
    
    While i<filesize(ArchJugadores) do
        begin
            Seek(ArchJugadores,i);
            Read(ArchJugadores,Ficha);
            If Ficha.Nombre=Buscado then
                begin
                    Ficha.Eliminado:=True;    //Se trata de un eliminado logico, no se lo elimina como tal del archivo.
                    Seek(ArchJugadores,i);
                    Write(ArchJugadores,Ficha)
                end;
                
            i:=i+1;
                    
        end;
end;
            

procedure BorrarJugador ( var ArbolJugadores : Arbol ; var ArchJugadores : Jugadores );
//Este procedimiento se encarga de pedirle al usuario  el nombre de un jugador para eliminarlo del archivo y el arbol.
//Primero verifica si esta en el Arbol y luego si esto es Verdadero , se procede a eliminar a el jugador.
var
    Buscado : String;
    Decision : Char;
begin
    Write('¿A que jugador desea eliminar? ' );
    ReadLn(Buscado);
    
    If EstaEnArbol(ArbolJugadores, Buscado) then
        begin
            EliminaNodo(ArbolJugadores,Buscado);
            EliminaDeArch(ArchJugadores,Buscado);
            WriteLn('');
            TextColor(10);
            WriteLn('Jugador eliminado exitosamente!');
            TextColor(15);
        end
    else
        begin
            WriteLn('');
            TextColor(4);
            Write('ERROR! ');
            TextColor(15);
            WriteLn('El jugador no se encuentra en la lista de jugadores');
            WriteLn('');
            Write('Si desea volver a intentarlo ponga "S" sino ponga cualquier otro caracter: ');
            ReadLn(Decision);
            If Decision='S' then
                begin
                    Clrscr;
                    BorrarJugador(ArbolJugadores,ArchJugadores)
                end
            else
                Exit;
            
        end;
end;

Procedure AgregaEnArch (var ArchJugadores : Jugadores ; Ficha : reg_Jugador);
//Este procedimiento se encarga de agregar un jugador al final del archivo.

begin
    Seek(ArchJugadores,filesize(ArchJugadores)); //Localiza el final del archivo
    Write(ArchJugadores,Ficha);

end;

Procedure AgregaJugador (var ArbolJugadores : Arbol ; var ArchJugadores : Jugadores);
//Este procedimiento se encarga de pedirle al usuario un jugador para agregarlo tanto en el Arbol como en el archivo que contiene los jugadores.
var
    Nombre : String;
    Decision : Char;
    Ficha : reg_Jugador;
    
begin
    Write('Escriba el nombre del jugador que desea agregar : ');
    ReadLn(Nombre);
    
    If EstaEnArbol(ArbolJugadores,Nombre) then
        begin
            WriteLn('');
            TextColor(4);
            Write('ERROR! ');
            TextColor(15);
            WriteLn('El jugador ya existe');
            WriteLn('');
            Write('Si desea volver a intentarlo ponga "S" sino ponga cualquier otro caracter: ');
            ReadLn(Decision);
            If Decision='S' then
                begin
                    Clrscr;
                    AgregaJugador(ArbolJugadores,ArchJugadores)
                end
            else
                Exit;
        end
    else
        begin
            Ficha.Nombre:=Nombre;
            Ficha.Wins:=0;
            Ficha.Eliminado:=False;
            InsertaJugadoresArbol(ArbolJugadores,Ficha.Nombre,Ficha.Wins);
            AgregaEnArch(ArchJugadores,Ficha);
            WriteLn('');
            TextColor(10);
            WriteLn('Jugador agregado exitosamente!');
            TextColor(15);
        end;
        
end;


procedure CargaPreguntas (var ArchPalabras : Palabras; var Rosco : PuntLista);
// Este procedimiento se encarga de cargar las preguntas (letra,consigna,palabra) en una lista circular 
var
    nro_set,i,tope: Integer;
    Sets : reg_palabra;
    Nuevo : PuntLista;
    
begin
    
    nro_set:=Random(5)+1;
    Sets.nro_set:=6;
    i:=0;
    While not EOF(Archpalabras) and (Sets.nro_set<>nro_set) do  //Se avanza en el archivo hasta llegar al set buscado;
        begin

            Seek(ArchPalabras,i);
            Read(ArchPalabras,Sets);
            
            i:=i+26; //Se avanza cada 26 para optimizar la busqueda ya que no seria eficiente avanzar en letras que pertenecen al mismo set
        end;
    i:=i-27;
    tope:=i+26;
    
    While i<Tope do                         // En este ciclo se crea y desarrolla la lista circular que representa el rosco del juego
        begin

            Seek(ArchPalabras,TOpe);
            Read(ArchPalabras,Sets);
            New(Nuevo);
            Nuevo^.Letra:=Sets.letra;
            Nuevo^.Palabra:=Sets.Palabra;
            Nuevo^.Consigna:=Sets.Consigna;
            Nuevo^.Estado:=Pendiente;
            If Rosco=Nil then
                begin
                    Nuevo^.Sig:= Nuevo;
                    Rosco :=Nuevo;
                end
            else
                begin
                    Nuevo^.Sig:=Rosco^.Sig;
                    Rosco^.Sig:=Nuevo;
                end;
                

           Tope:=Tope-1;
    
    
        end;

end;

function QuedanPP (Rosco : PuntLista) : Boolean; //QuedanPP = Quedan Por Preguntar
//Esta funcion se encarga de verificar si quedan preguntas pendientes en la lista circular.

var
    Cursor : PuntLista;
    
begin
    Cursor:=Rosco;
    
    QuedanPP:=False;
    
    If Cursor^.Estado<>Pendiente then
        begin
            Cursor:=Cursor^.Sig;
                While (Cursor^.Letra<>'A') and (QuedanPP=False) do
                    begin
                        If Cursor^.Estado<>Pendiente then
                            Cursor:=Cursor^.Sig
                        else
                            QuedanPP:=True;
                    end;
        end
    else
        QuedanPP:=True;
end;

procedure Turno (var Partida: ArrPartida; Jug : Integer);
//Este procedimiento se encarga de mostrarle al jugador la letra y consigna para que responda la palabra que le corresponde
//En base a lo que el jugador responda el estado del nodo cambia a Acertada,Pendiente o Errada

var
    Palabra : String;

begin
    
    If Jug=1 then
        Writeln('Turno de ', Partida[1].Nombre)
    else
        WriteLn('Turno de ', Partida[2].Nombre);
        
    While Partida[jug].rosco^.Estado<>Pendiente do
            Partida[Jug].Rosco:=Partida[Jug].Rosco^.Sig;
            
    WriteLn('');
    Writeln('Letra: ', Partida[Jug].Rosco^.Letra);
    WriteLn('Consigna: ', Partida[Jug].Rosco^.Consigna);
    Write('Palabra ("pp" para pasar palabra): ');
    ReadLn(Palabra);
             
    If Palabra='pp' then
        begin
            Partida[Jug].Rosco:=Partida[Jug].Rosco^.Sig;
            TextColor(9);
            WriteLn('');
            WriteLn('PasaPalabra!');
            Delay(800);
            TextColor(15);
        end
            else
                If Palabra=Partida[Jug].Rosco^.Palabra then
                    begin
                        Partida[Jug].Rosco^.Estado:=Acertada;
                        Partida[Jug].Rosco:=Partida[Jug].Rosco^.Sig;
                        TextColor(10);
                        WriteLn('');
                        WriteLn('Correcto!');
                        Delay(800);
                        TextColor(15);
                        clrscr;
                        If QuedanPP(Partida[Jug].Rosco) then
                        Turno(Partida,Jug);             //Si el jugador acierta la palabra sigue jugando hasta que en el algun momento erre.
                        
                    end
                else
                    begin
                        Partida[Jug].Rosco^.Estado:=Errada;
                        Partida[Jug].Rosco:=Partida[Jug].Rosco^.Sig;
                        TextColor(12);
                        WriteLn('');
                        WriteLn('Incorrecto!');
                        Delay(800);
                        TextColor(15);
                    end;
end;

function CantAcertada ( Rosco : PuntLista) : integer;
//Esta funcion se encarrga de contar la cantidad de preguntas acertadas por el jugador
var
    Cursor : PuntLista;
    
begin
    Cursor:=Rosco;
    CantAcertada:=0;
    If Cursor^.Estado=Acertada then
            CantAcertada:=CantAcertada +1;
    
    Cursor:=Cursor^.Sig;

    While Cursor<>Rosco do
        begin
            If Cursor^.Estado=Acertada then
                CantAcertada:=CantAcertada +1;
            Cursor:=Cursor^.Sig;
        end;
    
end;

procedure AgregarWinArbol (var ArbolJugadores : Arbol; Buscado : String);
//Este procedimiento se encarga de agregar una victoria en el arbol al jugador buscado.
begin
    If ArbolJugadores<>Nil then
        If Buscado<ArbolJugadores^.Nombre then
            AgregarWinArbol(ArbolJugadores^.Ant,Buscado)
        else
            If Buscado>ArbolJugadores^.Nombre then
                AgregarWinArbol(ArbolJugadores^.Sig,Buscado)
            else
                ArbolJugadores^.Wins:=ArbolJugadores^.Wins +1;
                
end;

procedure AgregarWinArchivo (var ArchJugadores : jugadores; Buscado : String);           
//Este procedimiento se encarga de agregar una victoria en el archivo al jugador buscado.
var
    Ficha : reg_Jugador;
    i : Integer;
    
begin
    i:=0;
    
    While i<filesize(ArchJugadores) do
        begin
            Seek(ArchJugadores,i);
            Read(ArchJugadores,Ficha);
            If Ficha.Nombre=Buscado then
                begin
                    Ficha.Wins:=Ficha.Wins +1;
                    Seek(ArchJugadores,i);
                    Write(ArchJugadores,Ficha)
                end;
                
            i:=i+1;
                    
        end;
end;
procedure Ganador ( var ArbolJugadores : Arbol ; var ArchJugadores : Jugadores; Partida : ArrPartida; Jug : Integer );
//Este procedimiento se encarga de imprimir el nombre del jugador ganador y sumar 1 victoria tanto en el arbol como en el archiv0
var
    y : integer;
    
begin
    y:=0;
    AgregarWinArbol(ArbolJugadores,Partida[Jug].Nombre);
            AgregarWinArchivo(ArchJugadores,Partida[Jug].Nombre);
            
            repeat
                begin
                    Textcolor(y);
                    gotoxy(23,3) ; WriteLn(Partida[Jug].Nombre, ' es el ganador de la partida!');
                    gotoxy(23,4) ; WriteLn('Cantidad de preguntas acertadas: ' , cantAcertada(Partida[Jug].Rosco));
                    y:=y+1;
                    Delay(200);
                end;
            until y=16;
end;

procedure DeterminaGanador ( var ArbolJugadores : Arbol; var ArchJugadores: Jugadores; Partida : ArrPartida);
//Este procedimiento se encargar de determinar el ganador 

    
begin
 
    If CantAcertada(Partida[1].rosco) < CantAcertada(Partida[2].rosco) then
            Ganador(ArbolJugadores,ArchJugadores,Partida,2)
    else
        If CantAcertada(Partida[1].rosco) = CantAcertada(Partida[2].rosco) then  // Puede haber un empate y ningun jugador gana.
            WriteLn('Ambos jugadores han acertado la misma cantidad de palabras, es un empate!')
        else
            Ganador(ArbolJugadores,ArchJugadores,Partida,1);
            
end;

procedure Jugar ( var ArbolJugadores : Arbol; var  ArchJugadores : Jugadores );
//Este procedimiento se encarga de desarrolar la partida de pasapalabra.
//Se pide el nombre de los dos jugadores y se verifica que ambos esten en el arbol.
//Luego se le carga las preguntas a cada rosco para que finalmente se desarrollen los turnos hasta que algun jugador se quede sin preguntas pendientes
var
    Jugador1,Jugador2 : String;
    ArchPalabras : Palabras;
    Partida : ArrPartida;
    Jug : Integer;

begin
    
    
    Write('Ingrese el nombre del primer jugador: ');
    ReadLn(Jugador1);
    Writeln('');
    Write('Ingrese el nombre del segundo jugador: ');
    ReadLn(Jugador2);
    
    If Jugador1<>Jugador2 then //Los jugadores deben ser distintos
        begin
            If not EstaEnArbol(ArbolJugadores,Jugador1) then
                begin
                    WriteLn('');
                    TextColor(4);
                    Write('ERROR! ');
                    TextColor(15);
                    WriteLn('El jugador ', Jugador1, ' no se encuentra en el arbol Jugadores');
                    WriteLn('');
                    WriteLn('Presione Enter e intente nuevamente');
                    readln;
                    Clrscr;
                    Jugar(ArbolJugadores,ArchJugadores);
                end
            else
                If not EstaEnArbol(ArbolJugadores,Jugador2) then
                    begin
                        WriteLn('');
                        TextColor(4);
                        Write('ERROR! ');
                        TextColor(15);
                        WriteLn('El jugador ', Jugador2, ' no se encuentra en el arbol Jugadores');
                        WriteLn('');
                        WriteLn('Presione Enter e intente nuevamente');
                        readln;
                        clrscr;
                        Jugar(ArbolJugadores,ArchJugadores);
                    end
                else
                    begin
                        assign (ArchPalabras, '/ip2/palabras.dat');
                        reset(ArchPalabras);
                        Partida[1].Nombre:=Jugador1;
                        Partida[2].Nombre:=Jugador2;
                        randomize; 
                        Partida[2].Rosco:=Nil;
                        Partida[1].Rosco:=Nil;
                        CargaPreguntas(ArchPalabras,Partida[1].Rosco);
                        CargaPreguntas(ArchPalabras,Partida[2].Rosco);
                        Partida[1].Rosco:=Partida[1].Rosco^.Sig;   
                        Partida[2].Rosco:=Partida[2].Rosco^.Sig;        
                        clrscr;
                        Jug:=1; // Jugador que arranca

                        While QuedanPP(Partida[1].Rosco) and QuedanPP(Partida[2].Rosco) do
                                begin
                                    
                                    Turno(Partida,Jug);
                                    If QuedanPP(Partida[Jug].Rosco) then
                                        begin
                                        
                                            If Jug = 1 then
                                                Jug:=2
                                            else
                                                Jug:=1
                                        end;
                                    clrscr;
                                end;
                        
                        If Jug=1 then   //Si termina primero el jugador 1, el jugador 2 tiene derecho a completar su turno ya que el Jugador 1 empezo la partida.
                            begin
                                Turno(Partida,2);
                                clrscr;
                            end;
                        
                        gotoxy(17,1) ; Writeln('El jugador ',Partida[jug].Nombre,' ha completado su rosco primero');
                        Writeln('');
                        DeterminaGanador(ArbolJugadores,ArchJugadores,Partida);
                        close(ArchPalabras);
                    end;   
        end;
end;


// PROGRAMA PRINCIPAL 

var
    ArbolJugadores : Arbol;
    ArchJugadores : Jugadores;
    Opcion : Integer; 
    x,y : integer;

begin
    Opcion:=-1;
    Assign(ArchJugadores, '/ip2/IgnacioGorriti-Jugadores');
    Reset(ArchJugadores);
    
    LlenaArbol(ArbolJugadores, ArchJugadores);
    
    // Presentacion del Juego
    x:=0;
    y:=0;
    While X<=14 do
        begin
            textcolor(y);
            gotoxy(38-x,1) ; WriteLn('    ____  ____  ____  ____    ');
            gotoxy(38-x,2) ; WriteLn('   ||P ||||a ||||s ||||a ||   ');
            gotoxy(38-x,3) ; WriteLn('   ||__||||__||||__||||__||   ');
            gotoxy(38-x,4) ; WriteLn('   |/__\||/__\||/__\||/__\|   ');
            gotoxy(1+x,5) ; WriteLn('    ____  ____  ____  ____  ____  ____  ____    ');
            gotoxy(1+x,6) ; WriteLn('   ||p ||||a ||||l ||||a ||||b ||||r ||||a ||   ');
            gotoxy(1+x,7) ; WriteLN('   ||__||||__||||__||||__||||__||||__||||__||   ');
            gotoxy(1+x,8) ; WriteLn('   |/__\||/__\||/__\||/__\||/__\||/__\||/__\|   ');


            If (x mod 2 = 0) then
                y:=y+1;
            x:=x +1;
            delay(135);
        end;
    
    y:=0;

    repeat
        begin
        If y=16 then
            y:=0;
        Textcolor(y);
        gotoxy(23,10) ; WriteLn('Presione una tecla para comenzar');
        y:=y+1;
        Delay(500);
        
        end;
    until keypressed;

    clrscr;
    //Menu
    
    textcolor(15);
    While Opcion<>6 do
            begin
                WriteLn('');
                TextColor(2);
                gotoxy(11,1) ; WriteLn('==========================================================');
                Textcolor(15);
                gotoxy(11,2) ; WriteLn('                          Menu                           ');
                textcolor(2);
                gotoxy(11,3) ; WriteLn('==========================================================');
                TextColor(15);
                gotoxy(11,4) ; WriteLn('|    1- Agregar un jugador                               |');
                gotoxy(11,5) ; WriteLn('|    2- Ver lista de jugadores                           |');
                gotoxy(11,6) ; WriteLn('|    3- Ver los 10 jugadores con mas partidas ganadas    |');
                gotoxy(11,7) ; WriteLn('|    4- Jugar                                            |');
                gotoxy(11,8) ; WriteLn('|    5- Borrar un jugador                                |');
                gotoxy(11,9) ; WriteLn('|    6- Salir                                            |');
                gotoxy(9,11) ; Write('¿Que desea hacer? (Escriba el numero de la opcion elegida) : ');
                Readln(Opcion);
          
                    begin
                        clrscr;
                        Case Opcion of 
                            1 : begin
                                    AgregaJugador(ArbolJugadores,ArchJugadores);
                                    WriteLn('');
                                    WriteLn('Para volver al menu presione Enter');
                                    ReadLn;
                                end;
                                
                            2 : begin
                                    TextColor(14);
                                    WriteLn('Lista de jugadores: ');
                                    WriteLn('');
                                    ImprimeJugadores(ArbolJugadores);
                                    WriteLn('');
                                    WriteLn('Para volver al menu presione Enter');
                                    ReadLn;
                                    clrscr;

                                end;
                                
                            3 : begin
                                    TextColor(13);
                                    WriteLn('Top 10 jugadores con mas victorias: ');
                                    WriteLn('');
                                    ImprimeTop10(ArbolJugadores);
                                    WriteLn('');
                                    WriteLn('Para volver al menu presione Enter');
                                    ReadLn;
                                    clrscr;
                                    
                                end;
                                
                            4 : begin
                                    TextColor(4);
                                    gotoxy(11,1) ; WriteLn('==========================================================');  //Advertencia importante para que la experiencia del usuario sea optima
                                    gotoxy(11,2) ; WriteLn('                          Aviso                           ');
                                    gotoxy(11,3) ; WriteLn('==========================================================');
                                    TextColor(13);
                                    gotoxy(8,4) ;  WriteLn(' Antes de jugar tenga en cuenta las siguientes consideraciones:');
                                    TextColor(15);
                                    gotoxy(11,5) ; WriteLn('        1) NO puede usar la ñ, en su lugar use "ni"       ');
                                    gotoxy(11,6) ; WriteLn('      2) Las palabras deben ser escritas en minuscula     ');
                                    gotoxy(11,7) ; WriteLn('      3) Las palabras no deben ser escritas con tildes     ');
                                    gotoxy(11,8) ; WriteLn('                                                          ');
                                    gotoxy(11,9) ; WriteLn('              Presione Enter para continuar               ');
                                    readln;
                                    clrscr;
                                    
                                    
                                    Jugar(ArbolJugadores,ArchJugadores);
                                    WriteLn('');
                                    WriteLn('Para volver al menu presione Enter');
                                    ReadLn;
                                end;
                                
                            5 : begin
                                    BorrarJugador(Arboljugadores,ArchJugadores);
                                    WriteLn('');
                                    WriteLn('Para volver al menu presione Enter');
                                    ReadLn;
                                end;
                                
                            6 :begin
                                Close(ArchJugadores);
                                gotoxy(34,1) ; Writeln('Saliendo');
                                x:=43;
                                delay(200);
                                While x<46 do
                                    begin
                                        gotoxy(X,1) ; WriteLn('.');
                                        x:=x+1;
                                        delay(800);
                                    end;
                                clrscr;
                                Exit;
                            end;
                            
                        end;
                    end;
                clrscr;
            end;
                        
    

    
    
    
end. 
    
    