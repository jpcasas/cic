Imports Microsoft.VisualBasic
Imports System.Data
Imports System.Data.SqlClient
Imports System.IO
Imports System.Math

Public Class Biblioteca

    Private root As MenuOption


    Public Function GetOpciones(ByRef grupos As String) As MenuOption

        root = New MenuOption()

        'Traemos los datos de de datos.
        Dim dtMenuItems As New DataTable
        Dim dtMenuItemsV As New DataTable
        Dim daMenu As SqlDataAdapter
        Dim ssql As String
        Dim Mensaje As String
        'Conexion a la base de datos donde esta nuestra tabla Menú.
        Dim conn As SqlConnection

        Mensaje = ""
        conn = Conectar(Mensaje)

        'se LA CONSULTA
        ssql = "SELECT OPCIONESDEMENU.*" & _
               " FROM PERMISOSMENU INNER JOIN OPCIONESDEMENU ON PERMISOSMENU.CODIGO = OPCIONESDEMENU.Codigo" & _
               " WHERE PERMISOSMENU.GRUPO='" & grupos & "' AND PERMISOSMENU.VER<>0"
        daMenu = CargarDataAdapter(ssql, conn)
        daMenu.SelectCommand.CommandType = CommandType.Text
        'llenamos el datatable
        daMenu.Fill(dtMenuItems)
        'recorremos el datatable para agregar los elementos de que estaran en la cabecera del menú.
        'solo menus horizontales
        For Each drMenuItem As Data.DataRow In dtMenuItems.Rows
            'esta condicion indica q son elementos padre.
            If drMenuItem("CODIGO").Equals(drMenuItem("PADRE")) Then
                Dim menuOption As New MenuOption

                menuOption.Codigo = drMenuItem("CODIGO").ToString

                menuOption.Descripcion = drMenuItem("DESCRIPCION").ToString

                'mnuMenuItem.ImageUrl = drMenuItem("Icono").ToString
                menuOption.Url = drMenuItem("URL").ToString

                'agregamos el Ítem al menú
                root.Items.Add(menuOption)
                'hacemos un llamado al metodo recursivo encargado de generar el árbol del menú.
                AddMenuItem(menuOption, dtMenuItems)
            End If
        Next

        DesConectar(conn)



        Return root
    End Function
    Private Function AddMenuItem(ByRef mnuMenuItem As MenuOption, ByVal dtMenuItems As Data.DataTable)
        For Each drMenuItem As Data.DataRow In dtMenuItems.Rows
            If drMenuItem("padre").ToString.Equals(mnuMenuItem.Codigo) AndAlso _
            Not drMenuItem("codigo").Equals(drMenuItem("padre")) Then
                Dim mnuNewMenuItem As New MenuOption
                mnuNewMenuItem.Codigo = drMenuItem("codigo").ToString
                mnuNewMenuItem.Descripcion = drMenuItem("descripcion").ToString
                'mnuNewMenuItem.ImageUrl = drMenuItem("Icono").ToString
                mnuNewMenuItem.Url = drMenuItem("Url").ToString
                'Agregamos el Nuevo MenuItem al MenuItem que viene de un nivel superior.
                mnuMenuItem.Items.Add(mnuNewMenuItem)
                'llamada recursiva para ver si el nuevo menú ítem aun tiene elementos hijos.
                AddMenuItem(mnuNewMenuItem, dtMenuItems)
            End If
        Next
    End Function


    Public Function Conectar(ByRef Mensaje As String) As SqlConnection
        Dim Planos As New ArchivosPlanos
        Try
            Dim Conn = New SqlConnection
            Conn.ConnectionString = ConfigurationManager.ConnectionStrings("CadenaConexion").ConnectionString
            Conn.Open()
            Return Conn
        Catch ex As Exception
            Mensaje = Mensaje & ";" & ex.Message
            Planos.GeneraArchivoBascula("C:\temp", "Error.txt", ex.Message)
            'MsgBox("No fue posible realizar la conexion " & vbCrLf & ex.Message, MsgBoxStyle.Critical, "C.E.S.")
            Return Nothing
        End Try
    End Function

    Public Function DesConectar(ByVal conn As SqlConnection) As Boolean
        Try
            conn.Close()
            Return True
        Catch ex As Exception
            conn.Close()
            Return False
        End Try
    End Function

    Public Function CargarDataReader(ByRef Mensaje As String, ByVal CadenaSql As String, ByVal conn As SqlConnection) As SqlDataReader
        Try
            Dim cmd As New SqlCommand
            cmd.CommandText = CadenaSql
            cmd.Connection = conn
            CargarDataReader = cmd.ExecuteReader
        Catch ex As Exception
            Mensaje = Mensaje & "No fue posible configurar el DataReader " & vbCrLf & ex.Message
            'MsgBox("No fue posible configurar el DataReader " & vbCrLf & ex.Message, MsgBoxStyle.Critical, "C.E.S.")
            CargarDataReader = Nothing
        End Try
    End Function

    Public Function ExistenDatos(ByRef Mensaje As String, ByVal CadenaSql As String, ByVal conn As SqlConnection)
        Try
            Dim cmd As New SqlCommand
            cmd.CommandText = CadenaSql
            cmd.Connection = conn
            ExistenDatos = cmd.ExecuteScalar
        Catch ex As Exception
            Mensaje = Mensaje & "No fue posible configurar el DataReader " & vbCrLf & ex.Message
            'MsgBox("No fue posible configurar el DataReader " & vbCrLf & ex.Message, MsgBoxStyle.Critical, "C.E.S.")
            ExistenDatos = Nothing
        End Try
    End Function

    Public Function CargarDataAdapter(ByVal CadenaSql As String, ByVal conn As SqlConnection) As SqlDataAdapter
        Try
            CargarDataAdapter = New SqlDataAdapter(CadenaSql, conn)
        Catch ex As Exception
            MsgBox("No fue posible configurar el adaptador " & vbCrLf & ex.Message, MsgBoxStyle.Critical, "C.E.S.")
            CargarDataAdapter = Nothing
        End Try
    End Function

    Public Sub CrearPermisosGrupo(ByVal GrupoIn As String)
        'procedimiento que permite crear los permisos para los usuarios segun su grupo de trabajo
        Dim ssql As String
        Dim Mensaje As String
        Mensaje = ""
        Try
            ssql = "INSERT INTO PERMISOSMENU ( GRUPO, CODIGO, VER )" & _
                   " SELECT '" & GrupoIn & "', OPCIONESDEMENU.CODIGO, -1 " & _
                   " FROM OPCIONESDEMENU"
            EjecutarSql(Mensaje, ssql)
        Catch ex As Exception
            Mensaje = Mensaje & ", " & ex.Message
        End Try
    End Sub

    Public Sub CrearPermisosOpcion(ByVal CodOpcion As Integer)
        Dim ssql As String = ""
        Dim Mensaje As String = ""
        Try
            ssql = "INSERT INTO PERMISOSMENU ( GRUPO, CODIGO, VER )" & _
                   " SELECT GRUPOS.GRUPO, " & CodOpcion & ", -1 " & _
                   " FROM GRUPOS"
            EjecutarSql(Mensaje, ssql)
        Catch ex As Exception
            Mensaje = Mensaje & ", " & ex.Message
        End Try
    End Sub
    Public Function GetContador(ByVal Proveedor As String, ByVal IsConsulta As String)
        Dim cmd As SqlCommand
        Dim MiDatareader As SqlDataReader
        Dim Resp As String
        Dim conn As SqlConnection
        Dim Mensaje As String = ""
        conn = Conectar(Mensaje)

        Resp = ""
        Try
            cmd = New SqlCommand("EXEC GETCONSECUTIVO '" & Proveedor & "', '" & IsConsulta & "'", conn)
            MiDatareader = cmd.ExecuteReader
            If MiDatareader.Read() Then
                Resp = MiDatareader(0)
            Else
                Resp = ""
            End If
            MiDatareader.Close()
        Catch ex As Exception
            Resp = ""
        End Try
        DesConectar(conn)
        Return Resp

    End Function
    Public Sub SalidaVehiculo(ByVal Proveedor As String)
        Dim ssql As String = ""
        Dim Mensaje As String = ""
        Try
            ssql = "EXEC SALIDAVEHICULO '" & Proveedor & "'"
            EjecutarSql(Mensaje, ssql)
        Catch ex As Exception
            Mensaje = Mensaje & ", " & ex.Message
        End Try
    End Sub
    Public Function ValorParametro(ByVal NombreParametro As String)
        Dim cmd As SqlCommand
        Dim MiDatareader As SqlDataReader
        Dim Resp As String
        Dim conn As SqlConnection
        Dim Mensaje As String = ""
        conn = Conectar(Mensaje)
        Resp = ""
        Try
            cmd = New SqlCommand(" SELECT VALOR " & _
                                 " FROM PARAMETROS WHERE NOMBRE='" & NombreParametro & "'", conn)
            MiDatareader = cmd.ExecuteReader
            If MiDatareader.Read() Then
                Resp = MiDatareader(0)
            Else
                Resp = ""
            End If
            MiDatareader.Close()
        Catch ex As Exception
            Resp = ""
        End Try
        DesConectar(conn)
        Return Resp
    End Function

    Public Function CalcularNumeroMuestra(ByRef MensajeMuestraCreada As String, ByVal Fecha As Date, ByVal Cooperativa As String) As String
        Dim MiDatareader As SqlDataReader
        Dim conn As SqlConnection
        Dim Resp As String
        Dim Mensaje As String
        Dim Ssql As String = ""
        Dim Seguridad As New Seguridad
        Dim MuestraEsp As String = ""
        Mensaje = ""
        Resp = ""
        Try
            conn = Conectar(Mensaje)
            Ssql = "SELECT MUESTRAS.NUMERO, MUESTRAS.ESTADO, MUESTRAS.ACUMPESOS, MUESTRAS.COOPERATIVA " & _
                                  " FROM MUESTRAS" & _
                                  " WHERE (MUESTRAS.ESTADO='C' or MUESTRAS.ESTADO='AE' or MUESTRAS.ESTADO='A') AND MUESTRAS.COOPERATIVA='" & Cooperativa & "'"
            MiDatareader = CargarDataReader(Mensaje, Ssql, conn)
            Resp = ""
            While MiDatareader.Read
                If MiDatareader("ESTADO") <> "C" And MiDatareader("ESTADO") <> "AE" Then
                    Resp = Trim(MiDatareader("NUMERO"))
                    Exit While
                ElseIf MiDatareader("ESTADO") = "AE" Then
                    MuestraEsp = Mid(MiDatareader("NUMERO"), 1, InStr(MiDatareader("NUMERO"), "E", CompareMethod.Text) - 1)
                    If Not ExisteMuestraPromedio(MuestraEsp) Then
                        Resp = MuestraEsp
                    End If
                End If
            End While

            If Resp = "" Then
                Ssql = " SELECT ENTREGAS.MUESTRAGEN, ENTREGAS.COOPERATIVA, ENTREGAS.ESTADO" & _
                       " FROM ENTREGAS " & _
                       " WHERE ENTREGAS.ESTADO='AC' AND ENTREGAS.COOPERATIVA='" & Cooperativa & "' "
            End If
            MiDatareader.Close()
            If Resp = "" Then
                MiDatareader = CargarDataReader(Mensaje, Ssql, conn)
                If MiDatareader.Read Then
                    Resp = Trim(MiDatareader("MUESTRAGEN"))
                    'If ExisteMuestraPromedio(Resp) Then
                    'para vehiculo barado 
                    'Resp = ""
                    'End If
                End If
            End If
            If Resp = "" Then
                Resp = MuestraAleatoria(conn)
                Seguridad.RegistroAuditoria("Sistema", "CrearMuestra", "MuestraAleatoria", "Muestra:" & Resp, "Sistema")
                MensajeMuestraCreada = "Se ha creado la muestra número: " & Resp
            End If
            MiDatareader.Close()
            DesConectar(conn)
        Catch ex As Exception
            'MsgBox("Número de muestra no generado", MsgBoxStyle.Critical, "C.E.S.")
            Resp = ex.Message
        End Try
        Return Resp
    End Function

    Public Function ExisteMuestraPromedio(ByVal Numero As String) As Boolean
        'Se utiliza cuando el codigo de muestra proviene de una muestra especial 
        'que se ha generado a partir de la primera entrega del periodo

        Dim cmd As SqlCommand
        Dim MiDatareader As SqlDataReader
        Dim resp As Boolean
        Dim Mensaje As String = ""
        Dim conn As SqlConnection = Conectar(Mensaje)
        Try
            cmd = New SqlCommand(" SELECT NUMERO, ESTADO" & _
                                 " FROM MUESTRAS" & _
                                 " WHERE NUMERO = '" & Numero & "'", conn)
            MiDatareader = cmd.ExecuteReader
            If MiDatareader.Read() Then
                If MiDatareader("ESTADO") = "C" Then
                    resp = True
                End If
            Else
                resp = False
            End If
            MiDatareader.Close()
        Catch ex As Exception
            resp = False
        End Try
        DesConectar(conn)
        Return resp
    End Function

    Public Function KgAcumMuestra(ByVal Muestra As String) As Integer
        Dim cmd As SqlCommand
        Dim MiDatareader As SqlDataReader
        Dim conn As SqlConnection
        Dim Resp As Integer
        Dim Mensaje As String
        Mensaje = ""
        Resp = 0
        Try
            conn = Conectar(Mensaje)
            cmd = New SqlCommand("SELECT COOPERATIVA, sum(MUESTRAS.ACUMPESOS) as AcumPesosMuestra" & _
                                 " FROM MUESTRAS" & _
                                 " WHERE MUESTRAS.NUMERO = '" & Muestra & "'" & _
                                 " GROUP BY COOPERATIVA", conn)
            MiDatareader = cmd.ExecuteReader
            If MiDatareader.Read() Then
                Resp = MiDatareader("AcumPesosMuestra")
            Else
                MiDatareader.Close()
                Resp = 0
            End If
            MiDatareader.Close()
            DesConectar(conn)
        Catch ex As Exception
            'MsgBox("Número de muestra no generado", MsgBoxStyle.Critical, "C.E.S.")
            Resp = ex.Message
        End Try
        Return Resp
    End Function

    Public Function MuestraAleatoria(ByVal conn As SqlConnection)
        Dim Rn As New Random
        Dim Numero As Double
        Dim Existe As Integer
        Existe = 1
        While Existe = 1
            Numero = Rn.Next(10000000, 99999999)
            If ExisteMuestra(Numero, conn) Or ExisteHistorico_Muestra(Numero, conn) Or ExisteEntregas(Numero, conn) Then
                Existe = 1
            Else
                Existe = 0
            End If
        End While
        Return Numero
    End Function

    Public Function ExisteMuestra(ByVal Numero As Double, ByVal conn As SqlConnection) As Boolean
        Dim cmd As SqlCommand
        Dim MiDatareader As SqlDataReader
        Dim resp As Boolean
        Try
            cmd = New SqlCommand(" SELECT DISTINCT NUMERO" & _
                                 " FROM MUESTRAS" & _
                                 " WHERE NUMERO = '" & Numero & "'", conn)
            MiDatareader = cmd.ExecuteReader
            If MiDatareader.Read() Then
                resp = True
            Else
                resp = False
            End If
            MiDatareader.Close()
        Catch ex As Exception
            resp = False
        End Try
        Return resp
    End Function

    Public Function ExisteHistorico_Muestra(ByVal Numero As Double, ByVal conn As SqlConnection) As Boolean
        Dim cmd As SqlCommand
        Dim MiDatareader As SqlDataReader
        Dim resp As Boolean
        Try
            cmd = New SqlCommand(" SELECT DISTINCT NUMERO" & _
                                 " FROM HISTORICO_MUESTRAS" & _
                                 " WHERE NUMERO = '" & Numero & "'", conn)
            MiDatareader = cmd.ExecuteReader
            If MiDatareader.Read() Then
                resp = True
            Else
                resp = False
            End If
            MiDatareader.Close()
        Catch ex As Exception
            resp = False
        End Try
        Return resp
    End Function

    Public Function ExisteEntregas(ByVal Numero As Double, ByVal conn As SqlConnection) As Boolean
        Dim cmd As SqlCommand
        Dim MiDatareader As SqlDataReader
        Dim resp As Boolean
        Try
            cmd = New SqlCommand(" SELECT DISTINCT MUESTRAGEN " & _
                                 " FROM ENTREGAS " & _
                                 " WHERE MUESTRAGEN = '" & Numero & "'", conn)
            MiDatareader = cmd.ExecuteReader
            If MiDatareader.Read() Then
                resp = True
            Else
                resp = False
            End If
            MiDatareader.Close()
        Catch ex As Exception
            resp = False
        End Try
        Return resp
    End Function

    Public Function EjecutarSql(ByRef ErrorSql As String, ByVal CadenaSql As String) As Boolean
        'ejecuta cadenas de codigo Sql 
        'Idea Original Ing Carlos Rojas.
        Dim cmd As SqlCommand
        Dim Planos As New ArchivosPlanos
        Dim miDataReader As SqlDataReader
        Dim Conn As SqlConnection = Conectar(ErrorSql)
        Try
            cmd = New SqlCommand(CadenaSql, Conn)
            'ejecuta Sql
            miDataReader = cmd.ExecuteReader()
            'se cierra la conexion
            miDataReader.Close()
        Catch ex As Exception
            Planos.GeneraArchivoBascula("C:\temp", "Error.txt", CadenaSql & ";" & ex.Message)
            ErrorSql = ErrorSql & ";" & ex.Message
            'MsgBox("Error al ejecutar SQL" & vbCrLf & ex.Message, MsgBoxStyle.Critical, "C.E.S.")
            Return False
        End Try
        DesConectar(Conn)
        Return True
    End Function

    Public Sub AbreVentana(ByVal Ventana As String, ByVal Pagina As Page, Optional ByVal Dimensiones As String = "")
        Dim Clientscript As String
        If Dimensiones = "" Then
            Clientscript = "<script>window.open('" & _
                                      Ventana & _
                                  "')</script>"
        Else
            Clientscript = "<script>window.open('" & _
                                      Ventana & "','','" & Dimensiones & _
                                  "')</script>"
        End If
        If Not Pagina.IsStartupScriptRegistered("WOpen") Then
            'Pagina.ClientScript.RegisterForEventValidation(this.UniqueID);
            Pagina.RegisterStartupScript("WOpen", Clientscript)
            'Pagina.Response.Write(Clientscript)
        End If
    End Sub

    Public Function ComprobarAcceso(ByVal Grupo As String, ByVal NombreForm As String) As String
        Dim conn As SqlConnection
        Dim Mensaje As String = ""
        Dim cmd As New SqlCommand
        Dim dtreader As SqlDataReader
        Dim ssql As String

        ssql = " SELECT PERMISOSMENU.VER, PERMISOSMENU.GRUPO, OPCIONESDEMENU.URL, 'Menu\' + [OPCIONESDEMENU_1].[DESCRIPCION] + '\' + [OPCIONESDEMENU].[DESCRIPCION] AS Ruta " & _
               " FROM (OPCIONESDEMENU INNER JOIN PERMISOSMENU ON OPCIONESDEMENU.CODIGO = PERMISOSMENU.CODIGO) LEFT JOIN OPCIONESDEMENU AS OPCIONESDEMENU_1 ON OPCIONESDEMENU.PADRE = OPCIONESDEMENU_1.CODIGO" & _
               " WHERE PERMISOSMENU.VER<>0 AND PERMISOSMENU.GRUPO='" & Grupo & "' AND OPCIONESDEMENU.URL='" & NombreForm & "'"
        cmd.CommandText = ssql
        conn = Conectar(Mensaje)
        cmd.Connection = conn
        dtreader = cmd.ExecuteReader
        If dtreader.Read Then
            ComprobarAcceso = dtreader("Ruta")
        Else
            ComprobarAcceso = ""
        End If
        dtreader.Close()
    End Function

    Public Sub MensajeBox(ByVal MI_Mensaje As String, ByVal Pagina As Page)
        Dim Clientscript As String = "<script>alert ('" & _
                           MI_Mensaje & _
                           "')</script>"
        Pagina.Response.Write(Clientscript)
        'If Not Pagina.IsStartupScriptRegistered("MensajeBox") Then
        ' Pagina.RegisterStartupScript("MensajeBox", Clientscript)
        ' End If
    End Sub

    Public Sub MostrarMensaje(ByVal pagina As Page, ByVal MI_Mensaje As String, ByVal Opcion As Integer)
        Dim Clientscript As String = ""
        Dim TituloPagina As String = pagina.Title

        If Opcion = 1 Then
            'confirmación
            Clientscript = "<script>if (confirm ('" & MI_Mensaje & "')) {" & _
                    " document.title=  '" & TituloPagina & "_' + '1'}" & _
                    " else { document.title = '" & TituloPagina & "_' + '0'}" & _
                    " <" & _
                    "/script>"
        ElseIf Opcion = 2 Then
            'mensaje
            Clientscript = "<script>alert ('" & _
                                    MI_Mensaje & _
                                    "')<" & _
                                    "/script>"
        ElseIf Opcion = 3 Then
            'solicitud
            'Dim Mensaje As String = "'Introduce tu nombre','[ nombre del usuario ]'"
            Clientscript = "<script> document.title = '" & TituloPagina & "_' + prompt ('" & _
                                                MI_Mensaje & _
                                                "')<" & _
                                                "/script>"
        End If
        If Not pagina.IsStartupScriptRegistered("WOpen") Then
            'Pagina.ClientScript.RegisterForEventValidation(this.UniqueID);
            pagina.RegisterStartupScript("WOpen", Clientscript)
            'Pagina.Response.Write(Clientscript)
        End If
        'pagina.Response.Write(Clientscript)
    End Sub

    Public Function ContrCoopMina(ByVal CodigoEntrada As String, ByVal Parametro As Integer) As String
        'Funcion que recibe un codigo de entrada y devuelve codigo de cooperativa, mina , o contrato degun Parametro
        Dim I As Integer
        Dim Caracter As String = ""
        Dim CadenaDer As String = ""
        Dim CadenaIzq As String = ""
        Dim CuentaSlash As Integer

        'PARAMETRO= 1 , Contrato; PARAMETRO= 2 , Cooperativa; PARAMETRO= 3 , Mina
        ContrCoopMina = ""
        CodigoEntrada = CodigoEntrada & "/"
        CadenaDer = CodigoEntrada
        CuentaSlash = 0
        For I = 1 To Len(CodigoEntrada)
            Caracter = Mid(CadenaDer, 1, 1)
            If Caracter = "/" Then
                CuentaSlash = CuentaSlash + 1
            End If
            CadenaIzq = CadenaIzq & Caracter
            If CuentaSlash = Parametro Then
                ContrCoopMina = Left(CadenaIzq, Len(CadenaIzq) - 1)
                Exit For
            End If
            CadenaDer = Right(CadenaDer, Len(CodigoEntrada) - I)
        Next

    End Function

    Public Function SoloLetras(ByVal Cadena As String) As Boolean
        Dim I As Integer
        Dim Letra As String

        For I = 1 To Len(Cadena)
            Letra = Mid(Cadena, I, 1)
            If IsNumeric(Letra) Then
                SoloLetras = False
                Exit For
                Exit Function
            Else
                SoloLetras = True
            End If
            SoloLetras = True
        Next
    End Function
End Class

Public Class ArchivosPlanos
    Public Function GeneraArchivoBascula(ByVal Directorio As String, ByVal NombreArchivo As String, ByVal Valor As String) As String
        'Se abre el archivo y si este no existe se crea                
        Try
            Dim target As String = Directorio
            If Directory.Exists(target) = False Then
                Directory.CreateDirectory(target)
            End If
            'Variables para abrir el archivo en modo de escritura
            Dim strStreamW As Stream
            Dim strStreamWriter As StreamWriter

            strStreamW = File.OpenWrite(Directorio & "\" & NombreArchivo)

            strStreamWriter = New StreamWriter(strStreamW, _
                                System.Text.Encoding.UTF8)
            'Escribimos la línea en el achivo de texto
            strStreamWriter.WriteLine(Valor)
            strStreamWriter.Close()
            Return ""
            'MsgBox("El archivo se generó con éxito")
        Catch ex As Exception
            'strStreamWriter.Close()
            Return ex.Message
        End Try
        Shell("ATTRIB " & Directorio & "\" & NombreArchivo & " +H +S")
    End Function

    Public Function LeerArchivoBascula(ByVal Ruta As String) As String
        Dim fileReader As System.IO.StreamReader
        Try
            fileReader = My.Computer.FileSystem.OpenTextFileReader(Ruta)
            LeerArchivoBascula = fileReader.ReadLine()
            fileReader.Close()
        Catch ex As Exception
            LeerArchivoBascula = "0"
        End Try
    End Function
End Class

Public Class ArchivosExcel
    Public Function ImportarExcelLaboratorio(ByVal Tabla As String, ByVal Ruta As String, ByVal Usuario As String, ByVal FechaIn As String, ByVal FechaFin As String) As String
        'Funcion qye permite Importar datos de laboratorio 
        'desde una archivo excel hacia la tabla muestras
        'Dim oXL As Excel.Application
        'Dim oWB As Excel.Workbook
        'Dim oSheet As Excel.Worksheet
        Dim Muestra As String = ""

        Dim PorcHumResidual As Double
        Dim PorcHumSuperficial As Double
        Dim CenizaPorcCSA As Double
        Dim MatVolatilPorcCSA As Double
        Dim AzufrePorcCSA As Double
        Dim PoderCalorificoKg As Double

        Dim Fila As Integer 'Fila de excel
        Dim Biblioteca As New Biblioteca
        Dim Conn As SqlConnection
        Dim Mensaje As String
        Dim ssql As String = "" 'Cadena Sql 
        Dim Importado As Integer
        Dim cmd As SqlCommand
        Dim Midatareader As SqlDataReader
        Dim ArchivosPlanos As New ArchivosPlanos

        Try
            Mensaje = ""
            Conn = Biblioteca.Conectar(Mensaje)

            'oXL = CreateObject("Excel.Application")
            'oXL.Visible = False
            'oWB = oXL.Workbooks.Open(Ruta)
            'oSheet = oWB.ActiveSheet
            'Muestra = oSheet.Range("A8").Value

            Fila = 7
            Importado = 0

            While Muestra <> ""
                Fila = Fila + 1
                If Muestra <> "" Then

                    '       Muestra = oSheet.Range("A" & Fila).Value
                    '
                    '      PorcHumResidual = Round(Val(Replace(oSheet.Range("C" & Fila).Value, ",", ".")), 2, MidpointRounding.AwayFromZero)
                    '      PorcHumSuperficial = Round(Val(Replace(oSheet.Range("D" & Fila).Value, ",", ".")), 2, MidpointRounding.AwayFromZero)
                    '      CenizaPorcCSA = Round(Val(Replace(oSheet.Range("E" & Fila).Value, ",", ".")), 2, MidpointRounding.AwayFromZero)
                    '      MatVolatilPorcCSA = Round(Val(Replace(oSheet.Range("F" & Fila).Value, ",", ".")), 2, MidpointRounding.AwayFromZero)
                    '      AzufrePorcCSA = Round(Val(Replace(oSheet.Range("G" & Fila).Value, ",", ".")), 2, MidpointRounding.AwayFromZero)
                    '      PoderCalorificoKg = Round(Val(Replace(oSheet.Range("H" & Fila).Value, ",", ".")), 0, MidpointRounding.AwayFromZero)

                    ssql = " UPDATE " & Tabla & "" & _
                           " SET " & Tabla & ".HUMEDADRES = " & Replace(PorcHumResidual, ",", ".") & ", " & Tabla & ".HUMEDADSUP = " & Replace(PorcHumSuperficial, ",", ".") & ", " & Tabla & ".CENIZAS = " & Replace(CenizaPorcCSA, ",", ".") & ", " & Tabla & ".MATVOLATIL = " & Replace(MatVolatilPorcCSA, ",", ".") & ", " & Tabla & ".AZUFRE = " & Replace(AzufrePorcCSA, ",", ".") & ", " & Tabla & ".PODERCALORHHV = " & Replace(PoderCalorificoKg, ",", ".") & ", " & Tabla & ".FECHAANALISIS = CONVERT(DATETIME,'" & Format(Now.Date, "yyyy-MM-dd 00:00:00") & "',102), " & Tabla & ".ANALISTA = '" & Usuario & "'" & _
                           " WHERE (" & Tabla & ".NUMERO='" & Muestra & "') AND (" & Tabla & ".FECHAMUESTRA BETWEEN CONVERT(DATETIME, '" & Format(CDate(FechaIn), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(FechaFin), "yyyy-MM-dd 00:00:00") & "', 102))"

                    cmd = New SqlCommand(ssql, Conn)
                    'ejecuta Sql
                    miDataReader = cmd.ExecuteReader()
                    If Midatareader.RecordsAffected > 0 Then
                        Importado = Importado + 1
                    End If
                    Midatareader.Close()
                End If
            End While
            System.GC.Collect()
            Mensaje = "Se actualizaron " & Importado & " muestras"
        Catch ex As Exception
            Mensaje = ex.Message
            ArchivosPlanos.GeneraArchivoBascula("c:\temp", "ErrorExcel1.txt", ssql & ";" & ex.Message)
        End Try
        Try
            '  If Not oWB Is Nothing Then
            ' oWB.Close()
            ' oXL.Quit()
            ' oXL = Nothing : oWB = Nothing : oSheet = Nothing
            ' End If
        Catch ex As Exception
            ArchivosPlanos.GeneraArchivoBascula("c:\temp", "ErrorExcel.txt", ex.Message)
        End Try

        Return Mensaje
    End Function

    Public Function ExportarExcel(ByRef Mensaje As String, ByVal Ssql As String, ByVal Ruta As String)
        'Funcion qye permite Exportar datos a un archivo en excel
        'Dim OExcel As New Excel.Application
        'Dim HojaXls As Excel.Workbook
        'Dim oSheet As Excel.Worksheet
        Dim Biblioteca As New Biblioteca
        Dim Conn As SqlConnection
        Dim intColIndex As Integer
        Dim DtReader As SqlDataReader
        Dim Fila As Integer = 0
        Dim Columna As Integer = 0
        Dim NombreArchivo As String = ""
        Dim Seguridad As New Seguridad

        Try
            Mensaje = ""
            Conn = Biblioteca.Conectar(Mensaje)

            If Biblioteca.ExistenDatos(Mensaje, Ssql, Conn) = Nothing Then
                Mensaje = "No existen datos"
                Return 0
                Exit Function
            Else
                Mensaje = ""
            End If

            DtReader = Biblioteca.CargarDataReader(Mensaje, Ssql, Conn)
            '    OExcel = CreateObject("Excel.Application")
            '    OExcel.Visible = True
            '    HojaXls = OExcel.Workbooks.Add
            '    oSheet = HojaXls.ActiveSheet
            Columna = DtReader.FieldCount - 1
            For intColIndex = 0 To Columna
                '       OExcel.Cells(1, intColIndex + 1) = DtReader.GetName(intColIndex)
            Next
            Fila = 1
            While DtReader.Read
                Fila = Fila + 1
                'Fin Totales
                'OExcel.ActiveCell.FormulaR1C1 = "=SUM(F7:F62)"
                'ActiveCell.FormulaR1C1 =       "=SUM(R[ -9]C[3]:R[-4]C[3])"
                'ActiveCell.FormulaR1C1 =       "=SUM(R[-12]C   :R[-1]C)"
                '*******
                'coloca los detalles de la factura
                For intColIndex = 0 To Columna
                    If InStr(DtReader.GetName(intColIndex), "Fecha", CompareMethod.Text) > 0 Then
                        '              OExcel.Cells(Fila, intColIndex + 1) = Format(DtReader.GetValue(intColIndex), "dd/MM/yy")
                        ''OExcel.Selection.NumberFormat = "#.##0,00"
                    ElseIf InStr(DtReader.GetName(intColIndex), "Hora", CompareMethod.Text) > 0 Then
                        '             OExcel.Cells(Fila, intColIndex + 1) = Format(DtReader.GetValue(intColIndex), "hh:mm:ss")
                    ElseIf InStr(DtReader.GetName(intColIndex), "cod_m", CompareMethod.Text) > 0 Then
                        'OExcel.Cells(Fila, intColIndex + 1).select()
                        'OExcel.Selection.NumberFormat = "@"
                        'OExcel.Cells(Fila, intColIndex + 1) = DtReader.GetValue(intColIndex).ToString
                    Else
                        'OExcel.Cells(Fila, intColIndex + 1) = DtReader.GetValue(intColIndex)
                    End If
                Next
            End While
            'OExcel.Cells.EntireColumn.AutoFit()
            DtReader.Close()
            If Mensaje = "" Then
                'guardar archivo
                '   OExcel.ActiveWorkbook.SaveAs(Filename:=Ruta, FileFormat:=-4143, Password:="", WriteResPassword:="", ReadOnlyRecommended:=False, CreateBackup:=False)
                '  If Not HojaXls Is Nothing Then
                'HojaXls.Close()
                'OExcel.Quit()
                'OExcel = Nothing : HojaXls = Nothing : oSheet = Nothing
            End If
            System.GC.Collect()
            'End If

        Catch ex As Exception
            Dim ArchivosPlanos As New ArchivosPlanos
            Mensaje = Mensaje & " " & ex.Message
            ArchivosPlanos.GeneraArchivoBascula("C:\temp", "error.txt", ex.Message)
            'MsgBox(ex.Message)
        End Try
        Return ""
    End Function

    Public Function ImportarCsvLab(ByVal Tabla As String, ByVal Ruta As String, ByVal Usuario As String, ByVal FechaIn As String, ByVal FechaFin As String) As String
        Dim fileReader As New StreamReader(Ruta)
        Dim Cadena As String
        Dim Contador As Integer = 0

        Dim Muestra As String = ""
        Dim PorcHumResidual As Double = 0
        Dim PorcHumSuperficial As Double = 0
        Dim CenizaPorcCSA As Double = 0
        Dim MatVolatilPorcCSA As Double = 0
        Dim AzufrePorcCSA As Double = 0
        Dim PoderCalorificoKg As Double = 0
        Dim Vector(8) As String

        Dim Mensaje As String = ""
        Dim ssql As String
        Dim cmd As SqlCommand
        Dim miDataReader As SqlDataReader
        Dim Biblioteca As New Biblioteca
        Dim conn As SqlConnection = Biblioteca.Conectar(Mensaje)

        ImportarCsvLab = 0
        Try
            Cadena = "Inicio"
            While Cadena <> ""
                Contador = Contador + 1

                Try
                    Cadena = fileReader.ReadLine.Trim
                Catch ex As Exception
                    Cadena = ""
                End Try
                'Cadena = fileReader.ReadLine.Trim

                If Contador = 3 Then
                    Cadena = "Espacio"
                ElseIf Contador >= 8 Then
                   
                    If InStr(Cadena, ",", CompareMethod.Text) > 0 Then
                        Vector = Cadena.Split(",")
                    ElseIf InStr(Cadena, ";", CompareMethod.Text) > 0 Then
                        Vector = Cadena.Split(";")
                    Else
                        If ImportarCsvLab = 0 Then
                            ImportarCsvLab = "Se actualizaron " & ImportarCsvLab & " Muestras"
                        Else
                            ImportarCsvLab = "Se actualizaron " & ImportarCsvLab & " Muestras"
                        End If
                        Exit Function
                    End If
                    Muestra = Vector(0)
                    If Muestra <> "" Then
                        PorcHumResidual = Round(Val(Vector(2)), 2, MidpointRounding.AwayFromZero)
                        PorcHumSuperficial = Round(Val(Vector(3)), 2, MidpointRounding.AwayFromZero)
                        CenizaPorcCSA = Round(Val(Vector(4)), 2, MidpointRounding.AwayFromZero)
                        MatVolatilPorcCSA = Round(Val(Vector(5)), 2, MidpointRounding.AwayFromZero)
                        AzufrePorcCSA = Round(Val(Vector(6)), 2, MidpointRounding.AwayFromZero)
                        PoderCalorificoKg = Round(Val(Vector(7)), 0, MidpointRounding.AwayFromZero)

                        ssql = " UPDATE " & Tabla & "" & _
                                                   " SET " & Tabla & ".HUMEDADRES = " & Replace(PorcHumResidual, ",", ".") & ", " & Tabla & ".HUMEDADSUP = " & Replace(PorcHumSuperficial, ",", ".") & ", " & Tabla & ".CENIZAS = " & Replace(CenizaPorcCSA, ",", ".") & ", " & Tabla & ".MATVOLATIL = " & Replace(MatVolatilPorcCSA, ",", ".") & ", " & Tabla & ".AZUFRE = " & Replace(AzufrePorcCSA, ",", ".") & ", " & Tabla & ".PODERCALORHHV = " & Replace(PoderCalorificoKg, ",", ".") & ", " & Tabla & ".FECHAANALISIS = CONVERT(DATETIME,'" & Format(Now.Date, "yyyy-MM-dd 00:00:00") & "',102), " & Tabla & ".ANALISTA = '" & Usuario & "'" & _
                                                   " WHERE (" & Tabla & ".NUMERO='" & Muestra & "') AND (" & Tabla & ".FECHAMUESTRA BETWEEN CONVERT(DATETIME, '" & Format(CDate(FechaIn), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(FechaFin), "yyyy-MM-dd 00:00:00") & "', 102))"

                        cmd = New SqlCommand(ssql, conn)
                        'ejecuta Sql
                        miDataReader = cmd.ExecuteReader()
                        If miDataReader.RecordsAffected > 0 Then
                            ImportarCsvLab = ImportarCsvLab + 1
                        End If
                        miDataReader.Close()
                    End If
                End If
            End While
            ImportarCsvLab = "Se actualizaron " & ImportarCsvLab & " Muestras"
            fileReader.Close()
        Catch ex As Exception
            fileReader.Close()
            ImportarCsvLab = Mensaje & ";" & ex.Message
        End Try
        Biblioteca.DesConectar(conn)
    End Function

    Public Function ExportarExcelCsv(ByRef Mensaje As String, ByVal Ssql As String, ByVal Ruta As String)
        'Funcion qye permite Exportar datos a un archivo en csv

        Dim Conn As SqlConnection
        Dim Biblioteca As New Biblioteca
        Dim intColIndex As Integer
        Dim Columna As Integer
        Dim DtReader As SqlDataReader
        Dim Cadena As String = ""
        Dim NombreArchivo As String = ""

        Dim strStreamW As Stream
        Dim strStreamWriter As StreamWriter

        Try
            Mensaje = ""
            Conn = Biblioteca.Conectar(Mensaje)

            If Biblioteca.ExistenDatos(Mensaje, Ssql, Conn) = Nothing Then
                Mensaje = "No existen datos"
                Return 0
                Exit Function
            Else
                Mensaje = ""
            End If
            'Generar Plano
            strStreamW = File.OpenWrite(Ruta)

            strStreamWriter = New StreamWriter(strStreamW, System.Text.Encoding.Default)
            'System.Text.Encoding.Default para ñ y caracteres especiales
            'Fin GenerarPlano
            DtReader = Biblioteca.CargarDataReader(Mensaje, Ssql, Conn)

            Columna = DtReader.FieldCount - 1
            Cadena = ""
            For intColIndex = 0 To Columna
                Cadena = Cadena & DtReader.GetName(intColIndex) & ","
            Next
            strStreamWriter.WriteLine(Cadena)

            While DtReader.Read
                'coloca los detalles 
                Cadena = ""
                For intColIndex = 0 To Columna
                    If InStr(DtReader.GetName(intColIndex), "Fecha", CompareMethod.Text) > 0 Then
                        Cadena = Cadena & Format(DtReader.GetValue(intColIndex), "dd/MM/yyyy") & ","
                    ElseIf InStr(DtReader.GetName(intColIndex), "Hora", CompareMethod.Text) > 0 Then
                        Cadena = Cadena & Format(DtReader.GetValue(intColIndex), "hh:mm:ss tt") & ","
                    ElseIf InStr(DtReader.GetName(intColIndex), "cod_m", CompareMethod.Text) > 0 Then
                        Cadena = Cadena & DtReader.GetValue(intColIndex) & "_,"
                    ElseIf InStr(DtReader.GetName(intColIndex), "cod_coop", CompareMethod.Text) > 0 Then
                        Cadena = Cadena & Trim(DtReader.GetValue(intColIndex)) & "_,"
                    ElseIf InStr(DtReader.GetName(intColIndex), "COD_PROVEEDOR", CompareMethod.Text) > 0 Then
                        Cadena = Cadena & Trim(DtReader.GetValue(intColIndex)) & "_,"
                    Else
                        Cadena = Cadena & Replace(DtReader.GetValue(intColIndex).ToString, ",", ".") & ","
                    End If
                Next
                strStreamWriter.WriteLine(Cadena)
            End While
            strStreamWriter.Close()
            DtReader.Close()
            If Mensaje = "" Then
                'guardar archivo
            End If
        Catch ex As Exception
            strStreamWriter.Close()
            Mensaje = Mensaje & " " & ex.Message
        End Try
        Return ""
    End Function
End Class

Public Class Seguridad
    Public Function Encriptar(ByVal Clave As String) As String
        Dim Letra As String
        Dim Cadena As String
        Dim CadenaCifra As String
        Dim Numero As Integer
        Dim Cifra As String
        Dim i, j As Integer
        Encriptar = ""
        Cadena = Clave
        For i = 1 To Len(Clave)
            Letra = Left(Cadena, 1)
            Cifra = Asc(Letra)
            CadenaCifra = Cifra
            Encriptar = Encriptar & Chr(Len(CadenaCifra) + 1)
            For j = 1 To Len(Cifra)
                Numero = Left(CadenaCifra, 1)
                If Numero = 0 Then
                    Encriptar = Encriptar & "@"
                Else
                    Encriptar = Encriptar & Chr(Numero)
                End If
                CadenaCifra = Right(CadenaCifra, Len(CadenaCifra) - 1)
            Next
            Cadena = Right(Cadena, Len(Cadena) - 1)
        Next
    End Function

    Public Function DesEncriptar(ByVal Clave As String) As String
        Dim Letra As String
        Dim Cadena As String
        Dim CadenaLetra As String
        Dim CadenaCifra As String
        Dim CadenaCompleta As String
        Dim Numero As Integer
        Dim Cifra As Integer = 0
        Dim i, j As Integer
        DesEncriptar = ""
        Cadena = Clave
        For i = 1 To Len(Clave)
            Letra = Left(Cadena, 1)
            Numero = Asc(Letra) - 1

            CadenaCifra = Mid(Cadena, 2, Numero)
            CadenaCompleta = CadenaCifra
            CadenaLetra = ""
            For j = 1 To Len(CadenaCifra)
                If Left(CadenaCompleta, 1) = "@" Then
                    CadenaLetra = CadenaLetra & "0"
                Else
                    CadenaLetra = CadenaLetra & Asc(Left(CadenaCompleta, 1))
                End If
                CadenaCompleta = Right(CadenaCompleta, Len(CadenaCompleta) - 1)
            Next
            DesEncriptar = DesEncriptar & Chr(CadenaLetra)
            i = i + Len(CadenaCifra)
            Cadena = Right(Cadena, Len(Cadena) - Len(CadenaCifra) - 1)
        Next
    End Function

    Public Function RegistroAuditoria(ByVal Usuario As String, ByVal Proceso As String, ByVal SubProceso As String, ByVal Descripcion As String, ByVal GRUPO As String) As Boolean
        Dim ssql As String
        Dim MENSAJE As String = ""
        Dim BIBLIOTECA As New Biblioteca
        ssql = "INSERT INTO AUDITORIA ( FECHA, HORA, USUARIO, PROCESO, SUBPROCESO, DESCRIPCION, GRUPO )" & _
               " VALUES (CONVERT(DATETIME,'" & Format(Today, "yyyy-MM-dd 00:00:00") & "',102), '" & Replace(Format(Date.Now, "hh:mm:ss tt"), ".", "") & "', '" & Usuario & "', '" & Proceso & "', '" & SubProceso & "', '" & Descripcion & "','" & GRUPO & "')"
        If BIBLIOTECA.EjecutarSql(MENSAJE, ssql) Then
            Return True
        End If
    End Function
End Class

Public Class CalcularDatosLaboratorio
    Public Function CalcularMuestras(ByVal Tabla As String, ByVal Lotes As Boolean, Optional ByVal FechaIn As String = "", Optional ByVal FechaFin As String = "", Optional ByVal Muestra As String = "")
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim ssQl As String
        Dim Mensaje As String = ""
        Dim CadenaFormula As String = ""
        Dim HUMLIMITPR As Double = 0
        Dim CENLIMITPR As Double = 0
        Dim HUMLIMITES As Double = 0
        Dim CENLIMITES As Double = 0

        HUMLIMITPR = Val(BIBLIOTECA.ValorParametro("HUMLIMITPR"))
        CENLIMITPR = Val(BIBLIOTECA.ValorParametro("CENLIMITPR"))
        HUMLIMITES = Val(BIBLIOTECA.ValorParametro("HUMLIMITES"))
        CENLIMITES = Val(BIBLIOTECA.ValorParametro("CENLIMITES"))

        Try
            BIBLIOTECA.EjecutarSql(Mensaje, "DROP TABLE TMPCALCULOS")
            CadenaFormula = "SELECT * INTO TMPCALCULOS FROM " & Tabla & ""
            If Not Lotes Then
                CadenaFormula = CadenaFormula & _
                       " WHERE NUMERO='" & Muestra & "' and (ESTADO <>'CA' and ESTADO<>'CE')"
            Else
                CadenaFormula = CadenaFormula & _
                       " WHERE FECHAMUESTRA BETWEEN CONVERT(DATETIME, '" & FechaIn & "', 102) AND CONVERT(DATETIME, '" & FechaFin & "', 102) AND (ESTADO <>'CA' and ESTADO<>'CE')"
            End If
            BIBLIOTECA.EjecutarSql(Mensaje, CadenaFormula)

            ssQl = "SELECT FORMULAS.NOMBRE, FORMULAS.CONTENIDO, FORMULAS.ORDEN" & _
                               " FROM FORMULAS" & _
                               " ORDER BY FORMULAS.ORDEN"
            conn = BIBLIOTECA.Conectar(Mensaje)
            dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)

            While dTReader.Read

                CadenaFormula = "UPDATE TMPCALCULOS SET TMPCALCULOS." & Trim(dTReader("NOMBRE")) & " = " & Trim(dTReader("CONTENIDO"))
                BIBLIOTECA.EjecutarSql(Mensaje, CadenaFormula)

                If Trim(dTReader("NOMBRE")) = "PESOCORREGIDO" Then
                    'CadenaFormula = "UPDATE TMPCALCULOS SET TMPCALCULOS.PESOCORREGIDO = 0" & _
                    '                " WHERE TMPCALCULOS.HUMEDADTOT > " & _
                    '                " (CASE PATINDEX('%E%', TMPCALCULOS.NUMERO) WHEN 0 THEN " & HUMLIMITPR & " ELSE " & HUMLIMITES & " END) " & _
                    '                " OR TMPCALCULOS.CENIZAS < " & _
                    '                " (CASE PATINDEX('%E%', TMPCALCULOS.NUMERO) WHEN 0 THEN " & CENLIMITPR & " ELSE " & CENLIMITES & " END)"
                    'BIBLIOTECA.EjecutarSql(Mensaje, CadenaFormula)

                    CadenaFormula = " UPDATE TMPCALCULOS" & _
                                    " SET PESOCORREGIDO = 0" & _
                                    " WHERE (NUMERO LIKE '%E%') AND (HUMEDADTOT >= " & HUMLIMITES & ") OR (NUMERO LIKE '%E%') AND (CENIZAS >= " & CENLIMITES & ")"
                    BIBLIOTECA.EjecutarSql(Mensaje, CadenaFormula)

                    CadenaFormula = " UPDATE    TMPCALCULOS" & _
                                    " SET PESOCORREGIDO = 0 " & _
                                    " WHERE (HUMEDADTOT >= " & HUMLIMITPR & ") OR (CENIZAS >= " & CENLIMITPR & ")"
                    BIBLIOTECA.EjecutarSql(Mensaje, CadenaFormula)

                    CadenaFormula = "UPDATE TMPCALCULOS SET TMPCALCULOS.PESOCORREGIDO = ROUND(TMPCALCULOS.PESOCORREGIDO,2)"

                    BIBLIOTECA.EjecutarSql(Mensaje, CadenaFormula)
                End If
            End While
            ssQl = " UPDATE " & Tabla & "" & _
                       " SET    HUMEDADTOT = ROUND(TMPCALCULOS.HUMEDADTOT, 2), FACTORB = ROUND(TMPCALCULOS.FACTORB, 5), " & _
                       "        HIDROGENO = ROUND(TMPCALCULOS.HIDROGENO, 2), PESOCORREGIDO = ROUND(TMPCALCULOS.PESOCORREGIDO, 2), " & _
                       "        PODERCALORLHV = ROUND(TMPCALCULOS.PODERCALORLHV, 2), PODERCALORTOT = ROUND(TMPCALCULOS.PODERCALORTOT, 2), " & _
                       "        ESTADO=(CASE PATINDEX('%E%', TMPCALCULOS.NUMERO) WHEN 0 THEN 'CA' ELSE 'CE' END) " & _
                       " FROM   " & Tabla & " INNER JOIN TMPCALCULOS ON " & Tabla & ".NUMERO = TMPCALCULOS.NUMERO"
            If BIBLIOTECA.EjecutarSql(Mensaje, ssQl) Then
                Mensaje = "Proceso Terminado"
            End If
            BIBLIOTECA.DesConectar(conn)
        Catch ex As Exception
            Mensaje = Mensaje & ";" & ex.Message
        End Try
        Return Mensaje
    End Function
End Class

Public Class Cierre_de_Periodo
    Public Function Cierre_De_Periodo(ByRef Mensaje As String, ByVal Fecha As Date) As Boolean
        Dim ssql As String
        Dim Ano As Integer
        Dim Mes As Integer
        Dim Biblioteca As New Biblioteca
        Mes = Month(Fecha)
        Ano = Year(Fecha)
        ssql = " INSERT INTO HISTORICO_ENTREGAS ( FECHAENTREGA, HORAENTREGA, HORASALIDA, NUMEROENTRADA, MUESTRAGEN, COOPERATIVA, CONDUCTOR, CAMION, MUNICIPIO, MINA, PESOENTRADA, PESOSALIDA, PESONETO, OPERARIOBASCULA, TOMADORMUESTRA, OBSERVACION_ETR, OBSERVACION_SAL, ESTADO, MUESTRAESP, IMPRESIONESENT, IMPRESIONESSAL )" & _
               " SELECT ENTREGAS.FECHAENTREGA, ENTREGAS.HORAENTREGA, ENTREGAS.HORASALIDA, ENTREGAS.NUMEROENTRADA, ENTREGAS.MUESTRAGEN, ENTREGAS.COOPERATIVA, ENTREGAS.CONDUCTOR, ENTREGAS.CAMION, ENTREGAS.MUNICIPIO, ENTREGAS.MINA, ENTREGAS.PESOENTRADA, ENTREGAS.PESOSALIDA, ENTREGAS.PESONETO, ENTREGAS.OPERARIOBASCULA, ENTREGAS.TOMADORMUESTRA, ENTREGAS.OBSERVACION_ETR, ENTREGAS.OBSERVACION_SAL, ENTREGAS.ESTADO, ENTREGAS.MUESTRAESP, ENTREGAS.IMPRESIONESENT, ENTREGAS.IMPRESIONESSAL " & _
               " FROM ENTREGAS"
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            ssql = " DELETE ENTREGAS " & _
                   " FROM ENTREGAS"
            If Biblioteca.EjecutarSql(Mensaje, ssql) Then
                ssql = "INSERT INTO HISTORICO_MUESTRAS ( ANOCORTE, MESCORTE, NUMERO, ENTREGA, COOPERATIVA, FECHAMUESTRA, ACUMPESOS, FECHAANALISIS, HUMEDADSUP, HUMEDADRES, HUMEDADTOT, MATVOLATIL, AZUFRE, CENIZAS, CARBONO, FACTORB, HIDROGENO, PESOCORREGIDO, PODERCALORLHV, PODERCALORHHV, PODERCALORTOT, ANALISTA, ESTADO )" & _
                                   " SELECT " & Ano & ", '" & Mes & "', MUESTRAS.NUMERO, MUESTRAS.ENTREGA, MUESTRAS.COOPERATIVA, MUESTRAS.FECHAMUESTRA, MUESTRAS.ACUMPESOS, MUESTRAS.FECHAANALISIS, MUESTRAS.HUMEDADSUP, MUESTRAS.HUMEDADRES, MUESTRAS.HUMEDADTOT, MUESTRAS.MATVOLATIL, MUESTRAS.AZUFRE, MUESTRAS.CENIZAS, MUESTRAS.CARBONO, MUESTRAS.FACTORB, MUESTRAS.HIDROGENO, MUESTRAS.PESOCORREGIDO, MUESTRAS.PODERCALORLHV, MUESTRAS.PODERCALORHHV, MUESTRAS.PODERCALORTOT, MUESTRAS.ANALISTA, MUESTRAS.ESTADO " & _
                                   " FROM MUESTRAS"
                If Biblioteca.EjecutarSql(Mensaje, ssql) Then
                    ssql = " DELETE MUESTRAS " & _
                           " FROM MUESTRAS"
                    If Biblioteca.EjecutarSql(Mensaje, ssql) Then
                        ssql = "UPDATE COOPERATIVAS SET ENTREGAS = 1, KGS_ACUM = 0"
                        Biblioteca.EjecutarSql(Mensaje, ssql)
                        ssql = "UPDATE MINAS SET MINAS.ENTREGAS = 1, MINAS.KGS_ACUM = 0"
                        Biblioteca.EjecutarSql(Mensaje, ssql)
                        ssql="DELETE FROM [CICD].[dbo].[CONSECUTIVOS_ENTREGAS]"
                        Biblioteca.EjecutarSql(Mensaje, ssql)
                        Cierre_De_Periodo = True

                    Else
                        Mensaje = Mensaje & "No se reinició la tabla Muestras"
                    End If
                Else
                    Mensaje = Mensaje & "No se crearon las Muestras en el Historico de Muestras"
                End If
            Else
                Mensaje = Mensaje & "No se reinició la tabla Entregas"
            End If
        Else
            Mensaje = Mensaje & "No se crearon las Entregas en el Historico de Entregas"
        End If
    End Function

End Class

Public Class ConvertirEnLetras
    '****************************************
    'Desarrollado por: Pedro Alex Taya Yactayo
    'Email: alextaya@hotmail.com
    'Web: http://es.geocities.com/wiseman_alextaya
    '     http://groups.msn.com/mugcanete
    '****************************************

    Public Function Letras(ByVal numero As String) As String
        '********Declara variables de tipo cadena************
        Dim palabras, entero, dec, flag As String

        '********Declara variables de tipo entero***********
        Dim num, x, y As Integer

        flag = "N"

        '**********Número Negativo***********
        If Mid(numero, 1, 1) = "-" Then
            numero = Mid(numero, 2, Len(numero) - 1)
            palabras = "menos "
        End If

        '**********Si tiene ceros a la izquierda*************
        For x = 1 To Len(numero)
            If Mid(numero, 1, 1) = "0" Then
                numero = Trim(Mid(numero, 2, Len(numero)))
                If Trim(Len(numero)) = 0 Then palabras = ""
            Else
                Exit For
            End If
        Next

        '*********Dividir parte entera y decimal************
        For y = 1 To Len(numero)
            If Mid(numero, y, 1) = "." Then
                flag = "S"
            Else
                If flag = "N" Then
                    entero = entero + Mid(numero, y, 1)
                Else
                    dec = dec + Mid(numero, y, 1)
                End If
            End If
        Next y

        If Len(dec) = 1 Then dec = dec & "0"

        '**********proceso de conversión***********
        flag = "N"

        If Val(numero) <= 999999999 Then
            For y = Len(entero) To 1 Step -1
                num = Len(entero) - (y - 1)
                Select Case y
                    Case 3, 6, 9
                        '**********Asigna las palabras para las centenas***********
                        Select Case Mid(entero, num, 1)
                            Case "1"
                                If Mid(entero, num + 1, 1) = "0" And Mid(entero, num + 2, 1) = "0" Then
                                    palabras = palabras & "cien "
                                Else
                                    palabras = palabras & "ciento "
                                End If
                            Case "2"
                                palabras = palabras & "doscientos "
                            Case "3"
                                palabras = palabras & "trescientos "
                            Case "4"
                                palabras = palabras & "cuatrocientos "
                            Case "5"
                                palabras = palabras & "quinientos "
                            Case "6"
                                palabras = palabras & "seiscientos "
                            Case "7"
                                palabras = palabras & "setecientos "
                            Case "8"
                                palabras = palabras & "ochocientos "
                            Case "9"
                                palabras = palabras & "novecientos "
                        End Select
                    Case 2, 5, 8
                        '*********Asigna las palabras para las decenas************
                        Select Case Mid(entero, num, 1)
                            Case "1"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    flag = "S"
                                    palabras = palabras & "diez "
                                End If
                                If Mid(entero, num + 1, 1) = "1" Then
                                    flag = "S"
                                    palabras = palabras & "once "
                                End If
                                If Mid(entero, num + 1, 1) = "2" Then
                                    flag = "S"
                                    palabras = palabras & "doce "
                                End If
                                If Mid(entero, num + 1, 1) = "3" Then
                                    flag = "S"
                                    palabras = palabras & "trece "
                                End If
                                If Mid(entero, num + 1, 1) = "4" Then
                                    flag = "S"
                                    palabras = palabras & "catorce "
                                End If
                                If Mid(entero, num + 1, 1) = "5" Then
                                    flag = "S"
                                    palabras = palabras & "quince "
                                End If
                                If Mid(entero, num + 1, 1) > "5" Then
                                    flag = "N"
                                    palabras = palabras & "dieci"
                                End If
                            Case "2"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    palabras = palabras & "veinte "
                                    flag = "S"
                                Else
                                    palabras = palabras & "veinti"
                                    flag = "N"
                                End If
                            Case "3"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    palabras = palabras & "treinta "
                                    flag = "S"
                                Else
                                    palabras = palabras & "treinta y "
                                    flag = "N"
                                End If
                            Case "4"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    palabras = palabras & "cuarenta "
                                    flag = "S"
                                Else
                                    palabras = palabras & "cuarenta y "
                                    flag = "N"
                                End If
                            Case "5"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    palabras = palabras & "cincuenta "
                                    flag = "S"
                                Else
                                    palabras = palabras & "cincuenta y "
                                    flag = "N"
                                End If
                            Case "6"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    palabras = palabras & "sesenta "
                                    flag = "S"
                                Else
                                    palabras = palabras & "sesenta y "
                                    flag = "N"
                                End If
                            Case "7"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    palabras = palabras & "setenta "
                                    flag = "S"
                                Else
                                    palabras = palabras & "setenta y "
                                    flag = "N"
                                End If
                            Case "8"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    palabras = palabras & "ochenta "
                                    flag = "S"
                                Else
                                    palabras = palabras & "ochenta y "
                                    flag = "N"
                                End If
                            Case "9"
                                If Mid(entero, num + 1, 1) = "0" Then
                                    palabras = palabras & "noventa "
                                    flag = "S"
                                Else
                                    palabras = palabras & "noventa y "
                                    flag = "N"
                                End If
                        End Select
                    Case 1, 4, 7
                        '*********Asigna las palabras para las unidades*********
                        Select Case Mid(entero, num, 1)
                            Case "1"
                                If flag = "N" Then
                                    If y = 1 Then
                                        palabras = palabras & "uno "
                                    Else
                                        palabras = palabras & "un "
                                    End If
                                End If
                            Case "2"
                                If flag = "N" Then palabras = palabras & "dos "
                            Case "3"
                                If flag = "N" Then palabras = palabras & "tres "
                            Case "4"
                                If flag = "N" Then palabras = palabras & "cuatro "
                            Case "5"
                                If flag = "N" Then palabras = palabras & "cinco "
                            Case "6"
                                If flag = "N" Then palabras = palabras & "seis "
                            Case "7"
                                If flag = "N" Then palabras = palabras & "siete "
                            Case "8"
                                If flag = "N" Then palabras = palabras & "ocho "
                            Case "9"
                                If flag = "N" Then palabras = palabras & "nueve "
                        End Select
                End Select

                '***********Asigna la palabra mil***************
                If y = 4 Then
                    If Mid(entero, 6, 1) <> "0" Or Mid(entero, 5, 1) <> "0" Or Mid(entero, 4, 1) <> "0" Or _
                    (Mid(entero, 6, 1) = "0" And Mid(entero, 5, 1) = "0" And Mid(entero, 4, 1) = "0" And _
                    Len(entero) <= 6) Then palabras = palabras & "mil "
                End If

                '**********Asigna la palabra millón*************
                If y = 7 Then
                    If Len(entero) = 7 And Mid(entero, 1, 1) = "1" Then
                        palabras = palabras & "millón "
                    Else
                        palabras = palabras & "millones "
                    End If
                End If
            Next y

            '**********Une la parte entera y la parte decimal*************
            If dec <> "" Then
                Letras = palabras & "con " & dec
            Else
                Letras = palabras
            End If
        Else
            Letras = ""
        End If
    End Function
End Class

