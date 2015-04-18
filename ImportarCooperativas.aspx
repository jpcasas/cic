<%@ Page Language="VB" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.IO" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim NombreArchivo As String
        Dim Cargado As Boolean
        Dim Seguridad As New Seguridad
        Dim archivosplanos As New ArchivosPlanos
        
        Cargado = False
        NombreArchivo = ""
        If (RutaSubir.PostedFile.ContentLength > 0) Then
            
            NombreArchivo = System.IO.Path.GetFileName(RutaSubir.PostedFile.FileName)
            Dim SaveLocation As String
            SaveLocation = Server.MapPath("Documentos") + "\\" + NombreArchivo
            Try
                RutaSubir.PostedFile.SaveAs(SaveLocation)
                Cargado = True
            Catch ex As Exception
                Cargado = False
                archivosplanos.GeneraArchivoBascula("c:\temp", "ErrorCargaCoop.txt", ex.Message)
                'mensaje.ForeColor = System.Drawing.Color.Red
                'mensaje.Text = "Error no "                
            End Try
        Else
            mensaje.ForeColor = System.Drawing.Color.Red
            mensaje.Text = "Por favor seleccione un archivo para subir"
            Exit Sub
        End If
        If Cargado Then
            Try
                Me.mensaje.ForeColor = System.Drawing.Color.Blue
                'mensaje.Text = Importar.ImportarExcelLaboratorio("Muestras", Server.MapPath("Documentos") & "\" & NombreArchivo, Session("Usuario"), Me.FECHAIN.Text, Me.FECHAFIN.Text)
                'Me.mensaje.Text = Importar.ImportarCsvLab("Muestras", Server.MapPath("Documentos") & "\" & NombreArchivo, Session("Usuario"), Me.FECHAIN.Text, Me.FECHAFIN.Text)
                Me.mensaje.Text = ImportarDesdeCsv(Server.MapPath("Documentos") & "\" & NombreArchivo)
                
            Catch ex As Exception
                archivosplanos.GeneraArchivoBascula("c:\temp", "ErrorExcel1.txt", ex.Message)
            End Try
            'Seguridad.RegistroAuditoria(Session("Usuario"), "Importar", "Datos Laboratorio", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text & ";Ruta:" & Server.MapPath("Documentos") & "\" & NombreArchivo & ";Tabla:Muestras", Session("GRUPOUS"))
        Else
            mensaje.ForeColor = System.Drawing.Color.Red
            mensaje.Text = "El archivo no fue transferido al servidor "
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
    End Sub
    
    Protected Sub Cancelar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ClientScript As String
        ClientScript = "<script> window.close();" & "<" & "/script>"
        Response.Write(ClientScript)
    End Sub
    
    Private Function ImportarDesdeCsv(ByVal Ruta As String) As String
        Dim fileReader As New StreamReader(Ruta, System.Text.Encoding.Default)
        'System.Text.Encoding.Default para ñ y caracteres especiales
        Dim Cadena As String
        Dim Contador As Integer = 0
        DIM Seguridad AS New     Seguridad

        Dim CodCoop As String = ""
        Dim Descripcion As String = ""
        Dim CupoLimite As Double = 0
        dim Estado as String = ""
        Dim Vector(9) As String
        Dim Actualizados As Integer = 0
        Dim Insertados As Integer = 0

        Dim Mensaje As String = ""
        Dim Ssql As String = ""
        Dim cmd As SqlCommand
        Dim miDataReader As SqlDataReader
        Dim Biblioteca As New Biblioteca
        Dim conn As SqlConnection = Biblioteca.Conectar(Mensaje)
             
         

        ImportarDesdeCsv = 0
        Try
            ssql = "UPDATE    COOPERATIVAS" & _
                   " SET ESTADO = ''"
            Biblioteca.EjecutarSql(Mensaje, ssql)
            ssql = ""
            Cadena = "Inicio"
            While Cadena <> ""
                Contador = Contador + 1
                Try
                    Cadena = fileReader.ReadLine.Trim
                Catch ex As Exception
                    Cadena = ""
                End Try
                
                If InStr(Cadena, ",", CompareMethod.Text) > 0 Then
                    Cadena=Cadena & ","
                    Vector = Cadena.Split(",")
                ElseIf InStr(Cadena, ";", CompareMethod.Text) > 0 Then
                    Cadena=Cadena & ";"
                    Vector = Cadena.Split(";")
                Else
                    If ImportarDesdeCsv = 0 Then
                        ImportarDesdeCsv = "Se actualizaron " & Actualizados & " y se Insertaron " & Insertados & " Cooperativas "
                    Else
                        ImportarDesdeCsv = "Verifique que el archivo se encuentre separado por (Comas) o por (Punto Y Coma)"
                    End If
                    Exit Function
                End If
                
              
                
                CodCoop = Vector(0)
                If CodCoop <> "" Then
                    Descripcion = Vector(1)
                    CupoLimite = Val(Vector(2))
                    Estado=vector(6)
                    ssql = "UPDATE    COOPERATIVAS" & _
                           " SET DESCRIPCION = '" & Descripcion & "', CUPOLIMITE = " & CupoLimite & ", ESTADO = '"& Estado &"', ENTREGAS = 1, KGS_ACUM = 0" & _
                           " WHERE NUMERO = '" & CodCoop & "'"

                    cmd = New SqlCommand(ssql, conn)
                    miDataReader = cmd.ExecuteReader()
                    
                    If miDataReader.RecordsAffected > 0 Then
                        Actualizados = Actualizados + 1
                    Else
                        'Si no actualiza entonces realiza Insert
                        miDataReader.Close()
                        ssql = "INSERT INTO COOPERATIVAS" & _
                               " (NUMERO, DESCRIPCION, CUPOLIMITE, ESTADO, ENTREGAS, KGS_ACUM)" & _
                               " VALUES ('" & CodCoop & "', '" & Descripcion & "', " & CupoLimite & ", '"& Estado &"', 1, 0)"
                        cmd = New SqlCommand(ssql, conn)
                        miDataReader = cmd.ExecuteReader()
                        If miDataReader.RecordsAffected > 0 Then
                            Insertados = Insertados + 1
                        End If
                    End If
                    miDataReader.Close()
                End If
            End While
            ImportarDesdeCsv = "Se actualizaron " & Actualizados & " y se Insertaron " & Insertados & " Cooperativas "
            Seguridad.RegistroAuditoria(Session("Usuario"), "Importar", "Cooperativas", "Mensaje:" & Me.mensaje.Text & ";Ruta:" & Ruta, Session("GRUPOUS"))
            fileReader.Close()
        Catch ex As Exception
            fileReader.Close()
            ImportarDesdeCsv = Mensaje & ";" & ex.Message
        End Try
        Biblioteca.DesConectar(conn)
    End Function
</script>   

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Importar Cooperativas</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <table style="border-right: #cccccc thin double; padding-right: 1px; border-top: #cccccc thin double; padding-left: 1px; padding-bottom: 1px; border-left: #cccccc thin double; padding-top: 1px; border-bottom: #cccccc thin double; width: 342px; height: 141px;"> <!-- TABLA USADA COMO MARCO DEL FORMULARIO-->
        <tr>
        <td style="height: 146px; width: 169px;">
            <table style="width: 347px; height: 182px">
                <tr>
                    <td align="center" colspan="2" height="1" style="color: #000000">
                        <asp:Label ID="Label17" runat="server" Font-Bold="True" ForeColor="#336677" Text="Importar Cooperativas" Width="179px"></asp:Label></td>
                </tr>
                <tr>
                    <td align="left" colspan="2" style="height: 24px; text-align: center">
                        <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="Red" Text="Se actualizaran todos los campos de la tabla cooperativas, y se crearan los registros que no se encuentren actualmente"></asp:Label></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; text-align: right;">
                        &nbsp;</td>
                    <td align="left" style="width: 83px">
                        </td>
                </tr>
                <tr>
                    <td align="right" style="text-align: right;" colspan="2">
                        <asp:FileUpload ID="RutaSubir" runat="server" Width="370px" />&nbsp;</td>
                </tr>
                <tr>
                    <td align="center" colspan="2" style="height: 26px; text-align: right;">
                        <asp:Button ID="BtnActualizar" runat="server" Font-Bold="True" Font-Italic="False"
                            Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677"
                            OnClick="BtnActualizar_Click" Text="Aceptar" />&nbsp;
                    <asp:Button ID="Cancelar" runat="server" Font-Bold="True" Font-Italic="False"
                            Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677"
                            Text="Cancelar" OnClick="Cancelar_Click" /></td>
                </tr>
                <tr>
                    <td align="center" colspan="2" style="height: 26px; text-align: left;">
                        <asp:Label ID="mensaje" runat="server"></asp:Label></td>
                </tr>
            </table>
                        </td>
        </tr>
    </table>
    </div>

    </form>
</body>
</html>
