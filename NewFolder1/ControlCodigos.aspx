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

   


   


    Protected Sub Importar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ClientScript As String
        ClientScript = "<script> var win=window.open('ImportarCodigos.aspx'); win.onunload = function(){alert('closed');}" & "<" & "/script>"
        Response.Write(ClientScript)
        
    End Sub

    Protected Sub Button1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        GridView1.DataBind()
        
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    &nbsp;
    <div>
        &nbsp;&nbsp;
        <table>
        <tr><td align="center">
            &nbsp;</td>
        <td style="text-align: center">
        <table><tr style="align: center"><td style="height: 98px">
        <asp:Button ID="Importar" runat="server" Font-Bold="True" Font-Italic="False"
                Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677"
                Text="Importar" OnClick="Importar_Click" TabIndex="5" />
            <asp:Button ID="Button1" runat="server" Font-Bold="True" Font-Italic="False"
                Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677"
                Text="Actualizar" OnClick="Button1_Click" TabIndex="5" />
                
                </td><td style="width: 41px">&nbsp</td>
        <td style="height: 98px" >
        
        <asp:DetailsView ID="DetailsView1" runat="server"  AutoGenerateRows="False" DataKeyNames="Codigo_Barras" DataSourceID="dsCodigos" DefaultMode="Insert">
                <Fields>
                    <asp:BoundField DataField="Codigo_Barras" HeaderText="Codigo de Barras" ReadOnly="True"
                        SortExpression="Codigo_Barras" />
                    <asp:BoundField DataField="Proveedor" HeaderText="Proveedor" SortExpression="Proveedor" />
                    <asp:CommandField CancelText="Cancelar" DeleteText="Borrar" EditText="Editar" InsertText="Adicionar"
                        NewText="Nuevo" ShowInsertButton="True" />
                </Fields>
            </asp:DetailsView></td></tr></table>
            
        
        
        
           
        
        
        </td>
        </tr>
        <tr><td>
            &nbsp;</td><td><asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
            CellPadding="4" DataKeyNames="Codigo_Barras" DataSourceID="dsCodigos" ForeColor="#333333"
            GridLines="None" AllowSorting="True" Width="676px" >
            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
            <Columns>
                <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" DeleteText="Borrar" EditText="Editar" />
                <asp:BoundField DataField="Codigo_Barras" HeaderText="C&#243;digo de Barras" ReadOnly="True"
                    SortExpression="Codigo_Barras" />
                <asp:BoundField DataField="Proveedor" HeaderText="Proveedor" SortExpression="Proveedor" />
            </Columns>
            <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
            <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <EditRowStyle BackColor="#999999" />
            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
        </asp:GridView></td></tr>
        </table>
         <asp:ObjectDataSource ID="dsCodigos" runat="server" DeleteMethod="Delete" InsertMethod="Insert"
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DataSet1TableAdapters.CODIGO_BARRASTableAdapter"
                UpdateMethod="Update">
                <DeleteParameters>
                    <asp:Parameter Name="Original_Codigo_Barras" Type="String" />
                </DeleteParameters>
                <UpdateParameters>
                    <asp:Parameter Name="Proveedor" Type="String" />
                    <asp:Parameter Name="Original_Codigo_Barras" Type="String" />
                </UpdateParameters>
                <InsertParameters>
                    <asp:Parameter Name="Codigo_Barras" Type="String" />
                    <asp:Parameter Name="Proveedor" Type="String" />
                </InsertParameters>
            </asp:ObjectDataSource>
        &nbsp; &nbsp;
    </div>    
</asp:Content>