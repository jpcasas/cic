<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Entrada Diaria de Carbón OT" %>
<%@ Register Assembly="CrystalDecisions.Web, Version=10.2.3600.0, Culture=neutral, PublicKeyToken=692fbea5521e1304"
    Namespace="CrystalDecisions.Web" TagPrefix="CR" %>

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

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        
        ssql = "EXEC REPORTE"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "CrystalReport.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "reporte"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Cooperativas", "Cooperativas:Todas", Session("GRUPOUS"))
        
        
       
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
        <br />
        <br />
        <table>
            <tr>
                <td align="center" style="width: 470px; height: 25px">
                    Subtotal cooperativas por proveedores</td>
            </tr>
            <tr>
                <td align="center" colspan="1" style="width: 470px; height: 22px">
                    <CR:CrystalReportViewer ID="myCrystalReportViewer" runat="server" AutoDataBind="true" PrintMode="ActiveX" />
                    </td>
            </tr>
            <tr>
                <td align="center" colspan="1" height="1" style="width: 470px">
                    &nbsp;<asp:Button ID="Imprimir" runat="server" Font-Bold="True" ForeColor="#336677" Text="Imprimir" OnClick="Imprimir_Click" />
                    &nbsp;&nbsp;</td>
            </tr>
            <tr>
                <td align="left" style="width: 470px; height: 21px">
                    &nbsp;<asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>    
</asp:Content>