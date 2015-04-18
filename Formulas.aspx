<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Formulas de Cálculo" %>

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
        
        Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
        If Mensaje = "" Then
            Response.Redirect("Principal.aspx")
        Else
            CType(Master.FindControl("Label1"), Label).Text = Mensaje
        End If
        Mensaje = ""
        ssql = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT FORMULAS.NOMBRE, FORMULAS.CONTENIDO" & _
               " FROM FORMULAS " & _
               " ORDER BY FORMULAS.ORDEN"
        
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "FORMULAS")
        'llenar datagrid
        Me.FORMULAS.DataSource = DtSet.Tables("FORMULAS").DefaultView
        Me.FORMULAS.DataBind()
        Session("SqlReporte") = ssql
        BIBLIOTECA.DesConectar(conn)
    End Sub
    
    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Session("TituloReporte") = "Listado de Fórmulas de Laboratorio"
        'Dim Biblioteca As New Biblioteca
        'Biblioteca.AbreVentana("Reportes.aspx", Page)
        'Response.Redirect("Reportes.aspx")
        
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
         
        ssql = "SELECT * FROM FORMULAS " & _
               " ORDER BY ORDEN"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "Formulas.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "Formulas"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Formulas", "Formulas:Todas", Session("GRUPOUS"))
    End Sub
        
    Protected Sub FORMULAS_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        If e.CommandName = "Actualizar" Then
            'Dim index As Integer = Convert.ToInt32(e.CommandArgument)
            FORMULAS.EditIndex = System.Convert.ToInt16(e.CommandArgument)
            'Dim customersGridView As GridView = CType(e.CommandSource, GridView)
            Dim row As GridViewRow = FORMULAS.Rows(FORMULAS.EditIndex)
            Dim TNombre As Label = row.FindControl("Nombre")
            Dim TFormula As TextBox = row.FindControl("Formula")
            
            Dim BIBLIOTECA As New Biblioteca
            Dim Mensaje As String
            Dim ssql As String
            Dim Seguridad As New Seguridad
            Mensaje = ""
            
            ssql = "UPDATE FORMULAS SET FORMULAS.CONTENIDO = '" & TFormula.Text & "'" & _
                   " WHERE FORMULAS.NOMBRE='" & TNombre.Text & "'"
            BIBLIOTECA.EjecutarSql(Mensaje, ssql)
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Formulas", "Nombre Formula:" & TNombre.Text & ";Contenido" & TFormula.Text, Session("GRUPOUS"))
            Call Actualizar()
                      
            '*****para acceder a los campos de un gridview sin usar controles adicionales
            ' Create a new ListItem object for the customer in the row.
            '            Dim item As New ListItem()
            '            item.Text = Server.HtmlDecode(row.Cells(1).Text) + " " + Server.HtmlDecode(row.Cells(2).Text)

            ' If the author is not already in the ListBox, add the ListItem
            ' object to the Items collection of a ListBox control.            
        End If
    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
        <table>
            <tr>
                <td align="left" style="width: 126px; height: 27px;">
                    <asp:GridView ID="FORMULAS" runat="server" BackColor="White" BorderColor="#CCCCCC"
                        BorderStyle="None" BorderWidth="1px" CellPadding="3" AutoGenerateColumns="False" OnRowCommand="FORMULAS_RowCommand">
                        <FooterStyle BackColor="White" ForeColor="#000066" />
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#669999" Font-Bold="True" ForeColor="White" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Left" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <Columns>
                            <asp:TemplateField HeaderText="Nombre F&#243;rmula">
                                <FooterTemplate>
                                    &nbsp;
                                </FooterTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="Nombre" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.Nombre") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Contenido de la F&#243;rmula">
                                <FooterTemplate>
                                    &nbsp;
                                </FooterTemplate>
                                <ItemTemplate>
                                    <asp:TextBox ID="Formula" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.Contenido") %>' Width="554px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:ButtonField CommandName="Actualizar" Text="Actualizar" />
                        </Columns>
                    </asp:GridView>
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" colspan="1">
                
                <asp:Button ID="Imprimir" runat="server" Font-Bold="True" ForeColor="#336677" OnClick="Imprimir_Click"
                        Text="Imprimir" /></td>
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