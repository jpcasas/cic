<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Entradas Carbón Mes" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim Mensaje As String
        Dim ssql As String = ""
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim conn As SqlConnection
        
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        Mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
        If Mensaje = "" Then
            Response.Redirect("Principal.aspx")
        Else
            CType(Master.FindControl("Label1"), Label).Text = Mensaje
        End If
        If Not Page.IsPostBack Then
            'CARGAR(PROCUCTOS)
            conn = Biblioteca.Conectar(Mensaje)
            DtSet = New DataSet
            ssql = " SELECT PRODUCTO.CODIGO, PRODUCTO.NOMBRE" & _
                   " FROM PRODUCTO " & _
                   " UNION " & _
                   " SELECT '..' AS CODIGO1, '...' AS NOMBRE1 " & _
                   " FROM PRODUCTO AS PRODUCTO_1"
            DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DtSet, "PRODUCTO")
            Me.CProducto.DataSource = DtSet.Tables("PRODUCTO").DefaultView
            Me.CProducto.DataTextField = "NOMBRE"
            Me.CProducto.DataValueField = "CODIGO"
            Me.CProducto.DataBind()
            'CargarGridView(" WHERE PRODUCTO.NOMBRE LIKE '%CENIZA%' AND (FECHA BETWEEN CONVERT(DATETIME, '" & Format(DateAdd(DateInterval.Day, -30, Today), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(Today, "yyyy-MM-dd 00:00:00") & "', 102))")
            Biblioteca.DesConectar(conn)
        End If
        me.NomBoton.Text="SalCeniza"
    End Sub
      
    Protected Sub CENIZA_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        Dim index As Integer = Convert.ToInt32(e.CommandArgument)
        Dim row As GridViewRow = CENIZA.Rows(index)
        
        Me.CodSalida.Text = Trim(Server.HtmlDecode(row.Cells(1).Text))
    End Sub
    
    Protected Sub Editar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Nombre de Botones = : EntrCarbMes;TblMuestrasMes;AnalisisLabAno;EntrCarbAno;TblMuestrasAno
        Dim Biblioteca As New Biblioteca
        Session("CodSal") = Me.CodSalida.Text
        Session("CodProducto") = Me.CProducto.SelectedItem.Value
        Session("NomProducto") = Me.CProducto.SelectedItem.Text
        Session("ParamBDProd") = "Actualizar"
        
        If Me.CProducto.SelectedItem.Value = ".." Then
            Biblioteca.MostrarMensaje(Page, "Seleccione un producto", 2)
        End If
        Select Case Me.CProducto.SelectedItem.Text
            Case "CENIZA"
                Biblioteca.AbreVentana("SalidaCeniza.aspx", Page, "height=600,width=700,location=1")
            Case Else
                Biblioteca.AbreVentana("SalidaMaterialesBD.aspx", Page, "height=600,width=700,location=1")
                'Case "TblMuestrasMes"
                '    Biblioteca.AbreVentana("MuestrasMes.aspx", Page)
                'Case "AnalisisLabAno"
                
                'Case "EntrCarbAno"
                '    Biblioteca.AbreVentana("EntradaCarbonAno.aspx", Page)
                'Case "TblMuestrasAno"
                '   Biblioteca.AbreVentana("MuestrasAno.aspx", Page)
        End Select
    End Sub

    Protected Sub Insertar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Nombre de Botones = : EntrCarbMes;TblMuestrasMes;AnalisisLabAno;EntrCarbAno;TblMuestrasAno
        Dim Biblioteca As New Biblioteca
        Session("CodSal") = Me.CodSalida.Text
        Session("CodProducto") = Me.CProducto.SelectedItem.Value
        Session("NomProducto") = Me.CProducto.SelectedItem.Text
        Session("ParamBDProd") = "Insertar"
        
        If Me.CProducto.SelectedItem.Value = ".." Then
            Biblioteca.MostrarMensaje(Page, "Seleccione un producto", 2)
        End If
        Select Case Me.CProducto.SelectedItem.Text
            Case "CENIZA"
                Biblioteca.AbreVentana("SalidaCeniza.aspx", Page, "height=600,width=700,location=1")
            Case Else
                Biblioteca.AbreVentana("SalidaMaterialesBD.aspx", Page, "height=600,width=700,location=1")
                'Case "TblMuestrasMes"
                '    Biblioteca.AbreVentana("MuestrasMes.aspx", Page)
                'Case "AnalisisLabAno"
                '    
                'Case "EntrCarbAno"
                '    Biblioteca.AbreVentana("EntradaCarbonAno.aspx", Page)
                'Case "TblMuestrasAno"
                '    Biblioteca.AbreVentana("MuestrasAno.aspx", Page)
        End Select
    End Sub

    Protected Sub Eliminar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Nombre de Botones = : EntrCarbMes;TblMuestrasMes;AnalisisLabAno;EntrCarbAno;TblMuestrasAno
        Dim Biblioteca As New Biblioteca
        Session("CodSal") = Me.CodSalida.Text
        Session("CodProducto") = Me.CProducto.SelectedItem.Value
        Session("NomProducto") = Me.CProducto.SelectedItem.Text
        Session("ParamBDProd") = "Eliminar"
        
        If Me.CProducto.SelectedItem.Value = ".." Then
            Biblioteca.MostrarMensaje(Page, "Seleccione un producto", 2)
        End If
        
        Select Case Me.CProducto.SelectedItem.Text
            Case "CENIZA"
                Biblioteca.AbreVentana("SalidaCeniza.aspx", Page, "height=600,width=700,location=1")
            Case Else
                Biblioteca.AbreVentana("SalidaMaterialesBD.aspx", Page, "height=600,width=700,location=1")
                'Case "TblMuestrasMes"
                '    Biblioteca.AbreVentana("MuestrasMes.aspx", Page)
                'Case "AnalisisLabAno"
                '    
                'Case "EntrCarbAno"
                '    Biblioteca.AbreVentana("EntradaCarbonAno.aspx", Page)
                'Case "TblMuestrasAno"
                '    Biblioteca.AbreVentana("MuestrasAno.aspx", Page)
        End Select
    End Sub

    Protected Sub EntrCarbMes_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        If Me.CProducto.SelectedItem.Value = ".." Then
            Biblioteca.MostrarMensaje(Page, "Seleccione un producto", 2)
        End If
        CargarGridView()
    End Sub
    
    Private Sub CargarGridView()
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim Mensaje As String
        Dim ssql As String
        
        Dim CadenaSalida As String = ""
        Dim CadenaFecha As String = ""
        Dim CadenaWhere As String = ""
        
        Mensaje = ""
        Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
        If Mensaje = "" Then
            Response.Redirect("Principal.aspx")
        Else
            CType(Master.FindControl("Label1"), Label).Text = Mensaje
        End If
        Mensaje = ""
        
        If Me.CodSalIn.Text <> "" And Me.CodSalFin.Text <> "" Then
            CadenaSalida = "(CODIGOENTRADA BETWEEN '" & Me.CodSalIn.Text & "' AND '" & Me.CodSalFin.Text & "')"
        End If
        If Me.FechaIn.Text <> "" And Me.FechaFin.Text <> "" Then
            CadenaFecha = "(FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FechaIn.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FechaFin.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        End If
               
        If CadenaSalida <> "" Then
            CadenaWhere = CadenaSalida & " AND "
        End If
        If CadenaFecha <> "" Then
            CadenaWhere = CadenaWhere & CadenaFecha & " AND "
        End If
        
        If CadenaWhere <> "" Then
            CadenaWhere = " WHERE PRODUCTO.NOMBRE LIKE '%" & Me.CProducto.SelectedItem.Text & "%' AND " & Left(CadenaWhere, Len(CadenaWhere) - 4)
        Else
            CadenaWhere = " WHERE PRODUCTO.NOMBRE LIKE '%" & Me.CProducto.SelectedItem.Text & "%' AND (FECHA BETWEEN CONVERT(DATETIME, '" & Format(DateAdd(DateInterval.Day, -2, Today), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(Today, "yyyy-MM-dd 00:00:00") & "', 102))"
        End If
               
        CType(Master.FindControl("Label1"), Label).Text = CType(Master.FindControl("Label1"), Label).Text & "\" & Me.SalCeniza.Text & " " & Me.CProducto.SelectedItem.Text
        Me.CENIZA.Caption = Me.CProducto.SelectedItem.Text
        Me.NomBoton.Text = "EntrCarbMes"
        
        ssql = " SELECT CODIGOENTRADA AS [Cod Entrada], " & _
              " RIGHT('0' + LEFT(DAY(CONTROLMATERIALES.FECHA), 2), 2) + '/' + RIGHT('0' + LEFT(MONTH(CONTROLMATERIALES.FECHA), 2), 2) + '/' + LEFT(YEAR(CONTROLMATERIALES.FECHA), 4) AS [Fecha Entrada], " & _
              " PRODUCTO.NOMBRE as Producto, PESONETO as [Peso neto], Conductor, Placa, OperadorBascula as [Operador]" & _
              " FROM   CONTROLMATERIALES INNER JOIN " & _
                       " PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO " & _
              CadenaWhere & _
              " ORDER BY FECHA DESC, CODIGOENTRADA DESC"

        conn = BIBLIOTECA.Conectar(Mensaje)
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "CONTROLMATERIALES")
        'llenar datagrid
        Me.CENIZA.DataSource = DtSet.Tables("CONTROLMATERIALES").DefaultView
        Me.CENIZA.DataBind()
        BIBLIOTECA.DesConectar(conn)
    End Sub

    Protected Sub CProducto_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        CargarGridView()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
    <div>
        <table border="0" id="TABLE1"> 
            <tr>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:Label ID="Label1" runat="server" ForeColor="#336677" Text="Producto"></asp:Label></td>
                <td align="left" colspan="1" style="width: 546px; height: 1px">
                    </td>
                <td align="right" colspan="1" style="width: 126px; height: 1px">
                    <asp:Label ID="Label7" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cód Inicial"
                        Width="80px"></asp:Label></td>
                <td align="left" colspan="1" style="height: 1px">
                    <asp:TextBox ID="CodSalIn" runat="server" Width="99px"></asp:TextBox></td>
                <td align="left" colspan="1" style="height: 1px; text-align: left;">
                    &nbsp;<asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="#336677" Text="FechaIn"
                        Width="21px"></asp:Label></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:TextBox ID="FechaIn" runat="server" Width="95px"></asp:TextBox></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    &nbsp;<asp:CompareValidator
                        ID="cvFecha1" runat="server" ControlToValidate="FechaIn" ErrorMessage="*"
                        Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="3px"></asp:CompareValidator></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    </td>
                <td align="right" colspan="1" style="height: 1px; width: 126px;">
                    </td>
                <td align="left" colspan="1" style="height: 1px">
                    </td>
                <td align="right" colspan="1" style="height: 1px; width: 126px;">
                    </td>
                <td align="left" colspan="4" style="height: 1px">
                    </td>
                <td align="left" colspan="1" style="height: 1px">
                </td>
            </tr>
            <tr>
                <td align="right" colspan="1" style="width: 126px; height: 1px">
                    <asp:DropDownList ID="CProducto" runat="server" AutoPostBack="True" 
                        Width="245px" OnSelectedIndexChanged="CProducto_SelectedIndexChanged">
                    </asp:DropDownList></td>
                <td align="left" colspan="1" style="width: 546px; height: 1px">
                    </td>
                <td align="right" colspan="1" style="width: 126px; height: 1px">
                    <asp:Label ID="Label8" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cód Final"
                        Width="84px"></asp:Label></td>
                <td align="left" colspan="1" style="height: 1px">
                    <asp:TextBox ID="CodSalFin" runat="server" Width="99px"></asp:TextBox></td>
                <td align="left" colspan="1" style="height: 1px; text-align: left;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" ForeColor="#336677" Text="FechaFin"
                        Width="36px"></asp:Label></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:TextBox ID="FechaFin" runat="server" Width="95px"></asp:TextBox></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                 <asp:CompareValidator
                        ID="cvFecha2" runat="server" ControlToValidate="FechaFin" ErrorMessage="*"
                        Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="16px"></asp:CompareValidator></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    </td>
                <td align="right" colspan="1" style="height: 1px; width: 126px;">
                    </td>
                <td align="left" colspan="1" style="height: 1px">
                    </td>
                <td align="right" colspan="1" style="height: 1px; width: 126px;">
                    </td>
                <td align="left" colspan="4" style="height: 1px">
                    &nbsp;</td>
                <td align="left" colspan="1" style="height: 1px">
                    &nbsp;</td>
            </tr>
            <tr>
                <td align="left" colspan="16" style="height: 1px">
                    <asp:Button ID="SalCeniza" runat="server" ForeColor="#336677" Height="23px"
                        Text="Salidas" Width="139px" OnClick="EntrCarbMes_Click" /></td>
            </tr>
            <tr>
                <td align="left" colspan="3">
                    <asp:Button ID="Editar" runat="server" ForeColor="#336677" Text="Editar" OnClick="Editar_Click" />
                    <asp:Button ID="Insertar" runat="server" ForeColor="#336677" Text="Insertar" OnClick="Insertar_Click" />
                    <asp:Button ID="Eliminar" runat="server" ForeColor="#336677" Text="Eliminar" OnClick="Eliminar_Click" /></td>
                <td align="left" colspan="1">
                    <asp:TextBox ID="CodSalida" runat="server" Visible="False" Width="38px"></asp:TextBox></td>
                <td align="left" colspan="1">
                </td>
                <td align="left" colspan="1" style="width: 126px">
                </td>
                <td align="left" colspan="1" style="width: 126px">
                </td>
                <td align="left" colspan="1" style="width: 126px">
                </td>
                <td align="left" colspan="1" style="width: 126px">
                    </td>
                <td align="left" colspan="1">
                    <asp:TextBox ID="Fecha" runat="server" Visible="False" Width="38px"></asp:TextBox></td>
                <td align="left" colspan="1" style="width: 3px">
                    <asp:TextBox ID="NomBoton" runat="server" Visible="False" Width="38px"></asp:TextBox></td>
                <td align="left" colspan="1" style="width: 3px">
                </td>
                <td align="left" colspan="1" style="width: 3px">
                </td>
                <td align="left" colspan="3">
                </td>
            </tr>
            <tr>
                <td align="left" colspan="16">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" colspan="16" height="1">
                    <asp:GridView ID="CENIZA" runat="server" BackColor="White" BorderColor="#CCCCCC"
                        BorderStyle="None" BorderWidth="1px" Caption="Salidas Ceniza" CellPadding="3"
                        Font-Overline="False" ForeColor="#336677" Height="41px" OnRowCommand="CENIZA_RowCommand"
                        Width="166px">
                        <FooterStyle BackColor="White" Font-Bold="True" ForeColor="#000066" />
                        <Columns>
                            <asp:CommandField ButtonType="Button" SelectText="" ShowSelectButton="True" />
                        </Columns>
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Center" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="False" ForeColor="White" />
                        <AlternatingRowStyle Font-Bold="False" Font-Italic="False" Wrap="False" />
                    </asp:GridView>
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 546px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                
                </td>
                <td style="width: 524px" align="right">
                
                </td>
                <td align="left" height="1" style="width: 53px">
                
                </td>
                <td align="left" height="1" style="height: 1px;" colspan="3">
                
                </td>
            </tr>
        </table>
    </div>    
</asp:Content>