<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Productos" %>


<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Mensaje As String
        Mensaje = ""
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        If Not Page.IsPostBack Then
            Dim BIBLIOTECA As New Biblioteca
            Dim conn As SqlConnection
            Dim DtAdapter As SqlDataAdapter
            Dim DtSet As DataSet
            Dim ssql As String
            
            Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            Mensaje = ""
            conn = BIBLIOTECA.Conectar(Mensaje)
            ssql = " SELECT CODIGO + '_' + NOMBRE AS NPRODUCTO" & _
                   " FROM PRODUCTO " & _
                   " UNION " & _
                   " SELECT '..' AS NPRODUCTO1 " & _
                   " FROM PRODUCTO AS PRODUCTO_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "PRODUCTO")
            'Combo1 Usuarios
            Me.CODIGOS.DataSource = DtSet.Tables("PRODUCTO").DefaultView
            Me.CODIGOS.DataTextField = "NPRODUCTO"
            ' Asigna el valor del value en el DropDownList
            Me.CODIGOS.DataValueField = "NPRODUCTO"
            Me.CODIGOS.DataBind()
            BIBLIOTECA.DesConectar(conn)
        End If
    End Sub

    Protected Sub CODIGOS_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim ssql As String
        Dim MyDataRow As DataRow
        Dim MyDataColumn As DataColumn
        Dim Numero1 As String
        Dim Descripcion1 As String
        Dim Mensaje As String
        Mensaje = ""
        'se indica que el boton actualizar no creara un nuevo registro si no que 
        'solo actualizara los datos modificados
        Session("Nuevoreg") = "NO"
        Numero1 = Trim(Left(Me.CODIGOS.SelectedValue, InStr(Me.CODIGOS.SelectedValue, "_", CompareMethod.Text) - 1))
        Descripcion1 = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT * FROM PRODUCTO WHERE CODIGO='" & Numero1 & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "PRODUCTO")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("PRODUCTO").Rows
            For Each MyDataColumn In DtSet.Tables("PRODUCTO").Columns
                Select Case MyDataColumn.ColumnName
                    Case "CODIGO"
                        CODIGO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.CODIGO.Enabled = False
                    Case "NOMBRE"
                        NOMBRE.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "ENTRADA"
                        Me.Entrada.Checked = IIf(MyDataRow(MyDataColumn.ColumnName) = -1, True, False)
                End Select
            Next MyDataColumn
        Next MyDataRow
    End Sub
    Protected Sub BtnNuevo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.CODIGO.Enabled = True
        Session("Nuevoreg") = "SI"
        Me.CODIGO.Text = ""
        Me.NOMBRE.Text = ""
    End Sub

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim ssql As String
        Dim Mensaje As String
        ssql = ""
        If Me.CODIGO.Text = "" Then
            'MsgBox("No se puede insertar un número nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un código nulo"
            Exit Sub
        End If
        If Session("NuevoReg") = "SI" Then
            ssql = "INSERT INTO PRODUCTO ( CODIGO, NOMBRE)" & _
                   " VALUES ('" & Trim(Me.CODIGO.Text) & "', '" & NOMBRE.Text & "')"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "PRODUCTO", "CODIGO:" & Me.CODIGO.Text & ";Nombre:" & Me.NOMBRE.Text, Session("GRUPOUS"))
        ElseIf Session("NuevoReg") = "NO" Then
            ssql = "UPDATE PRODUCTO " & _
                   " SET PRODUCTO.NOMBRE ='" & Me.NOMBRE.Text & "', ENTRADA = " & IIf(Me.Entrada.Checked = True, -1, 0) & "" & _
                   " WHERE PRODUCTO.CODIGO ='" & Me.CODIGO.Text & "'"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "EMPRESA", "CODIGO:" & Me.CODIGO.Text & ";Nombre:" & Me.NOMBRE.Text, Session("GRUPOUS"))
        End If
        Mensaje = ""
        Biblioteca.EjecutarSql(Mensaje, ssql)
    End Sub

    Protected Sub CODIGO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.CODIGO.Text = UCase(Me.CODIGO.Text)
    End Sub

    Protected Sub Eliminar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String = ""
        Dim Mensaje As String = ""
        Dim Seguridad As New Seguridad
        
        ssql = "DELETE FROM PRODUCTO" & _
               " WHERE CODIGO = '" & Me.CODIGO.Text & "'"
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Eliminar", "PRODUCTO", "Codigo:" & Me.CODIGO.Text & ";Nombre:" & Me.NOMBRE.Text, Session("GRUPOUS"))
            Me.mensaje.ForeColor = Color.Blue
            Me.mensaje.Text = "El Registro se ha eliminado"
        Else
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se ha Eliminado el Registro"
        End If
    End Sub

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim Orden As String
        Orden = RadioButtonList1.SelectedValue
        ssql = "SELECT * FROM PRODUCTO ORDER BY " & Orden
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "PRODUCTOS.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "PRODUCTO"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Productos", "Productos:Todos", Session("GRUPOUS"))
    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<script language="JavaScript"> 

</script>
    <div>
        &nbsp;&nbsp;<table>
            <tr>
                <td align="right" style="width: 167px; height: 6px;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Códigos" ForeColor="#336677"></asp:Label></td>
                <td colspan="2" height="1">
                    <asp:DropDownList ID="CODIGOS" runat="server" OnSelectedIndexChanged="CODIGOS_SelectedIndexChanged"
                        Width="286px" AutoPostBack="True">
                    </asp:DropDownList></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 13px;">
                </td>
                <td style="width: 234px; height: 13px;">
                </td>
                <td height="1" style="width: 159px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label1" runat="server" Text="Código" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="CODIGO" runat="server" OnTextChanged="CODIGO_TextChanged" Width="89px" Wrap="False"></asp:TextBox>
                    </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label3" runat="server" Text="Nombre" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="NOMBRE" runat="server" EnableTheming="True" Width="279px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Entra"></asp:Label></td>
                <td style="width: 234px" align="left">
                    <asp:CheckBox ID="Entrada" runat="server" /></td>
                <td align="left" height="1" style="width: 159px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    </td>
                <td style="width: 234px" align="left">
                    </td>
                <td align="left" height="1" style="width: 159px">
                    <asp:RadioButtonList ID="RadioButtonList1" runat="server" Font-Bold="True" ForeColor="#336677" Width="158px"  >
                        <asp:ListItem Value="CODIGO">Orden por c&#243;digo</asp:ListItem>
                        <asp:ListItem Value="NOMBRE" Selected="True">Orden por nombre</asp:ListItem>
                    </asp:RadioButtonList></td>
            </tr>
            <tr>
                <td align="center" colspan="2" style="height: 26px">
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<asp:Button ID="BtnNuevo" runat="server" OnClick="BtnNuevo_Click" Text="Nuevo" ForeColor="#336677" Font-Bold="True" />
                    <asp:Button ID="BtnActualizar" runat="server" Text="Acualizar" OnClick="BtnActualizar_Click" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" />
                    <asp:Button ID="Eliminar" runat="server" Font-Bold="True" Font-Italic="False" Font-Overline="False"
                        Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Eliminar_Click"
                        Text="Eliminar" /></td>
                <td align="center" colspan="1" height="1" style="width: 159px; text-align: left;">
                    <asp:Button ID="Imprimir" runat="server" Font-Bold="True" Font-Italic="False" Font-Overline="False"
                        Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Imprimir_Click"
                        Text="Imprimir" /></td>
            </tr>
            <tr>
                <td align="center" colspan="3" height="1" style="text-align: left">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>    
</asp:Content>