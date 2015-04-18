<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Cierre de Periodo" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        If Not Page.IsPostBack Then
            'define el valor para la comparacion
            cvFecha1.ValueToCompare = Today
            Me.FECHAIN.Text = Today
            Dim Mensaje As String = ""
            Dim Biblioteca As New Biblioteca
            
            Mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            Mensaje = ""
        End If
    End Sub

    Protected Sub Cierre_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Seguridad As New Seguridad
        Dim CierreDePeriodo As New Cierre_de_Periodo
        Dim Mensaje As String = ""
        
        Seguridad.RegistroAuditoria(Session("Usuario"), "Cierre De Periodo", "Inicio", "Fecha Cierre:" & Me.FECHAIN.Text, Session("GRUPOUS"))
        If CierreDePeriodo.Cierre_De_Periodo(Mensaje, Me.FECHAIN.Text) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Cierre De Periodo", "Fin Exitoso", "Fecha Cierre:" & Me.FECHAIN.Text, Session("GRUPOUS"))
            Me.mensaje.Text = "Cierre Terminado Exitosamente"
        Else
            Seguridad.RegistroAuditoria(Session("Usuario"), "Cierre De Periodo", "Fin No Exitoso", "Fecha Cierre:" & Me.FECHAIN.Text, Session("GRUPOUS"))
            Me.mensaje.Text = Mensaje
        End If
    End Sub

    Protected Sub Cancelar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("Principal.aspx")
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<script language="javascript" type="text/javascript">
// <!CDATA[

function Button1_onclick() {

}

// ]]>
</script>
    
    <div>
        <table>
            <tr>
                <td align="center" style="width: 470px; height: 25px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha de Corte para Cierre" Width="187px"></asp:Label><asp:TextBox ID="FECHAIN" runat="server" Enabled="False" Width="96px"></asp:TextBox><asp:CompareValidator ID="cvFecha1" runat="server" ErrorMessage="*" Width="1px" ControlToValidate="FECHAIN" Type="Date" Operator="DataTypeCheck" SetFocusOnError="True"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="center" colspan="1" style="width: 470px; height: 22px">
                    <asp:Label ID="Label1" runat="server" BorderColor="Black" BorderWidth="1px"
                        Font-Bold="True" ForeColor="Red" Text="ESTE PROCESO TRASLADARÁ TODOS LOS MOVIMIENTOS DEL PERÍODO A ARCHIVOS HISTÓRICOS Y PREPARARÁ LA APLICACIÓN PARA INICIO DE UN NUEVO PERÍODO, CON CONSECUTIVOS INICIALES DE NÚMEROS DE ENTREGAS. ES NECESARIO QUE ESTÉ SEGURO DE REALIZAR ESTE PROCESO."
                        Width="468px"></asp:Label></td>
            </tr>
            <tr>
                <td align="center" colspan="1" height="1" style="width: 470px">
                    &nbsp;<asp:Button ID="Cierre" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cierre" OnClick="Cierre_Click" />
                    <asp:Button ID="Cancelar" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cancelar" OnClick="Cancelar_Click" />
                    &nbsp;</td>
            </tr>
            <tr>
                <td align="left" style="width: 470px; height: 21px">
                    &nbsp;<asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>    
</asp:Content>