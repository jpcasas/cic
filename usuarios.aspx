<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Control de Usuarios" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text=""
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
            
            conn = BIBLIOTECA.Conectar(Mensaje)
            ssql = "SELECT CODIGO " & _
                   " FROM USUARIOS" & _
                   " UNION " & _
                   " SELECT '..' AS CODIGO1" & _
                   " FROM USUARIOS AS USUARIOS_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "USUARIOS")
            'Combo1 Usuarios
            Me.CODIGOS.DataSource = DtSet.Tables("USUARIOS").DefaultView
            Me.CODIGOS.DataTextField = "CODIGO"
            ' Asigna el valor del value en el DropDownList
            Me.CODIGOS.DataValueField = "CODIGO"
            Me.CODIGOS.DataBind()
            
            'Combo2 Grupos
            ssql = "SELECT GRUPO FROM GRUPOS"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DtSet, "GRUPOS")
            Me.GRUPO.DataSource = DtSet.Tables("GRUPOS").DefaultView
            Me.GRUPO.DataTextField = "GRUPO"
            ' Asigna el valor del value en el DropDownList
            Me.GRUPO.DataValueField = "GRUPO"
            Me.GRUPO.DataBind()
            'Cerrar Conexion
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
        'se indica que el boton actualizar no creara un nuevo registro si no que 
        'solo actualizara los datos modificados
        Session("Nuevoreg") = "NO"
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT * FROM USUARIOS WHERE CODIGO='" & Me.CODIGOS.SelectedValue & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "USUARIOS")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("USUARIOS").Rows
            For Each MyDataColumn In DtSet.Tables("USUARIOS").Columns
                Select Case MyDataColumn.ColumnName
                    Case "CODIGO"
                        CODIGO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.CODIGO.Enabled = False
                    Case "NOMBRE"
                        NOMBRE.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "CLAVE"
                        CLAVE.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.CODIGO.Enabled = False
                    Case "GRUPO"
                        GRUPO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "ESTADO"
                        estado.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                End Select
            Next MyDataColumn
        Next MyDataRow
    End Sub
    Protected Sub BtnNuevo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.CLAVE.Enabled = True
        Me.CODIGO.Enabled = True
        Session("Nuevoreg") = "SI"
        Me.CODIGO.Text = ""
        Me.NOMBRE.Text = ""
        Me.CLAVE.Text = ""
        Me.GRUPO.Text = "USUARIO"
    End Sub

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Mensaje As String
        Dim Seguridad As New Seguridad
        
        ssql = ""
        If Me.CODIGO.Text = "" Then
            'MsgBox("No se puede insertar un código nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un código nulo"
            Exit Sub
        End If
        If Session("NuevoReg") = "SI" Then
            ssql = "INSERT INTO USUARIOS ( CODIGO, NOMBRE, CLAVE, GRUPO,ESTADO)" & _
                   " VALUES ('" & CODIGO.Text & "', '" & NOMBRE.Text & "', '" & Seguridad.Encriptar(CLAVE.Text) & "','" & GRUPO.Text & "','" & ESTADO.Text & "')"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "Usuarios", "Codigo:" & Me.CODIGO.Text & ";Nombre:" & Me.NOMBRE.Text & ";Grupo:" & Me.GRUPO.Text & ";Estado:  " & Me.ESTADO.Text, Session("GRUPOUS"))
        ElseIf Session("NuevoReg") = "NO" Then
            ssql = "UPDATE USUARIOS " & _
                   " SET   USUARIOS.NOMBRE = '" & NOMBRE.Text & "', USUARIOS.ESTADO = '" & ESTADO.Text & "', USUARIOS.GRUPO = '" & GRUPO.Text & "'" & _
                   " WHERE USUARIOS.CODIGO = '" & CODIGO.Text & "'"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Usuarios", "Codigo:" & Me.CODIGO.Text & ";Nombre:" & Me.NOMBRE.Text & ";Grupo:" & Me.GRUPO.Text & ";Estado:  " & Me.ESTADO.Text, Session("GRUPOUS"))
        End If
        Mensaje = ""
        Biblioteca.EjecutarSql(Mensaje, ssql)
        me.mensaje.Text=Mensaje
    End Sub

    Protected Sub CODIGO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.CODIGO.Text = UCase(Me.CODIGO.Text)
    End Sub

    Protected Sub Eliminar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String = ""
        Dim conn As SqlConnection
        Dim DtReader As SqlDataReader
        Dim Mensaje As String = ""
        Dim Seguridad As New Seguridad
        
        conn = Biblioteca.Conectar(Mensaje)
        ssql = " SELECT DISTINCT OPERARIOBASCULA " & _
               " FROM HISTORICO_ENTREGAS " & _
               " WHERE OPERARIOBASCULA = '" & Me.CODIGO.Text & "'"
        DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
        If DtReader.Read Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El usuario tiene Historico de Entregas  " & vbCrLf & "No se puede Eliminar"
        Else
            DtReader.Close()
            ssql = " SELECT DISTINCT OPERARIOBASCULA " & _
                   " FROM ENTREGAS " & _
                   " WHERE OPERARIOBASCULA = '" & Me.CODIGO.Text & "'"
            DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
            If DtReader.Read Then
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "El Proveedor tiene Entregas  " & vbCrLf & "No se puede Eliminar"
            Else
                DtReader.Close()
                ssql = "DELETE FROM USUARIOS" & _
                       " WHERE CODIGO = '" & Me.CODIGO.Text & "'"
                If Biblioteca.EjecutarSql(Mensaje, ssql) Then
                    Seguridad.RegistroAuditoria(Session("Usuario"), "Eliminar", "Usuarios", "Codigo:" & Me.CODIGO.Text & ";Nombre:" & Me.NOMBRE.Text & ";Grupo:" & Me.GRUPO.Text & ";Estado:  " & Me.ESTADO.Text, Session("GRUPOUS"))
                    Me.mensaje.ForeColor = Color.Blue
                    Me.mensaje.Text = "El Registro se ha eliminado"
                Else
                    Me.mensaje.ForeColor = Color.Red
                    Me.mensaje.Text = "No se ha Eliminado el Registro"
                End If
            End If
        End If
        Biblioteca.DesConectar(conn)
    End Sub

    Protected Sub CambiarClave_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Session("USUARIOCAMBIOPASWWORD") = Me.CODIGO.Text
        Biblioteca.AbreVentana("CambiarContrasena.aspx", Page)
    End Sub

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        
        ssql = "SELECT * FROM USUARIOS"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "USUARIOS.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "USUARIOS"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "USUARIOS", "USUARIOS:Todos", Session("GRUPOUS"))
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
        &nbsp;&nbsp;<table>
            <tr>
                <td align="right" style="width: 167px; height: 6px; text-align: right;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Código" ForeColor="#336677"></asp:Label></td>
                <td style="width: 147px; height: 6px;">
                    <asp:DropDownList ID="CODIGOS" runat="server" OnSelectedIndexChanged="CODIGOS_SelectedIndexChanged"
                        Width="155px" AutoPostBack="True">
                    </asp:DropDownList></td>
                <td height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 13px;">
                </td>
                <td style="width: 147px; height: 13px;">
                </td>
                <td height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; text-align: right;">
                    <asp:Label ID="Label1" runat="server" Text="Código" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 147px" align="left">
                    <asp:TextBox ID="CODIGO" runat="server" OnTextChanged="CODIGO_TextChanged" Enabled="False"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; text-align: right;">
                    <asp:Label ID="Label3" runat="server" Text="Nombre de Usuario" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 147px" align="left">
                    <asp:TextBox ID="NOMBRE" runat="server" EnableTheming="True"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; text-align: right;">
                    <asp:Label ID="Label4" runat="server" Text="Clave" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="CLAVE" runat="server" TextMode="Password" Enabled="False"></asp:TextBox>
                <asp:Button ID="CambiarClave" runat="server" Text="Cambiar Clave" ForeColor="#336677" Font-Bold="True" Width="102px" OnClick="CambiarClave_Click" /></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 24px; text-align: right;">
                    <asp:Label ID="Label2" runat="server" Text="Grupo" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 147px; height: 24px;" align="left">
                    <asp:DropDownList ID="GRUPO" runat="server">
                    </asp:DropDownList></td>
                <td align="left" style="width: 79px; height: 24px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; text-align: right;">
                    <asp:Label ID="Label5" runat="server" Text="Estado" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 147px" align="left">
                    <asp:DropDownList ID="ESTADO" runat="server">
                        <asp:ListItem Value="A">Activo</asp:ListItem>
                        <asp:ListItem Value="R">Retirado</asp:ListItem>
                    </asp:DropDownList></td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="center" colspan="2" style="height: 26px">
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                   <asp:Button ID="BtnNuevo" runat="server" OnClick="BtnNuevo_Click" Text="Nuevo" ForeColor="#336677" Font-Bold="True" />
                    <asp:Button ID="BtnActualizar" runat="server" Text="Acualizar" OnClick="BtnActualizar_Click" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" />
                    <asp:Button ID="Eliminar" runat="server" Font-Bold="True" Font-Italic="False" Font-Overline="False"
                        Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Eliminar_Click"
                        Text="Eliminar" /></td>
                <td align="center" colspan="1" height="1" style="width: 79px">
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