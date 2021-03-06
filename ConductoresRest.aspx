﻿<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Control de Conductores Restringidos" %>

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
            Dim BIBLIOTECA As New Biblioteca
            Dim conn As SqlConnection
            Dim DtAdapter As SqlDataAdapter
            Dim DtSet As DataSet
            Dim ssql As String
            Dim Mensaje As String = ""
            
            Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            Mensaje = ""
            conn = BIBLIOTECA.Conectar(mensaje)
            ssql = " SELECT  NOMBRE " & _
                   " FROM CONDUCTORESREST " & _
                   " UNION " & _
                   " SELECT '..' AS NOMBRE1 " & _
                   " FROM CONDUCTORESREST AS CONDUCTORESREST_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "CONDUCTORESREST")
            'Combo1 Usuarios
            Me.CODIGOS.DataSource = DtSet.Tables("CONDUCTORESREST").DefaultView
            Me.CODIGOS.DataTextField = "NOMBRE"
            ' Asigna el valor del value en el DropDownList
            Me.CODIGOS.DataValueField = "NOMBRE"
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
        Dim Mensaje As String
        Mensaje = ""
        
        'se indica que el boton actualizar no creara un nuevo registro si no que 
        'solo actualizara los datos modificados
        Session("Nuevoreg") = "NO"
        
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT * FROM CONDUCTORESREST WHERE NOMBRE='" & Me.CODIGOS.SelectedValue & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "CAMIONESREST")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("CAMIONESREST").Rows
            For Each MyDataColumn In DtSet.Tables("CAMIONESREST").Columns
                Select Case MyDataColumn.ColumnName
                    Case "NOMBRE"
                        NOMBRE.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.NOMBRE.Enabled = False
                    Case "LICENCIA"
                        LICENCIA.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                End Select
            Next MyDataColumn
        Next MyDataRow
    End Sub
    Protected Sub BtnNuevo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.NOMBRE.Enabled = True
        Session("Nuevoreg") = "SI"
        Me.NOMBRE.Text = ""
        Me.LICENCIA.Text = ""
    End Sub

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim ssql As String
        Dim Mensaje As String
        ssql = ""
        If Me.NOMBRE.Text = "" Then
            'MsgBox("No se puede insertar un número nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un nombre nulo"
            Exit Sub
        End If
        If Session("NuevoReg") = "SI" Then
            ssql = "INSERT INTO CONDUCTORESREST ( NOMBRE, LICENCIA)" & _
                   " VALUES ('" & Me.NOMBRE.Text & "', '" & LICENCIA.Text & "')"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "Conductores Restringidos", "Nombre:" & Me.NOMBRE.Text, Session("GRUPOUS"))
        ElseIf Session("NuevoReg") = "NO" Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Conductores Restringidos", "Nombre:" & Me.NOMBRE.Text, Session("GRUPOUS"))
            ssql = "UPDATE CONDUCTORESREST " & _
                   " SET CONDUCTORESREST.LICENCIA ='" & Me.LICENCIA.Text & "'" & _
                   " WHERE CONDUCTORESREST.NOMBRE ='" & Me.NOMBRE.Text & "'"
        End If
        Mensaje = ""
        Biblioteca.EjecutarSql(Mensaje, ssql)
    End Sub

    Protected Sub CODIGO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.NOMBRE.Text = UCase(Me.NOMBRE.Text)
    End Sub

    Protected Sub Eliminar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String = ""
        Dim Mensaje As String = ""
        Dim Seguridad As New Seguridad
        
        ssql = "DELETE FROM CONDUCTORESREST" & _
               " WHERE NOMBRE = '" & Me.NOMBRE.Text & "'"
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Eliminar", "Conductores Restringidos", "Nombre:" & Me.NOMBRE.Text, Session("GRUPOUS"))
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
        
        ssql = "SELECT * FROM CONDUCTORESREST"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "CONDUCTORESREST.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "CONDUCTORESREST"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "ConductoresRest", "Conductores:Todos", Session("GRUPOUS"))
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
        &nbsp;&nbsp;<table>
            <tr>
                <td align="right" style="width: 167px; height: 6px;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Conductor" ForeColor="#336677"></asp:Label></td>
                <td colspan="2" height="1">
                    <asp:DropDownList ID="CODIGOS" runat="server" OnSelectedIndexChanged="CODIGOS_SelectedIndexChanged"
                        Width="286px" AutoPostBack="True">
                    </asp:DropDownList></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 13px;">
                </td>
                <td style="width: 167px; height: 13px;">
                </td>
                <td height="1" style="width: 51px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label1" runat="server" Text="Nombre" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="NOMBRE" runat="server" OnTextChanged="CODIGO_TextChanged" Width="308px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label3" runat="server" Text="Licencia" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="LICENCIA" runat="server" EnableTheming="True" Width="110px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    </td>
                <td style="width: 167px" align="left">
                    </td>
                <td align="left" height="1" style="width: 51px">
                </td>
            </tr>
            <tr>
                <td align="center" colspan="2" style="height: 26px">
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<asp:Button ID="BtnNuevo" runat="server" OnClick="BtnNuevo_Click" Text="Nuevo" ForeColor="#336677" Font-Bold="True" />
                    <asp:Button ID="BtnActualizar" runat="server" Text="Acualizar" OnClick="BtnActualizar_Click" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" />
                    <asp:Button ID="Eliminar" runat="server" Font-Bold="True" Font-Italic="False" Font-Overline="False"
                        Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Eliminar_Click"
                        Text="Eliminar" /></td>
                <td align="center" colspan="1" height="1" style="width: 51px; text-align: left;">
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