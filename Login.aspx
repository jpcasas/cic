
<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Login" %>

<%@ Import Namespace="System.Windows.Forms" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Drawing" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>

<script runat="server">

    Protected Sub ACEPTAR_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim Mensaje As String
        Dim usr As String
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        Me.txtnombre.Text = UCase(Me.txtnombre.Text)
        usr = UCase(Me.txtnombre.Text)
        dTReader = BIBLIOTECA.CargarDataReader(Mensaje, "SELECT CODIGO,GRUPO FROM USUARIOS WHERE CODIGO='ADMIN'", conn)
        
        Page.FindControl("txtnombre1")
        If Not dTReader.Read() Then
            'MsgBox("Verifique nombre y contraseña", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Verifique nombre y contraseña"
            If Me.txtnombre.Text <> "" And Me.txtcontrasena.Text <> "" Then
                Seguridad.RegistroAuditoria(Me.txtnombre.Text, "Inicio Sesion", "Clave y Contraseña", "Error de Clave y Contraseña", "")
            End If
        Else
            Session("Usuario") = Me.txtnombre.Text
            Session("GRUPOUS") = dTReader(1)
            Session("Contrasena") = Seguridad.Encriptar(Me.txtcontrasena.Text)
            Seguridad.RegistroAuditoria(Me.txtnombre.Text, "Inicio Sesion", "Clave y Contraseña", "Ingreso Exitoso", dTReader(1))
        End If
        dTReader.Close()
        BIBLIOTECA.DesConectar(conn)
        If Session("Usuario") <> "" Then
            Response.Redirect("Principal.aspx")
        End If
    End Sub
    
    Public Sub limpiar()
        Me.txtcontrasena.Text = ""
        Me.txtnombre.Text = ""
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Session("Usuario") = ""
        Session("GRUPOUS") = ""
        Me.mensaje.Text=""
        Me.txtnombre.Focus()
    End Sub

    '    Protected Sub txtnombre_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
    '        Me.txtnombre.Text = UCase(Me.txtnombre.Text)
    '        Me.txtcontrasena.Focus()
    '    End Sub
</script>    
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<script language="javascript" type="text/javascript">
<!--
function ponerMayusculas(nombre) 
{ 
    nombre.value=nombre.value.toUpperCase(); 
    document.getElementById('ctl00_ContentPlaceHolder1_txtnombre').value= nombre.value;        
} 

// -->
</script>
    
    <div>
        <table>
            <tr>
                <td style="width: 100px">
                </td>
                <td style="width: 61px">
                </td>
                <td align="right" style="width: 100px">
                </td>
                <td style="width: 166px">
                </td>
                <td style="width: 166px">
                </td>
            </tr>
            <tr>
                <td style="width: 100px; height: 21px">
                </td>
                <td style="width: 61px; height: 21px">
                </td>
                <td align="right" style="width: 100px; height: 21px">
                </td>
                <td style="width: 166px; height: 21px">
                </td>
                <td style="width: 166px; height: 21px">
                </td>
            </tr>
            <tr>
                <td style="width: 100px; height: 21px">
                </td>
                <td style="width: 61px; height: 21px">
                </td>
                <td align="right" style="width: 100px; height: 21px">
                </td>
                <td style="width: 166px; height: 21px">
                </td>
                <td style="width: 166px; height: 21px">
                </td>
            </tr>
            <tr>
                <td style="width: 100px">
                </td>
                <td style="width: 61px">
                </td>
                <td align="right" style="width: 100px">
                    <asp:Label ID="Label1" runat="server" Text="Nombre Usuario" Width="143px" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 166px">
                    <asp:TextBox ID="txtnombre" runat="server" AutoPostBack="false" TabIndex="1" ToolTip="Nombre de Usuario" Width="144px"></asp:TextBox></td>
                <td style="width: 166px">
                    </td>
            </tr>
            <tr>
                <td style="width: 100px; height: 26px">
                </td>
                <td style="width: 61px; height: 26px">
                </td>
                <td align="right" style="width: 100px; height: 26px">
                    <asp:Label ID="Label2" runat="server" Text="Contraseña" Width="116px" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 166px; height: 26px">
                    <asp:TextBox ID="txtcontrasena" runat="server" TextMode="Password" TabIndex="2"></asp:TextBox></td>
                <td style="width: 166px; height: 26px">
                    </td>
            </tr>
            <tr>
                <td style="width: 100px; height: 26px;">
                </td>
                <td style="width: 61px; height: 26px;">
                </td>
                <td align="right" style="width: 100px; height: 26px;">
                    </td>
                <td align="center" colspan="1" style="height: 26px">
                    <asp:Button ID="ACEPTAR" runat="server" Text="ACEPTAR" OnClick="ACEPTAR_Click" TabIndex="3" Font-Bold="True" ForeColor="#336677" /></td>
                <td colspan="2" align="center" style="height: 26px">
                    <asp:Label ID="mensaje" runat="server"></asp:Label>&nbsp;</td>
            </tr>
            <tr>
                <td style="width: 100px">
                </td>
                <td style="width: 61px">
                </td>
                <td align="right" style="width: 100px">
                </td>
                <td style="width: 166px">
                </td>
                <td style="width: 166px">
                    </td>
            </tr>
        </table>
    
    </div>   
</asp:Content>
