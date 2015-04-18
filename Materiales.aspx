<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Materiales" %>

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
            Me.cvFecha1.ValueToCompare = Today
            Me.CVFecha2.ValueToCompare = Today
            Me.FECHAIN.Text = Today
            Me.FECHAFIN.Text = Today
            
            Dim Mensaje As String = ""
            Dim Biblioteca As New Biblioteca
            Dim Conn As SqlConnection
            Dim Dtadapter As SqlDataAdapter
            Dim DtSet As DataSet
            Dim ssql As String
            
            Conn = Biblioteca.Conectar(Mensaje)
            
            ssql = " SELECT CODIGO, NOMBRE " & _
                    " FROM PRODUCTO " & _
                    " WHERE PRODUCTO.NOMBRE <> 'CENIZA'" & _
                    " UNION " & _
                    " SELECT 'TODOS' AS CODIGO, 'TODOS' AS NOMBRE  " & _
                    " FROM PRODUCTO AS PRODUCTO_1"
            
            Dtadapter = Biblioteca.CargarDataAdapter(ssql, Conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            Dtadapter.Fill(DtSet, "PRODUCTO")
            'Combo1 Usuarios
            Me.PRODUCTO.DataSource = DtSet.Tables("PRODUCTO").DefaultView
            Me.PRODUCTO.DataTextField = "NOMBRE"
            ' Asigna el valor del value en el DropDownList
            Me.PRODUCTO.DataValueField = "CODIGO"
            Me.PRODUCTO.DataBind()
            Biblioteca.DesConectar(Conn)
                       
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
        Dim CadenaWhere As String = ""

        If Me.PRODUCTO.Text = "TODOS" Then
            ssql = " SELECT     CONTROLMATERIALES.CODIGOENTRADA, CONTROLMATERIALES.FECHA, CONTROLMATERIALES.PLACA, CONTROLMATERIALES.PESOENTRADA, " & _
                     " CONTROLMATERIALES.PESOSALIDA, CONTROLMATERIALES.PESONETO, EMPRESA.DESCRIPCION AS EMPRESA, PRODUCTO.NOMBRE AS CODIGOPRODUCTO, " & _
                     " HORAENTRADA, HORASALIDA, OPERADORBASCULA " & _
                    " FROM         CONTROLMATERIALES LEFT OUTER JOIN PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO LEFT OUTER JOIN" & _
                     " EMPRESA ON CONTROLMATERIALES.EMPRESA = EMPRESA.CODIGO" & _
                   " WHERE PRODUCTO.NOMBRE <> 'CENIZA' AND " & _
                   " CONTROLMATERIALES.FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
                   " AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)"
        Else
            ssql = " SELECT     CONTROLMATERIALES.CODIGOENTRADA, CONTROLMATERIALES.FECHA, CONTROLMATERIALES.PLACA, CONTROLMATERIALES.PESOENTRADA, " & _
                 " CONTROLMATERIALES.PESOSALIDA, CONTROLMATERIALES.PESONETO, EMPRESA.DESCRIPCION AS EMPRESA, PRODUCTO.NOMBRE AS CODIGOPRODUCTO, " & _
                 " HORAENTRADA, HORASALIDA, OPERADORBASCULA " & _
               " FROM         CONTROLMATERIALES LEFT OUTER JOIN PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO LEFT OUTER JOIN" & _
                 " EMPRESA ON CONTROLMATERIALES.EMPRESA = EMPRESA.CODIGO" & _
               " WHERE PRODUCTO.NOMBRE <> 'CENIZA' AND " & _
               " CONTROLMATERIALES.FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
               " AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONTROLMATERIALES.CODIGOPRODUCTO = '" & Me.PRODUCTO.Text & "'"
            
        End If
        
        
        Session("NombreReporte") = "Materiales.rpt"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("Parametro") = Me.FECHAIN.Text
        Session("NombreDataTable") = "CONTROLMATERIALES"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Materiales", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text, Session("GRUPOUS"))
    End Sub

    Protected Sub Cancelar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("Principal.aspx")
    End Sub

    Protected Sub Agrupado_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)

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
        &nbsp;
        <table>
            <tr>
                <td align="center" style="text-align: right">
                </td>
                <td align="center" style="text-align: left">
                </td>
            </tr>
            <tr>
                <td align="center" style="text-align: right">
                </td>
                <td align="center" style="text-align: left">
                </td>
            </tr>
            <tr>
                <td align="center" style="text-align: right;">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Inicial" Width="88px"></asp:Label></td>
                <td align="center" style="text-align: left">
                    <asp:TextBox ID="FECHAIN" runat="server" Width="96px"></asp:TextBox>
                    <asp:CompareValidator ID="cvFecha1" runat="server" ControlToValidate="FECHAIN" ErrorMessage="*"
                        Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="1px"></asp:CompareValidator>
                </td>
            </tr>
            <tr>
                <td align="center" style="text-align: right;">
                    <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Final"
                        Width="82px"></asp:Label>
                    </td>
                <td align="center" style="text-align: left">
                    <asp:TextBox ID="FECHAFIN" runat="server" Width="96px"></asp:TextBox>
                    <asp:CompareValidator ID="CVFecha2" runat="server" ControlToValidate="FECHAFIN" ErrorMessage="*"
                        Height="13px" Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="1px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="center" style="text-align: right">
                    <asp:Label ID="Label3" runat="server" Font-Bold="True" ForeColor="#336677" Text="Producto"
                        Width="82px"></asp:Label></td>
                <td align="center" style="text-align: left">
                    <asp:DropDownList ID="PRODUCTO" runat="server"
                        Width="286px">
                    </asp:DropDownList></td>
            </tr>
            <tr>
                <td align="center">
                    </td>
                <td align="center">
                    <asp:Button ID="Imprimir" runat="server" Font-Bold="True" ForeColor="#336677" Text="Imprimir" OnClick="Imprimir_Click" />
                    <asp:Button ID="Cancelar" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cancelar" OnClick="Cancelar_Click" /></td>
            </tr>
            <tr>
                <td align="left" colspan="2" style="height: 21px">
                    <asp:Label ID="mensaje" runat="server" Width="459px"></asp:Label>&nbsp;
                </td>
            </tr>
        </table>
    </div>    
</asp:Content>