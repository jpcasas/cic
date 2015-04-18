<%@ Page Language="VB" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Dim BIBLIOTECA As New Biblioteca
            Dim conn As SqlConnection
            Dim DtAdapter As SqlDataAdapter
            Dim DtSet As DataSet
            Dim ssql As String
            Dim Mensaje As String = ""
            Mensaje = ""
            
            conn = BIBLIOTECA.Conectar(Mensaje)
            ssql = " SELECT NOMBRE " & _
                   " FROM USUARIOS" & _
                   " WHERE GRUPO = 'TOMA MUESTRAS' " '& _
            '" UNION " & _
            '" SELECT '..' AS CODIGO1" & _
            '" FROM USUARIOS AS USUARIOS_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "USUARIOS")
            'Combo1 Usuarios
            Me.TomaMuestras.DataSource = DtSet.Tables("USUARIOS").DefaultView
            Me.TomaMuestras.DataTextField = "NOMBRE"
            ' Asigna el valor del value en el DropDownList
            Me.TomaMuestras.DataValueField = "NOMBRE"
            Me.TomaMuestras.DataBind()
            BIBLIOTECA.DesConectar(conn)
        End If
    End Sub
    
    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ClientScript As String
        Dim Seguridad As New Seguridad
        
        If Me.TomaMuestras.Text = "" Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Seleccione el nombre de el señor toma muestras"
        Else
            Session("TomaMuestras") = Me.TomaMuestras.Text
            Seguridad.RegistroAuditoria(Session("Usuario"), "INSERTAR", "TomaMuestras", "Nombre:" & Me.TomaMuestras.Text, Session("GRUPOUS"))
            ClientScript = "<script> window.close();" & "<" & "/script>"
            Response.Write(ClientScript)
        End If
    End Sub

</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Nombre Toma Muestras</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table style="border-right: #cccccc thin double; padding-right: 1px; border-top: #cccccc thin double;
            padding-left: 1px; padding-bottom: 1px; border-left: #cccccc thin double; width: 199px;
            padding-top: 1px; border-bottom: #cccccc thin double; height: 52px" leftmargin="0" topmargin="0">
            <!-- TABLA USADA COMO MARCO DEL FORMULARIO-->
            <tr>
                <td style="width: 220px">
                    <table>
                        <tr>
                            <td align="right" style="height: 11px; text-align: center" colspan="2">
                                <asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="Blue" Text="Seleccione el nombre de el señor toma muestras"
                                    Width="217px"></asp:Label></td>
                        </tr>
                        <tr>
                            <td align="center" colspan="2" style="height: 26px; text-align: right">
                                <asp:DropDownList ID="TomaMuestras" runat="server" Width="218px">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td align="center" colspan="2" style="text-align: right">
                                <asp:Button ID="BtnActualizar" runat="server" Font-Bold="True" Font-Italic="False"
                                    Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677"
                                    OnClick="BtnActualizar_Click" Text="Acualizar" /></td>
                        </tr>
                        <tr>
                            <td align="center" colspan="2" style="text-align: left">
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
