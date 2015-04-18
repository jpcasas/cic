<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Ceniza" %>

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
            
            ssql = " SELECT CODIGO, DESCRIPCION " & _
                   " FROM EMPRESA " & _
                   " UNION " & _
                   " SELECT '999' AS CODIGO, 'Todas' AS DESCRIPCION" & _
                   " FROM EMPRESA AS EMPRESA1"
            
            Conn = Biblioteca.Conectar(Mensaje)
            Dtadapter = Biblioteca.CargarDataAdapter(ssql, Conn)
            DtSet = New DataSet
            Dtadapter.Fill(DtSet, "EMPRESA")
            Me.Empresa.DataSource = DtSet.Tables("EMPRESA").DefaultView
            Me.Empresa.DataTextField = "DESCRIPCION"
            ' Asigna el valor del value en el DropDownList
            Me.Empresa.DataValueField = "CODIGO"
            Me.Empresa.DataBind()
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
                
        If Me.Empresa.Text <> "999" Then
            CadenaWhere = " AND CONTROLMATERIALES.EMPRESA = '" & Me.Empresa.Text & "'"
        End If
        If Me.Escoria.Checked = True And Me.Empresa.Text <> "" Then
            CadenaWhere = CadenaWhere & " AND CONTROLMATERIALES.CENIZAESCORIA <> 0 "
        End If
        If Me.Volatil.Checked = True Then
            CadenaWhere = CadenaWhere & " AND CONTROLMATERIALES.CENIZAVOLATIL <> 0 "
        End If
        If Me.Patio.Checked = True Then
            CadenaWhere = CadenaWhere & " AND CONTROLMATERIALES.CENIZAPATIO <> 0 "
        End If
        If Me.Industria.Checked = True Then
            CadenaWhere = CadenaWhere & " AND CONTROLMATERIALES.INDUSTRIA <> 0 "
        End If
        
        ssql = " SELECT     CONTROLMATERIALES.CODIGOENTRADA, CONTROLMATERIALES.FECHA, CONTROLMATERIALES.CONDUCTOR, CONTROLMATERIALES.PLACA, " & _
                 " CONTROLMATERIALES.HORAENTRADA, CONTROLMATERIALES.HORASALIDA, CONTROLMATERIALES.PESOENTRADA, CONTROLMATERIALES.PESOSALIDA, CONTROLMATERIALES.PESONETO, " & _
                 " CONTROLMATERIALES.CENIZAVOLATIL, CONTROLMATERIALES.CENIZAESCORIA, CONTROLMATERIALES.CENIZAPATIO, " & _
                 " CONTROLMATERIALES.INDUSTRIA, EMPRESA.DESCRIPCION AS EMPRESA " & _
               " FROM CONTROLMATERIALES LEFT OUTER JOIN EMPRESA ON CONTROLMATERIALES.EMPRESA = EMPRESA.CODIGO LEFT OUTER JOIN " & _
                 " PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO " & _
               " WHERE PRODUCTO.NOMBRE = 'CENIZA' AND " & _
               " CONTROLMATERIALES.FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
               " AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)" & CadenaWhere
        Session("NombreReporte") = "Ceniza.rpt"
        If Me.Agrupado.Checked = True Then
            If Me.Empresa.Text <> "999" Then
                ssql = " SELECT CONTROLMATERIALES.FECHA,  sum(CONTROLMATERIALES.PESONETO) AS PESONETO " & _
                        " FROM CONTROLMATERIALES LEFT OUTER JOIN PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO" & _
                        " WHERE PRODUCTO.NOMBRE = 'CENIZA' AND " & _
                            " CONTROLMATERIALES.FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
                            " AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)" & _
                            " AND EMPRESA = '" & Me.Empresa.Text & "'" & _
                        " GROUP BY FECHA"
            Else
                ssql = " SELECT CONTROLMATERIALES.FECHA, sum(CONTROLMATERIALES.PESONETO) AS PESONETO " & _
                        " FROM CONTROLMATERIALES LEFT OUTER JOIN PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO" & _
                        " WHERE PRODUCTO.NOMBRE = 'CENIZA' AND " & _
                            " CONTROLMATERIALES.FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
                            " AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)" & _
                        " GROUP BY FECHA"
            End If
            Session("NombreReporte") = "CenizaAgr.rpt"
        End If
            Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
            Session("SqlReporte") = ssql
            Session("Parametro") = Me.FECHAIN.Text
            Session("NombreDataTable") = "CONTROLMATERIALES"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Ceniza", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text & ";Agrupado:" & IIf(Me.Agrupado.Checked = True, "SI", "NO"), Session("GRUPOUS"))
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
        &nbsp;<br />
        <table>
            <tr>
                <td align="center" style="text-align: right">
                </td>
                <td align="center" style="text-align: left">
                </td>
                <td align="center" style="text-align: right">
                </td>
                <td align="center" style="text-align: right">
                </td>
                <td align="center" style="text-align: right">
                </td>
            </tr>
            <tr>
                <td align="center" style="text-align: right">
                </td>
                <td align="center" style="text-align: left">
                </td>
                <td align="center" style="text-align: right">
                </td>
                <td align="center" style="text-align: right">
                </td>
                <td align="center" style="text-align: right">
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
                <td align="center" style="text-align: right">
                    <asp:CheckBox ID="Agrupado" runat="server" OnCheckedChanged="Agrupado_CheckedChanged"
                        Text="Agrupado" /></td>
                <td align="center" style="text-align: right">
                    &nbsp;<asp:DropDownList ID="Empresa" runat="server">
                    </asp:DropDownList></td>
                <td align="center" style="text-align: right">
                    <asp:CheckBox ID="Volatil" runat="server" Text="Volatil" />
                    <asp:CheckBox ID="Escoria" runat="server" Text="Escoria" />
                </td>
            </tr>
            <tr>
                <td align="center" colspan="1" style="text-align: right;">
                    <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Final"
                        Width="82px"></asp:Label>&nbsp;
                    </td>
                <td align="center" colspan="1" style="text-align: left">
                    <asp:TextBox ID="FECHAFIN" runat="server" Width="96px"></asp:TextBox>
                    <asp:CompareValidator ID="CVFecha2" runat="server" ControlToValidate="FECHAFIN" ErrorMessage="*"
                        Height="13px" Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="1px"></asp:CompareValidator></td>
                <td align="center" colspan="1">
                </td>
                <td align="center" colspan="1">
                    &nbsp;</td>
                <td align="center" colspan="1">
                    <asp:CheckBox ID="Industria" runat="server" Text="Industria" />
                    <asp:CheckBox ID="Patio" runat="server" Text="Patio" /></td>
            </tr>
            <tr>
                <td align="center" colspan="1">
                    &nbsp; &nbsp;&nbsp;</td>
                <td align="center" colspan="1">
                </td>
                <td align="center" colspan="1">
                </td>
                <td align="center" colspan="1">
                </td>
                <td align="center" colspan="1">
                    <asp:Button ID="Imprimir" runat="server" Font-Bold="True" ForeColor="#336677" Text="Imprimir" OnClick="Imprimir_Click" />
                    <asp:Button ID="Cancelar" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cancelar" OnClick="Cancelar_Click" />
                    </td>
            </tr>
            <tr>
                <td align="left" colspan="5">
                    <asp:Label ID="mensaje" runat="server" Width="504px"></asp:Label>&nbsp;
                </td>
            </tr>
        </table>
    </div>    
</asp:Content>