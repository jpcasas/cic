<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Control de Fichas" %>
<%@ Register
    Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="ajaxToolkit" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
       
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
            
        End If
    End Sub

   


   

  
    Protected Sub GridView1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

  

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        
        
        ssql = "SELECT * FROM [CONSECUTIVOS_ENTREGAS] ORDER BY [CONSECUTIVO] "
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "Fichas.rpt"
        Session("NombreDataTable") = "CONSECUTIVOS_ENTREGAS"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Cooperativas", "Cooperativas:Todas", Session("GRUPOUS"))
    
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    &nbsp;
    <div>
        &nbsp;&nbsp;
        <table>
        <tr><td align="center">
            &nbsp;<asp:Button ID="Imprimir" runat="server" Font-Bold="True" Font-Italic="False"
                Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677"
                Text="Imprimir" OnClick="Imprimir_Click" /></td>
        <td>
        
        </td>
        </tr>
        <tr><td>
            <asp:DetailsView ID="DetailsView1" runat="server" Height="50px" Width="125px" AutoGenerateRows="False" DataKeyNames="PROVEEDOR" DataSourceID="dsFichas" DefaultMode="Insert">
                <Fields>
                    <asp:BoundField DataField="PROVEEDOR" HeaderText="Cooperativa" ReadOnly="True" SortExpression="PROVEEDOR" />
                    <asp:BoundField DataField="CONSECUTIVO" HeaderText="Ficha" SortExpression="CONSECUTIVO" />
                    <asp:BoundField DataField="SERIE" HeaderText="SERIE" SortExpression="SERIE" Visible="False" />
                    <asp:CommandField ShowInsertButton="True" CancelText="Cancelar" InsertText="Guardar" />
                </Fields>
            </asp:DetailsView>
        </td><td><asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
            CellPadding="4" DataKeyNames="PROVEEDOR" DataSourceID="dsFichas" ForeColor="#333333"
            GridLines="None" AllowSorting="True" Width="676px" OnSelectedIndexChanged="GridView1_SelectedIndexChanged">
            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
            <Columns>
                <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" DeleteText="Borrar" EditText="Editar" />
                <asp:BoundField DataField="PROVEEDOR" HeaderText="Cooperativa" ReadOnly="True" SortExpression="PROVEEDOR" />
                <asp:BoundField DataField="CONSECUTIVO" HeaderText="Ficha" SortExpression="CONSECUTIVO" />
            </Columns>
            <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
            <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <EditRowStyle BackColor="#999999" />
            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
        </asp:GridView></td></tr>
        </table>
        <asp:ObjectDataSource ID="dsFichas" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}"
            SelectMethod="GetData" TypeName="DataSet1TableAdapters.CONSECUTIVOS_ENTREGASTableAdapter"
            UpdateMethod="Update" InsertMethod="Insert">
            <DeleteParameters>
                <asp:Parameter Name="Original_PROVEEDOR" Type="String" />
            </DeleteParameters>
            <UpdateParameters>
                <asp:Parameter Name="PROVEEDOR" Type="String" />
                <asp:Parameter Name="SERIE" Type="String" />
                <asp:Parameter Name="CONSECUTIVO" Type="Int32" />
                <asp:Parameter Name="Original_PROVEEDOR" Type="String" />
            </UpdateParameters>
            <InsertParameters>
                <asp:Parameter Name="PROVEEDOR" Type="String" />
                <asp:Parameter Name="SERIE" Type="String" />
                <asp:Parameter Name="CONSECUTIVO" Type="Int32" />
            </InsertParameters>
        </asp:ObjectDataSource>
        &nbsp; &nbsp;
    </div>    
</asp:Content>