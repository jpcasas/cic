<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Control de Proveedores" %>
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

   


   

  
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    &nbsp; Identificador de proveedor:
    <div>
        &nbsp;&nbsp;<asp:TextBox ID="txtBusquda" runat="server"></asp:TextBox>
        <asp:Button ID="Button1" runat="server" Text="Buscar" />
        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
            CellPadding="4" DataKeyNames="NUMERO" DataSourceID="ObjectDataSource1" ForeColor="#333333"
            GridLines="None" AllowSorting="True" Width="676px">
            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
            <Columns>
                <asp:CommandField ShowEditButton="True" />
                <asp:BoundField DataField="NUMERO" HeaderText="NUMERO" ReadOnly="True" SortExpression="NUMERO" />
                <asp:BoundField DataField="DESCRIPCION" HeaderText="DESCRIPCION" SortExpression="DESCRIPCION" />
                <asp:BoundField DataField="MUNICIPIO" HeaderText="COD.MUNICIPIO" SortExpression="MUNICIPIO" />
                <asp:BoundField DataField="Muni" HeaderText="MUNICIPIO" ReadOnly="True" SortExpression="Muni" />
                <asp:BoundField DataField="UNIDAD" HeaderText="UNIDAD" SortExpression="UNIDAD" />
                <asp:BoundField DataField="ESTADO" HeaderText="ESTADO" SortExpression="ESTADO" />
                <asp:BoundField DataField="CUPOLIMITE" HeaderText="CUPOLIMITE" SortExpression="CUPOLIMITE" />
                <asp:BoundField DataField="KGS_ACUM" HeaderText="KGS_ACUM" SortExpression="KGS_ACUM" ReadOnly="True" />
            </Columns>
            <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
            <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <EditRowStyle BackColor="#999999" />
            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
        </asp:GridView>
        <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" DeleteMethod="Delete"
            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataByNumero"
            TypeName="DataSet1TableAdapters.MINAS1TableAdapter" UpdateMethod="Update">
            <DeleteParameters>
                <asp:Parameter Name="Original_NUMERO" Type="String" />
            </DeleteParameters>
            <UpdateParameters>
                <asp:Parameter Name="DESCRIPCION" Type="String" />
                <asp:Parameter Name="MUNICIPIO" Type="String" />
                <asp:Parameter Name="UNIDAD" Type="String" />
                <asp:Parameter Name="ESTADO" Type="String" />
                <asp:Parameter Name="CUPOLIMITE" Type="Int32" />
                <asp:Parameter Name="KGS_ACUM" Type="Int32" />
                <asp:Parameter Name="Original_NUMERO" Type="String" />
            </UpdateParameters>
            <InsertParameters>
                <asp:Parameter Name="NUMERO" Type="String" />
                <asp:Parameter Name="DESCRIPCION" Type="String" />
                <asp:Parameter Name="MUNICIPIO" Type="String" />
				<asp:Parameter Name="OBSERVACIONES" Type="String" />
                <asp:Parameter Name="UNIDAD" Type="String" />
                <asp:Parameter Name="ESTADO" Type="String" />
                <asp:Parameter Name="CUPOLIMITE" Type="Int32" />
                <asp:Parameter Name="KGS_ACUM" Type="Int32" />
            </InsertParameters>
            <SelectParameters>
                <asp:ControlParameter ControlID="txtBusquda" DefaultValue="%" Name="NUMERO_PROVEEDOR"
                    PropertyName="Text" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
        &nbsp;
    </div>    
</asp:Content>