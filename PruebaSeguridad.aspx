<%@ Page Language="VB" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Button1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Seg As New Seguridad
        Dim Biblio As New Biblioteca
        'Dim dtreader As SqlDataReader
        Dim conn As SqlConnection
        Dim Mensaje As String = ""
        Dim ssql As String = ""
        Dim clave As String = ""
        
        
        'ssql = "SELECT * FROM USUARIOS WHERE NOMBRE = ROBERTO"
        ' conn = Biblio.Conectar(Mensaje)
        
        'dtreader = Biblio.CargarDataReader(Mensaje, ssql, conn)
        'While dtreader.Read
        clave = Seg.Encriptar("1")
        
        ssql = " UPDATE USUARIOS SET " & _
               " CLAVE = '" & clave & "' WHERE NOMBRE = 'ROBERTO'"
            
        Biblio.EjecutarSql(Mensaje, ssql)
        'End While
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Página sin título</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Button" /></div>
    </form>
</body>
</html>
