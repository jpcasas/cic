Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.IO
Imports System.Collections.Generic

<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class WebService
    Inherits System.Web.Services.WebService

    <WebMethod()> _
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

   
End Class

