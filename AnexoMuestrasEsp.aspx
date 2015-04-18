<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Anexo de Muestras Especiales" %>

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

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        ssql = " SELECT     ENTREGAS.CAMION, ENTREGAS.HORAENTREGA, ENTREGAS.HORASALIDA, ENTREGAS.NUMEROENTRADA, " & _
                  " COOPERATIVAS.DESCRIPCION AS COOPERATIVA, MUNICIPIOS.NOMBRE AS MUNICIPIO, MINAS.DESCRIPCION AS MINA, ENTREGAS.PESOENTRADA, " & _
                  " ENTREGAS.PESOSALIDA, ENTREGAS.PESONETO, ENTREGAS.MUESTRAESP AS MUESTRAGEN" & _
               " FROM         ENTREGAS LEFT OUTER JOIN" & _
                  " MUNICIPIOS ON ENTREGAS.MUNICIPIO = MUNICIPIOS.NUMERO LEFT OUTER JOIN" & _
                  " MINAS ON ENTREGAS.MINA = MINAS.NUMERO LEFT OUTER JOIN" & _
                  " COOPERATIVAS ON ENTREGAS.COOPERATIVA = COOPERATIVAS.NUMERO" & _
               " WHERE     (LEN(ENTREGAS.MUESTRAESP) <> 0) AND (ENTREGAS.FECHAENTREGA = CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Muestras Especiales", "Fecha:" & Me.FECHAIN.Text, Session("GRUPOUS"))
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "AnexoMuestrasEsp.rpt"
        Session("Parametro") = Me.FECHAIN.Text
        Session("NombreDataTable") = "Entregas"
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
        <br />
        <br />
        <table>
            <tr>
                <td align="center" style="width: 470px; height: 25px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha de Proceso Para Impresión" Width="275px"></asp:Label><asp:TextBox ID="FECHAIN" runat="server" Width="96px"></asp:TextBox><asp:CompareValidator ID="cvFecha1" runat="server" ErrorMessage="*" Width="1px" ControlToValidate="FECHAIN" Type="Date" Operator="DataTypeCheck" SetFocusOnError="True"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="center" colspan="1" style="width: 470px; height: 22px">
                    </td>
            </tr>
            <tr>
                <td align="center" colspan="1" height="1" style="width: 470px">
                    &nbsp;<asp:Button ID="Imprimir" runat="server" Font-Bold="True" ForeColor="#336677" Text="Imprimir" OnClick="Imprimir_Click" />
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