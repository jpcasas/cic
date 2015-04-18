<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Opciones de Menú" %>

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
        ssql = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT OPCIONESDEMENU.CODIGO, OPCIONESDEMENU.PADRE, OPCIONESDEMENU.DESCRIPCION, OPCIONESDEMENU.URL, OPCIONESDEMENU.VERTICAL" & _
               " FROM OPCIONESDEMENU"
        
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "OPCIONESDEMENU")
        'llenar datagrid
        Me.OPCIONESMENU.DataSource = DtSet.Tables("OPCIONESDEMENU").DefaultView
        Me.OPCIONESMENU.DataBind()
        BIBLIOTECA.DesConectar(conn)
    End Sub
       
    Protected Sub OPCIONESMENU_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        If e.CommandName = "Actualizar" Then
            Dim BIBLIOTECA As New Biblioteca
            Dim Mensaje As String = ""
            Dim ssql As String
            OPCIONESMENU.EditIndex = System.Convert.ToInt16(e.CommandArgument)
            Dim row As GridViewRow = OPCIONESMENU.Rows(OPCIONESMENU.EditIndex)
            Dim TCODIGO As TextBox = row.FindControl("CODIGO")
            Dim TCODIGO1 As TextBox = row.FindControl("CODIGO1")
            Dim TPADRE As TextBox = row.FindControl("PADRE")
            Dim TDESCRIPCION As TextBox = row.FindControl("DESCRIPCION")
            Dim TURL As TextBox = row.FindControl("URL")
            Dim TVERTICAL As CheckBox = row.FindControl("VERTICAL")
            Dim Seguridad As New Seguridad

            ssql = "UPDATE OPCIONESDEMENU SET OPCIONESDEMENU.CODIGO = '" & TCODIGO.Text & "', OPCIONESDEMENU.PADRE = '" & TPADRE.Text & "', OPCIONESDEMENU.DESCRIPCION = '" & TDESCRIPCION.Text & "', OPCIONESDEMENU.URL = '" & TURL.Text & "', OPCIONESDEMENU.VERTICAL = " & IIf(TVERTICAL.Checked = False, 0, -1) & "" & _
                   " WHERE OPCIONESDEMENU.CODIGO='" & TCODIGO1.Text & "'"
            If BIBLIOTECA.EjecutarSql(Mensaje, ssql) Then
                ssql = "UPDATE    PERMISOSMENU" & _
                       " SET CODIGO = '" & TCODIGO.Text & "'" & _
                       " WHERE CODIGO = '" & TCODIGO1.Text & "'"
                BIBLIOTECA.EjecutarSql(Mensaje, ssql)
            End If
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Opciones Menu", "Codigo:" & TCODIGO.Text & ";Padre:" & TPADRE.Text & ";Descripción:" & TDESCRIPCION.Text & ";Url:" & TURL.Text, Session("GRUPOUS"))
            
            Call Actualizar()
                      
            '*****para acceder a los campos de un gridview sin usar controles adicionales
            ' Create a new ListItem object for the customer in the row.
            '            Dim item As New ListItem()
            '            item.Text = Server.HtmlDecode(row.Cells(1).Text) + " " + Server.HtmlDecode(row.Cells(2).Text)

            ' If the author is not already in the ListBox, add the ListItem
            ' object to the Items collection of a ListBox control.            
        End If
    End Sub

    Protected Sub Insertar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.Insertar.CommandName = "Insertar" Then
            Dim TCODIGO As TextBox = Me.OPCIONESMENU.FooterRow.FindControl("NCODIGO")
            Dim TPADRE As TextBox = Me.OPCIONESMENU.FooterRow.FindControl("NPADRE")
            Dim TDESCRIPCION As TextBox = Me.OPCIONESMENU.FooterRow.FindControl("NDESCRIPCION")
            Dim TURL As TextBox = Me.OPCIONESMENU.FooterRow.FindControl("NURL")
            Dim TVERTICAL As CheckBox = Me.OPCIONESMENU.FooterRow.FindControl("NVERTICAL")
            Dim BIBLIOTECA As New Biblioteca
            Dim Mensaje As String = ""
            Dim ssql As String = ""
            Dim Seguridad As New Seguridad
            
            ssql = "INSERT INTO OPCIONESDEMENU ( CODIGO, PADRE, DESCRIPCION, URL, VERTICAL )" & _
                   " VALUES ('" & TCODIGO.Text & "', '" & TPADRE.Text & "', '" & TDESCRIPCION.Text & "', '" & TURL.Text & "', " & IIf(TVERTICAL.Checked = True, -1, 0) & ")"
            If BIBLIOTECA.EjecutarSql(Mensaje, ssql) Then
                Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "Opciones Menu", "Codigo:" & TCODIGO.Text & ";Padre:" & TPADRE.Text & ";Descripción:" & TDESCRIPCION.Text & ";Url:" & TURL.Text, Session("GRUPOUS"))
                BIBLIOTECA.CrearPermisosOpcion(TCODIGO.Text)
                Me.mensaje.ForeColor = Color.Blue
                Me.mensaje.Text = "Registro Creado Exitosamente"
            Else
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = Mensaje
            End If
            Call Actualizar()
        End If
    End Sub

    Protected Sub OPCIONESMENU_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<script language="JavaScript"> 

</script>
    <div>
        <table>
            <tr>
                <td align="left" style="width: 126px; height: 27px">
                    <asp:Label ID="mensaje" runat="server" Width="693px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" style="width: 126px; height: 27px;">
                    <asp:GridView ID="OPCIONESMENU" runat="server" BackColor="White" BorderColor="#CCCCCC"
                        BorderStyle="None" BorderWidth="1px" CellPadding="3" AutoGenerateColumns="False" ShowFooter="True" Height="140px" Width="483px" OnRowCommand="OPCIONESMENU_RowCommand" OnSelectedIndexChanged="OPCIONESMENU_SelectedIndexChanged">
                        <FooterStyle BackColor="White" ForeColor="#000066" />
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Left" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <Columns>
                            <asp:TemplateField HeaderText="C&#243;digo">
                                <FooterTemplate>
                                    <asp:TextBox ID="NCODIGO" runat="server" Width="67px"></asp:TextBox>
                                </FooterTemplate>
                                <ItemTemplate>
                                    <asp:TextBox ID="CODIGO" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.CODIGO") %>' Width="67px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="C&#243;digo Padre">
                                <FooterTemplate>
                                    <asp:TextBox ID="NPADRE" runat="server" Width="67px"></asp:TextBox>
                                </FooterTemplate>
                                <ItemTemplate>
                                    <asp:TextBox ID="PADRE" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.PADRE") %>' Width="67px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Descripci&#243;n">
                                <ItemTemplate>
                                    <asp:TextBox ID="DESCRIPCION" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.DESCRIPCION") %>' Width="250px"></asp:TextBox>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <asp:TextBox ID="NDESCRIPCION" runat="server" Width="250px"></asp:TextBox>
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Url">
                                <ItemTemplate>
                                    <asp:TextBox ID="URL" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.URL") %>' Width="179px"></asp:TextBox>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <asp:TextBox ID="NURL" runat="server" Width="179px"></asp:TextBox>
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Vertical">
                                <ItemTemplate>
                                    &nbsp; &nbsp;
                                    <asp:CheckBox ID="VERTICAL" runat="server" Checked='<%# DataBinder.Eval(Container, "DataItem.vertical") %>' Height="1px" Width="1px" />
                                </ItemTemplate>
                                <FooterTemplate>
                                    &nbsp; &nbsp;
                                    <asp:CheckBox ID="NVERTICAL" runat="server" Height="1px" Width="1px" />
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:ButtonField ButtonType="Button" HeaderText="Actualizar" CommandName="Actualizar" />
                            <asp:TemplateField HeaderText=" ">
                                <ItemTemplate>
                                    <asp:TextBox ID="CODIGO1" runat="server" Height="1px" Text='<%# DataBinder.Eval(Container, "DataItem.CODIGO") %>'
                                        Width="1px"></asp:TextBox>
                                </ItemTemplate>
                                <FooterTemplate>
                                    &nbsp;
                                </FooterTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:Button ID="Insertar" runat="server" Text="Insertar" Font-Bold="True" Font-Italic="False" ForeColor="#336677" CommandName="Insertar" OnClick="Insertar_Click" /></td>
            </tr>
        </table>
    </div>    
</asp:Content>