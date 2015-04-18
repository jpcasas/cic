﻿<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Empresas" %>

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
            ssql = " SELECT CODIGO + '_' + DESCRIPCION AS EMPRESAS" & _
                   " FROM EMPRESA " & _
                   " UNION " & _
                   " SELECT '..' AS EMPRESA1 " & _
                   " FROM EMPRESA AS EMPRESA_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "EMPRESA")
            'Combo1 Usuarios
            Me.CODIGOS.DataSource = DtSet.Tables("EMPRESA").DefaultView
            Me.CODIGOS.DataTextField = "EMPRESAS"
            ' Asigna el valor del value en el DropDownList
            Me.CODIGOS.DataValueField = "EMPRESAS"
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
        ssql = "SELECT * FROM EMPRESA WHERE CODIGO='" & Numero1 & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "EMPRESA")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("EMPRESA").Rows
            For Each MyDataColumn In DtSet.Tables("EMPRESA").Columns
                Select Case MyDataColumn.ColumnName
                    Case "CODIGO"
                        CODIGO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.CODIGO.Enabled = False
                    Case "DESCRIPCION"
                        DESCRIPCION.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                End Select
            Next MyDataColumn
        Next MyDataRow
    End Sub
    Protected Sub BtnNuevo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.CODIGO.Enabled = True
        Session("Nuevoreg") = "SI"
        Me.CODIGO.Text = ""
        Me.DESCRIPCION.Text = ""
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
            ssql = "INSERT INTO EMPRESA ( CODIGO, DESCRIPCION)" & _
                   " VALUES ('" & Trim(Me.CODIGO.Text) & "', '" & DESCRIPCION.Text & "')"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "EMPRESA", "CODIGO:" & Me.CODIGO.Text & ";Descripcion:" & Me.DESCRIPCION.Text, Session("GRUPOUS"))
        ElseIf Session("NuevoReg") = "NO" Then
            ssql = "UPDATE EMPRESA " & _
                   " SET EMPRESA .DESCRIPCION ='" & Me.DESCRIPCION.Text & "'" & _
                   " WHERE EMPRESA.CODIGO ='" & Me.CODIGO.Text & "'"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "EMPRESA", "CODIGO:" & Me.CODIGO.Text & ";Descripcion:" & Me.DESCRIPCION.Text, Session("GRUPOUS"))
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
        
        ssql = "DELETE FROM EMPRESA" & _
               " WHERE CODIGO = '" & Me.CODIGO.Text & "'"
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Eliminar", "Empresas", "Codigo:" & Me.CODIGO.Text & ";Descripcion:" & Me.DESCRIPCION.Text, Session("GRUPOUS"))
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
        ssql = "SELECT * FROM EMPRESA ORDER BY " & Orden
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "Empresas.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "Empresa"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Empresas", "Empresas:Todas", Session("GRUPOUS"))
    End Sub

    Protected Sub RadioButtonList1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)

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
                <td height="1" style="width: 143px">
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
                    <asp:Label ID="Label3" runat="server" Text="Descripción" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="DESCRIPCION" runat="server" EnableTheming="True" Width="279px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    </td>
                <td style="width: 234px" align="left">
                    </td>
                <td align="left" height="1" style="width: 143px">
                    <asp:RadioButtonList ID="RadioButtonList1" runat="server" Font-Bold="True" ForeColor="#336677"
                        Width="158px" OnSelectedIndexChanged="RadioButtonList1_SelectedIndexChanged">
                        <asp:ListItem Value="CODIGO">Orden por c&#243;digo</asp:ListItem>
                        <asp:ListItem Selected="True" Value="DESCRIPCION">Orden por nombre</asp:ListItem>
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
                <td align="center" colspan="1" height="1" style="width: 143px; text-align: left;">
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