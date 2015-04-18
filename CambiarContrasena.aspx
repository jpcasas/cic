<%@ Page Language="VB" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ClientScript As String
        Dim Biblioteca As New Biblioteca
        Dim ssql As String = ""
        Dim Mensaje As String
        Dim Seguridad As New Seguridad
                  
        If Me.ClaveOriginal.Text <> Me.ClaveAnt.Text Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "La clave no corresponde al usuario "
            Exit Sub
        End If
        If Me.NuevaClave.Text <> Me.ConfirmarNuevaClave.Text Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No coinsiden la Nueva clave y La Confirmación de nueva Clave "
            Exit Sub
        End If
        
        ssql = "UPDATE USUARIOS" & _
               " SET CLAVE = '" & Seguridad.Encriptar(Me.NuevaClave.Text) & "'" & _
               " WHERE CODIGO = '" & Session("USUARIOCAMBIOPASWWORD") & "'"
        Mensaje = ""
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            'Cerrar el explorador
            Seguridad.RegistroAuditoria(Session("Usuario"), "Contraseña", "Cambio de Contraseña", "Usuario:" & Session("USUARIOCAMBIOPASWWORD"), Session("GRUPOUS"))
            ClientScript = "<script> window.close();" & "<" & "/script>"
            Response.Write(ClientScript)
        Else
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se ha cambiado la clave "
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        
        If Not Page.IsPostBack Then
            Actualizar()
        End If
    End Sub
    Private Sub Actualizar()
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtReader As SqlDataReader
        Dim Seguridad As New Seguridad
        Dim ssql As String
        Dim Mensaje As String = ""
        
        Mensaje = ""        
        conn = BIBLIOTECA.Conectar(Mensaje)
                       
        ssql = "SELECT * FROM USUARIOS WHERE CODIGO ='" & Session("USUARIOCAMBIOPASWWORD") & "'"
        DtReader = BIBLIOTECA.CargarDataReader(Mensaje, ssql, conn)
        If DtReader.Read Then
            Me.NombreUser.Text = DtReader("codigo")
            Me.ClaveOriginal.Text = Seguridad.DesEncriptar(DtReader("CLAVE"))
        End If
        BIBLIOTECA.DesConectar(conn)
    End Sub

    Protected Sub Cancelar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ClientScript As String
        ClientScript = "<script> window.close();" & "<" & "/script>"
        Response.Write(ClientScript)
    End Sub
</script>   

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Cambiar Contraseña</title>
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
                        <asp:Label ID="Label17" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cambiar Contraseña" Width="179px"></asp:Label></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 13px">
                    </td>
                    <td style="width: 83px; height: 13px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 13px">
                        <asp:TextBox ID="ClaveOriginal" runat="server" Visible="False"></asp:TextBox>
                    </td>
                    <td style="width: 83px; height: 13px">
                        <asp:Label ID="NombreUser" runat="server" Font-Bold="True" ForeColor="#336677" Width="154px"></asp:Label></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 13px">
                    </td>
                    <td style="width: 83px; height: 13px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; text-align: right;">
                        <asp:Label ID="Label4" runat="server" Font-Bold="True" ForeColor="#336677" Text="Contraseña Anterior"></asp:Label></td>
                    <td align="left" style="width: 83px">
                        <asp:TextBox ID="ClaveAnt" runat="server" Width="111px" TextMode="Password"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 24px">
                        <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Nueva Contraseña"></asp:Label></td>
                    <td align="left" style="width: 83px; height: 24px">
                        <asp:TextBox ID="NuevaClave" runat="server" Width="111px" TextMode="Password"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; text-align: right;">
                        &nbsp;<asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="#336677" Text="Confirmar Contraseña"></asp:Label></td>
                    <td align="left" style="width: 83px">
                        <asp:TextBox ID="ConfirmarNuevaClave" runat="server" Width="111px" TextMode="Password"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="center" colspan="2" style="height: 26px; text-align: right;">
                        <asp:Button ID="BtnActualizar" runat="server" Font-Bold="True" Font-Italic="False"
                            Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677"
                            OnClick="BtnActualizar_Click" Text="Acualizar" />&nbsp;
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
