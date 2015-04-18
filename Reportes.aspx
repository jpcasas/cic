<%@ Page Language="VB" %>
<%@ import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim conn As SqlConnection
        Dim Mensaje As String
        Mensaje = ""
        Me.Usuario.Text = Session("Usuario")
        Me.Fecha.Text = Now.Date
        Me.TITULO.Text = Session("TituloReporte")
        conn = Biblioteca.Conectar(Mensaje)
        Dim DtReader As SqlDataReader
        DtReader = Biblioteca.CargarDataReader(Mensaje,Session("SqlReporte"), conn)
        Reporte.DataSource = DtReader
        Reporte.DataBind()
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Página sin título</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table>
            <tr>
                <td colspan="2" width="75%" bgcolor="#aeb1ab">                              
                    <asp:Label ID="TITULO" runat="server" Font-Bold="True"></asp:Label></td>
                <td  width="246" rowspan="2" align="right">
                    <asp:Image ID="Image1" runat="server" ImageUrl="~/imagenes/LOGOJ.BMP" Height="102px" Width="287px" /></td>
            </tr>
            <tr>
                <td style="height: 43px" valign="middle">
                    <asp:Label ID="Label2" runat="server" Text="Fecha de Impresión"></asp:Label>
                    &nbsp;&nbsp; &nbsp;<asp:Label ID="Fecha" runat="server" Width="82px"></asp:Label><br />
                    <asp:Label ID="Label3" runat="server" Text="Usuario Actual"></asp:Label>
                    &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;
                    <asp:Label ID="Usuario" runat="server" Width="82px"></asp:Label></td>
                <td style="height: 43px" valign="middle">
                    <br />
                    </td>
            </tr>
            <tr>
                <td colspan="3">
        <asp:GridView ID="Reporte" runat="server" CellPadding="4" ForeColor="#333333" Font-Underline="False">
            <FooterStyle ForeColor="White" Font-Bold="True" />
            <SelectedRowStyle BackColor="#FFCC66" Font-Bold="True" ForeColor="Navy" />
            <PagerStyle HorizontalAlign="Center" Font-Bold="False" />
            <HeaderStyle Font-Bold="True" ForeColor="Black" BorderColor="Black" BorderWidth="1px" Font-Underline="True" />            
            <RowStyle ForeColor="#333333" />
            <AlternatingRowStyle BackColor="LightGray" />
        </asp:GridView>
                </td>
            </tr>
        </table>
    
    </div>
    </form>
</body>
</html>
