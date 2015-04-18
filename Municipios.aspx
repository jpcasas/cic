<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Control de Municipios" %>

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
            ssql = " SELECT  NOMBRE +'_'+ NUMERO AS CIUDAD " & _
                   " FROM MUNICIPIOS" & _
                   " UNION " & _
                   " SELECT '..' AS CIUDAD1 " & _
                   " FROM MUNICIPIOS AS MUNICIPIOS_1"
            
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "MUNICIPIOS")
            'Combo1 Usuarios
            Me.CODIGOS.DataSource = DtSet.Tables("MUNICIPIOS").DefaultView
            Me.CODIGOS.DataTextField = "CIUDAD"
            ' Asigna el valor del value en el DropDownList
            Me.CODIGOS.DataValueField = "CIUDAD"
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
        Numero1 = Trim(Right(Me.CODIGOS.SelectedValue, Len(Me.CODIGOS.SelectedValue) - InStr(Me.CODIGOS.SelectedValue, "_", CompareMethod.Text)))
        Descripcion1 = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT * FROM MUNICIPIOS WHERE NUMERO='" & Numero1 & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "MUNICIPIOS")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("MUNICIPIOS").Rows
            For Each MyDataColumn In DtSet.Tables("MUNICIPIOS").Columns
                Select Case MyDataColumn.ColumnName
                    Case "NUMERO"
                        NUMERO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.NUMERO.Enabled = False
                    Case "NOMBRE"
                        NOMBRE.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                End Select
            Next MyDataColumn
        Next MyDataRow
    End Sub
    Protected Sub BtnNuevo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.NUMERO.Enabled = True
        Session("Nuevoreg") = "SI"
        Me.NUMERO.Text = ""
        Me.NOMBRE.Text = ""
    End Sub

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Mensaje As String
        Dim Seguridad As New Seguridad
        
        ssql = ""
        If Me.NUMERO.Text = "" Then
            'MsgBox("No se puede insertar un número nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un número nulo"
            Exit Sub
        End If
        If Session("NuevoReg") = "SI" Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "Cooperativas", "Código:" & Me.NUMERO.Text, Session("GRUPOUS"))
            ssql = "INSERT INTO MUNICIPIOS (NUMERO, NOMBRE )" & _
                   " VALUES ('" & Me.NUMERO.Text & "', '" & NOMBRE.Text & "')"
        ElseIf Session("NuevoReg") = "NO" Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Cooperativas", "Código:" & Me.NUMERO.Text, Session("GRUPOUS"))
            ssql = "UPDATE MUNICIPIOS " & _
                   " SET MUNICIPIOS.NOMBRE ='" & Me.NOMBRE.Text & "'" & _
                   " WHERE MUNICIPIOS.NUMERO ='" & Me.NUMERO.Text & "'"
        End If
        Mensaje = ""
        Biblioteca.EjecutarSql(Mensaje,  ssql)
    End Sub

    Protected Sub CODIGO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.NUMERO.Text = UCase(Me.NUMERO.Text)
    End Sub

    Protected Sub Eliminar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String = ""
        Dim conn As SqlConnection
        Dim DtReader As SqlDataReader
        Dim Mensaje As String = ""
        Dim Seguridad As New Seguridad
        
        conn = Biblioteca.Conectar(Mensaje)
        ssql = " SELECT MUNICIPIO " & _
               " FROM HISTORICO_ENTREGAS " & _
               " WHERE MUNICIPIO ='" & Me.NUMERO.Text & "'"
        DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
        If DtReader.Read Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El Municipio tiene Historico de Entregas  " & vbCrLf & "No se puede Eliminar"
        Else
            DtReader.Close()
            ssql = " SELECT MUNICIPIO " & _
               " FROM ENTREGAS " & _
               " WHERE MUNICIPIO = '" & Me.NUMERO.Text & "'"
            DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
            If DtReader.Read Then
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "El Municipio tiene Entregas  " & vbCrLf & "No se puede Eliminar"
            Else
                DtReader.Close()
                ssql = "DELETE FROM MUNICIPIOS" & _
                       " WHERE NUMERO = '" & Me.NUMERO.Text & "'"
                If Biblioteca.EjecutarSql(Mensaje, ssql) Then
                    Seguridad.RegistroAuditoria(Session("Usuario"), "Eliminar", "Cooperativas", "Código:" & Me.NUMERO.Text, Session("GRUPOUS"))
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

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        
        ssql = "SELECT * FROM MUNICIPIOS"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "MUNICIPIOS.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "MUNICIPIOS"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "MUNICIPIOS", "MUNICIPIOS:Todos", Session("GRUPOUS"))
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
    <div>
        &nbsp;&nbsp;<table>
            <tr>
                <td align="right" style="width: 167px; height: 6px;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Municipio" ForeColor="#336677"></asp:Label></td>
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
                <td height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label1" runat="server" Text="Número" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="NUMERO" runat="server" OnTextChanged="CODIGO_TextChanged" Width="34px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label3" runat="server" Text="Nombre" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="NOMBRE" runat="server" EnableTheming="True" Width="274px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    </td>
                <td style="width: 167px" align="left">
                    </td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" colspan="2" style="height: 26px">
                    <asp:Button ID="BtnNuevo" runat="server" OnClick="BtnNuevo_Click" Text="Nuevo" ForeColor="#336677" Font-Bold="True" />
                    <asp:Button ID="BtnActualizar" runat="server" Text="Acualizar" OnClick="BtnActualizar_Click" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" />
                    <asp:Button ID="Eliminar" runat="server" Font-Bold="True" Font-Italic="False" Font-Overline="False"
                        Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Eliminar_Click"
                        Text="Eliminar" />
                </td>
                <td align="center" colspan="1" style="width: 79px; text-align: left; height: 26px;">
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