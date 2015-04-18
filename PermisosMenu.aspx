<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Permisos Menú" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        If Not Page.IsPostBack Then
            Call Actualizar()
        End If
        Me.mensaje.Text = ""
    End Sub
    
    Private Sub Actualizar()
        Dim BIBLIOTECA As New Biblioteca
        Dim Mensaje As String = ""
        Dim DtAdapter As SqlDataAdapter
        Dim conn As SqlConnection
        Dim DtSet As DataSet
        Dim ssql As String
        
        Mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
        If Mensaje = "" Then
            Response.Redirect("Principal.aspx")
        Else
            CType(Master.FindControl("Label1"), Label).Text = Mensaje
        End If
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT GRUPO " & _
               " FROM GRUPOS " & _
               " UNION " & _
               " SELECT '..' AS GRUPO1 " & _
               " FROM GRUPOS AS GRUPOS_1"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "GRUPOS")
        'Combo1 Usuarios
        Me.GRUPO.DataSource = DtSet.Tables("GRUPOS").DefaultView
        Me.GRUPO.DataTextField = "GRUPO"
        ' Asigna el valor del value en el DropDownList
        Me.GRUPO.DataValueField = "GRUPO"
        Me.GRUPO.DataBind()
        BIBLIOTECA.DesConectar(conn)
    End Sub

    Protected Sub OPCIONESMENU_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs)        
        If e.CommandName = "Actualizar" Then
            Dim BIBLIOTECA As New Biblioteca
            Dim Mensaje As String = ""
            Dim ssql As String
            OPCIONESMENU.EditIndex = System.Convert.ToInt16(e.CommandArgument)
            Dim row As GridViewRow = OPCIONESMENU.Rows(OPCIONESMENU.EditIndex)
            Dim TCODIGO As Label = row.FindControl("CODIGO")
            Dim TVER As CheckBox = row.FindControl("VER")
            Dim Seguridad As New Seguridad

            ssql = " UPDATE PERMISOSMENU SET PERMISOSMENU.VER = " & IIf(TVER.Checked = False, 0, -1) & "" & _
                   " WHERE PERMISOSMENU.CODIGO=" & TCODIGO.Text & " AND PERMISOSMENU.GRUPO='" & Me.GRUPO.SelectedValue & "'"
            BIBLIOTECA.EjecutarSql(Mensaje, ssql)
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "PERMISOSMENU", "Código:" & TCODIGO.Text & ";Valor:" & Me.GRUPO.Text & ";Ver:" & TVER.Checked, Session("GRUPOUS"))
            
            Call Actualizar()
                      
            '*****para acceder a los campos de un gridview sin usar controles adicionales
            ' Create a new ListItem object for the customer in the row.
            '            Dim item As New ListItem()
            '            item.Text = Server.HtmlDecode(row.Cells(1).Text) + " " + Server.HtmlDecode(row.Cells(2).Text)

            ' If the author is not already in the ListBox, add the ListItem
            ' object to the Items collection of a ListBox control.            
        End If
    End Sub
    
    Protected Sub GRUPO_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim Mensaje As String = ""
        Dim ssql As String

        conn = Biblioteca.Conectar(Mensaje)
        ssql = " SELECT PERMISOSMENU.CODIGO, OPCIONESDEMENU.DESCRIPCION, PERMISOSMENU.VER" & _
               " FROM PERMISOSMENU LEFT JOIN OPCIONESDEMENU ON PERMISOSMENU.CODIGO = OPCIONESDEMENU.CODIGO" & _
               " WHERE PERMISOSMENU.GRUPO='" & Me.GRUPO.Text & "'"
        DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "PERMISOSMENU")
        'llenar datagrid
        Me.OPCIONESMENU.DataSource = DtSet.Tables("PERMISOSMENU").DefaultView
        Me.OPCIONESMENU.DataBind()
        Biblioteca.DesConectar(conn)
    End Sub
    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<script language="JavaScript"> 

</script>
    <div>
        <table>
            <tr>
                <td align="right" width="50%">
                    <asp:Label ID="Label4" runat="server" ForeColor="#336677" Height="21px" Text="Grupo"
                        Width="53px"></asp:Label>&nbsp;
                </td>                
                <td align="left" width="50%">
                <asp:DropDownList ID="GRUPO" runat="server" AutoPostBack="True"
                            Width="216px" OnSelectedIndexChanged="GRUPO_SelectedIndexChanged">
                        </asp:DropDownList></td>
            </tr>
            <tr>
                <td align="left"  colspan=2 style="width: 126px; height: 27px">
                    <asp:Label ID="mensaje" runat="server" Width="693px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left"  colspan=2 style="width: 126px; height: 27px;">
                    <asp:GridView ID="OPCIONESMENU" runat="server" BackColor="White" BorderColor="#CCCCCC"
                        BorderStyle="None" BorderWidth="1px" CellPadding="3" AutoGenerateColumns="False" Height="140px" Width="483px" OnRowCommand="OPCIONESMENU_RowCommand">
                        <FooterStyle BackColor="White" ForeColor="#000066" />
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Left" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <Columns>
                            <asp:TemplateField HeaderText="C&#243;digo">
                                <FooterTemplate>
                                    &nbsp;
                                </FooterTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="CODIGO" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.CODIGO") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Descripci&#243;n">
                                <ItemTemplate>
                                    <asp:Label ID="DESCRIPCION" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.DESCRIPCION") %>'
                                        Width="329px"></asp:Label>
                                </ItemTemplate>
                                <FooterTemplate>
                                    &nbsp;
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Ver">
                                <ItemTemplate>
                                    &nbsp;<asp:CheckBox ID="VER" runat="server" Checked='<%# DataBinder.Eval(Container, "DataItem.ver") %>' Height="1px" Width="1px" />
                                </ItemTemplate>
                                <FooterTemplate>
                                    &nbsp; &nbsp;&nbsp;&nbsp;
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:ButtonField ButtonType="Button" HeaderText="Actualizar" CommandName="Actualizar" />
                        </Columns>
                    </asp:GridView>
                    </td>
            </tr>
        </table>
    </div>    
</asp:Content>