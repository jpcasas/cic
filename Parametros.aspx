<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Parámetros del Sistema" %>

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
        ssql = "SELECT PARAMETROS.NOMBRE, PARAMETROS.VALOR" & _
               " FROM PARAMETROS " 
        
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "PARAMETROS")
        'llenar datagrid
        Me.PARAMETROS.DataSource = DtSet.Tables("PARAMETROS").DefaultView
        Me.PARAMETROS.DataBind()
        Session("SqlReporte") = ssql
        BIBLIOTECA.DesConectar(conn)
    End Sub
        
    Protected Sub PARAMETROS_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        If e.CommandName = "Actualizar" Then
            'Dim index As Integer = Convert.ToInt32(e.CommandArgument)
            PARAMETROS.EditIndex = System.Convert.ToInt16(e.CommandArgument)
            'Dim customersGridView As GridView = CType(e.CommandSource, GridView)
            Dim row As GridViewRow = PARAMETROS.Rows(PARAMETROS.EditIndex)
            Dim TNombre As Label = row.FindControl("Nombre")
            Dim TFormula As TextBox = row.FindControl("VALOR")
            Dim Seguridad As New Seguridad
            
            Dim BIBLIOTECA As New Biblioteca
            Dim Mensaje As String
            Dim ssql As String
            Mensaje = ""
            
            ssql = "UPDATE PARAMETROS SET PARAMETROS.VALOR = '" & TFormula.Text & "'" & _
                   " WHERE PARAMETROS.NOMBRE='" & TNombre.Text & "'"
            BIBLIOTECA.EjecutarSql(Mensaje, ssql)
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Parametros", "Nombre:" & TNombre.Text & ";Valor:" & TFormula.Text, Session("GRUPOUS"))
            Call Actualizar()
                      
            '*****para acceder a los campos de un gridview sin usar controles adicionales
            ' Create a new ListItem object for the customer in the row.
            '            Dim item As New ListItem()
            '            item.Text = Server.HtmlDecode(row.Cells(1).Text) + " " + Server.HtmlDecode(row.Cells(2).Text)

            ' If the author is not already in the ListBox, add the ListItem
            ' object to the Items collection of a ListBox control.            
        End If
    End Sub

    Protected Sub PARAMETROS_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<script language="JavaScript"> 

</script>
    <div>
        <table>
            <tr>
                <td align="left" style="width: 126px; height: 27px;">
                    <asp:GridView ID="PARAMETROS" runat="server" BackColor="White" BorderColor="#CCCCCC"
                        BorderStyle="None" BorderWidth="1px" CellPadding="3" AutoGenerateColumns="False" OnRowCommand="PARAMETROS_RowCommand" OnSelectedIndexChanged="PARAMETROS_SelectedIndexChanged">
                        <FooterStyle BackColor="White" ForeColor="#000066" />
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#669999" Font-Bold="True" ForeColor="White" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Left" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <Columns>
                            <asp:TemplateField HeaderText="Nombre Par&#225;metro">
                                <FooterTemplate>
                                    &nbsp;
                                </FooterTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="Nombre" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.Nombre") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Contenido Par&#225;metro">
                                <FooterTemplate>
                                    &nbsp;
                                </FooterTemplate>
                                <ItemTemplate>
                                    <asp:TextBox ID="VALOR" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.Valor") %>' Width="554px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:ButtonField CommandName="Actualizar" Text="Actualizar" />
                        </Columns>
                    </asp:GridView>
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" colspan="1">
                
                </td>
            </tr>
            <tr>
                <td align="left" colspan="1" id="TD1" style="height: 1px">
                    &nbsp; &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td align="left" style="width: 126px">
                    &nbsp;</td>
            </tr>
        </table>
    </div>    
</asp:Content>