<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Grupos" %>

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
            
            Mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            Mensaje = ""
            conn = BIBLIOTECA.Conectar(Mensaje)
            ssql = " SELECT * FROM GRUPOS " & _
                   " UNION" & _
                   " SELECT '..' AS GRUPO1, '.' AS DESCRIPCION1 " & _
                   " FROM GRUPOS AS GRUPOS_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "GRUPOS")
            'Combo1 Usuarios
            Me.CODGRUPO.DataSource = DtSet.Tables("GRUPOS").DefaultView
            Me.CODGRUPO.DataTextField = "GRUPO"
            ' Asigna el valor del value en el DropDownList
            Me.CODGRUPO.DataValueField = "GRUPO"
            Me.CODGRUPO.DataBind()
        End If
    End Sub

    Protected Sub BtnNuevo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.GRUPO.Enabled = True
        Session("Nuevoreg") = "SI"
        Me.GRUPO.Text = ""
        Me.DESCRIPCION.Text = ""
    End Sub

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Mensaje As String
        Dim Seguridad As New Seguridad
        
        ssql = ""
        If Me.GRUPO.Text = "" Then
            'MsgBox("No se puede insertar un código nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un código nulo"
            Exit Sub
        End If
        If Session("NuevoReg") = "SI" Then
            ssql = "INSERT INTO GRUPOS ( GRUPO, DESCRIPCION)" & _
                   " VALUES ('" & Me.GRUPO.Text & "', '" & Me.DESCRIPCION.Text & "')"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "Grupos", "Grupo:" & Me.GRUPO.Text & ";Descripción:" & Me.DESCRIPCION.Text, Session("GRUPOUS"))
        ElseIf Session("NuevoReg") = "NO" Then
            ssql = " UPDATE GRUPOS " & _
                   " SET   GRUPOS.DESCRIPCION= '" & DESCRIPCION.Text & "'" & _
                   " WHERE GRUPOS.GRUPO = '" & GRUPO.Text & "'"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Grupos", "Grupo:" & Me.GRUPO.Text & ";Descripción:" & Me.DESCRIPCION.Text, Session("GRUPOUS"))
        End If
        Mensaje = ""
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            If Session("NuevoReg") = "SI" Then
                Biblioteca.CrearPermisosGrupo(GRUPO.Text)
            End If
        End If
    End Sub

    Protected Sub CODIGO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.GRUPO.Text = UCase(Me.GRUPO.Text)
    End Sub

    Protected Sub CODGRUPO_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
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
        ssql = "SELECT * FROM GRUPOS WHERE GRUPO='" & Me.CODGRUPO.SelectedValue & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "GRUPOS")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("GRUPOS").Rows
            For Each MyDataColumn In DtSet.Tables("GRUPOS").Columns
                Select Case MyDataColumn.ColumnName
                    Case "GRUPO"
                        GRUPO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.GRUPO.Enabled = False
                    Case "DESCRIPCION"
                        DESCRIPCION.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.GRUPO.Enabled = False
                End Select
            Next MyDataColumn
        Next MyDataRow
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<script language="JavaScript"> 

</script>
    <div>
        <table>
            <tr>
                <td align="right" style="width: 167px; height: 6px;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Grupo" ForeColor="#336677"></asp:Label></td>
                <td style="width: 167px; height: 6px;">
                    <asp:DropDownList ID="CODGRUPO" runat="server" Width="155px" AutoPostBack="True" OnSelectedIndexChanged="CODGRUPO_SelectedIndexChanged">
                    </asp:DropDownList></td>
                <td height="1" style="width: 79px">
                </td>
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
                    <asp:Label ID="Label1" runat="server" Text="Nombre" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 167px" align="left">
                    <asp:TextBox ID="GRUPO" runat="server" OnTextChanged="CODIGO_TextChanged" Enabled="False"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Descripción"></asp:Label></td>
                <td style="width: 167px" align="left">
                    <asp:TextBox ID="DESCRIPCION" runat="server" OnTextChanged="CODIGO_TextChanged"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                    </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    </td>
                <td style="width: 167px" align="left">
                    <asp:Button ID="BtnNuevo" runat="server" OnClick="BtnNuevo_Click" Text="Nuevo" ForeColor="#336677" Font-Bold="True" />
                    <asp:Button ID="BtnActualizar" runat="server" Text="Acualizar" OnClick="BtnActualizar_Click" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" /></td>
                                        
                <td align="left" height="1" style="width: 79px">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 24px;">
                    </td>
                <td style="width: 167px; height: 24px;" align="left">
                    </td>
                <td align="left" style="width: 79px; height: 24px">
                </td>
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
                <td align="center" colspan="2" style="height: 26px">
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                    &nbsp;&nbsp;
                    </td>
                <td align="center" colspan="1" height="1" style="width: 79px">
                    </td>
            </tr>
        </table>
    </div>    
</asp:Content>