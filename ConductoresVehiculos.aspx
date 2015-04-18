<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Control de Cooperativas" %>
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
        Me.mensaje.Text = ""
        
    End Sub
    
 


    
    

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim Orden As String
        Orden = RadioButtonList1.SelectedValue
        ssql = "SELECT * FROM CONDUCTORESVEHICULOS ORDER BY " & Orden
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "ConductoresVehiculos.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "CONDUCTORESVEHICULOS"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Cooperativas", "Cooperativas:Todas", Session("GRUPOUS"))
    End Sub

    Protected Sub ImportarExcel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Biblioteca.AbreVentana("ImportarVehiculosConductores.aspx", Page)
    End Sub
    
 
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<asp:ScriptManager ID="ScriptManager1" runat="server">
        <Services>
        <asp:ServiceReference Path="AutoComplete.asmx" />
        </Services>
        </asp:ScriptManager>
            <ajaxToolkit:AutoCompleteExtender
                runat="server" 
                ID="autoComplete12" 
                TargetControlID="myTextBox"
                BehaviorID="AutoCompleteEx"
                ServicePath="AutoComplete.asmx" 
                ServiceMethod="GetPlacasList"
                MinimumPrefixLength="1" 
                CompletionInterval="1000"
                EnableCaching="true">
                <Animations>
                    <OnShow>
                        <Sequence>
                            <%-- Make the completion list transparent and then show it --%>
                            <OpacityAction Opacity="0" />
                            <HideAction Visible="true" />
                            
                            <%--Cache the original size of the completion list the first time
                                the animation is played and then set it to zero --%>
                            <ScriptAction Script="
                                // Cache the size and setup the initial size
                                var behavior = $find('AutoCompleteEx');
                                if (!behavior._height) {
                                    var target = behavior.get_completionList();
                                    behavior._height = target.offsetHeight - 2;
                                    target.style.height = '0px';
                                }" />
                            
                            <%-- Expand from 0px to the appropriate size while fading in --%>
                            <Parallel Duration=".4">
                                <FadeIn />
                                <Length PropertyKey="height" StartValue="0" EndValueScript="$find('AutoCompleteEx')._height" />
                            </Parallel>
                        </Sequence>
                    </OnShow>
                    <OnHide>
                        <%-- Collapse down to 0px and fade out --%>
                        <Parallel Duration=".2">
                            <FadeOut />
                            <Length PropertyKey="height" StartValueScript="$find('AutoCompleteEx')._height" EndValue="0" />
                        </Parallel>
                    </OnHide>
                </Animations>
                </ajaxToolkit:AutoCompleteExtender>                    
     
    <div>
        &nbsp;&nbsp;&nbsp;
        
        <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" DeleteMethod="Delete"
            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData"
            TypeName="DataSet1TableAdapters.CONDUCTORESVEHICULOSTableAdapter" UpdateMethod="Update">
            <DeleteParameters>
                <asp:Parameter Name="Original_conductor" Type="String" />
                <asp:Parameter Name="Original_placas" Type="String" />
                <asp:Parameter Name="Original_cedula" Type="String" />
            </DeleteParameters>
            <UpdateParameters>
                <asp:Parameter Name="Original_conductor" Type="String" />
                <asp:Parameter Name="Original_placas" Type="String" />
                <asp:Parameter Name="Original_cedula" Type="String" />
            </UpdateParameters>
            <InsertParameters>
                <asp:Parameter Name="conductor" Type="String" />
                <asp:Parameter Name="placas" Type="String" />
                <asp:Parameter Name="cedula" Type="String" />
            </InsertParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="ObjectDataSource2" runat="server" DeleteMethod="Delete"
            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData"
            TypeName="DataSet1TableAdapters.CONDUCTORESVEHICULOS2TableAdapter" UpdateMethod="Update">
            <DeleteParameters>
                <asp:Parameter Name="Original_conductor" Type="String" />
                <asp:Parameter Name="Original_placas" Type="String" />
                <asp:Parameter Name="Original_cedula" Type="String" />
            </DeleteParameters>
            <UpdateParameters>
                <asp:Parameter Name="Original_conductor" Type="String" />
                <asp:Parameter Name="Original_placas" Type="String" />
                <asp:Parameter Name="Original_cedula" Type="String" />
            </UpdateParameters>
            <SelectParameters>
                <asp:ControlParameter ControlID="myTextBox" DefaultValue="%" Name="PLACA" PropertyName="Text"
                    Type="String" />
            </SelectParameters>
            <InsertParameters>
                <asp:Parameter Name="conductor" Type="String" />
                <asp:Parameter Name="placas" Type="String" />
                <asp:Parameter Name="cedula" Type="String" />
            </InsertParameters>
        </asp:ObjectDataSource>
        &nbsp;&nbsp;
        <table>
            <tr>
                <td align="right" style="width: 167px; height: 6px;">
                    <asp:Button ID="ImportarExcel" runat="server" Font-Bold="True" ForeColor="#336677"
                        OnClick="ImportarExcel_Click" Text="Importar" ToolTip="Importar Datos desde Archivo Csv"
                        Width="114px" />
                </td>
                <td colspan="2" height="1">
                    &nbsp;<asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Vehiculo" ForeColor="#336677"></asp:Label>
                    <asp:TextBox runat="server" ID="myTextBox" Width="271px" autocomplete="off"  AutoPostBack="true"/></td>
            </tr>
           
            
            <tr>
                <td style="width: 123px; height: 21px; text-align: center;" align="left">
                <br />
                <asp:Panel ID="Panel1" runat="server">
                    <asp:DetailsView ID="DetailsView1" runat="server" BorderStyle="None" BorderWidth="0px"
                        DataSourceID="ObjectDataSource1" DefaultMode="Insert" Font-Bold="True" ForeColor="#336677"
                        GridLines="None" Height="50px" Width="125px" >
                        <Fields>
                            <asp:CommandField ButtonType="Button" ShowInsertButton="True" />
                        </Fields>
                    </asp:DetailsView>
                    
                    </asp:Panel>
                    </td>
                <td style="width: 139px; height: 21px; text-align: center;" align="left">
                    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" CellPadding="4" DataKeyNames="conductor,placas,cedula"
                        DataSourceID="ObjectDataSource2" AllowSorting="True" ForeColor="#333333" GridLines="None">
                        <RowStyle ForeColor="#333333" BackColor="#F7F6F3" />
                        <Columns>
                            <asp:CommandField ShowDeleteButton="True" />
                            <asp:BoundField DataField="placas" HeaderText="Placa" ReadOnly="True" SortExpression="placas" />
                            <asp:BoundField DataField="conductor" HeaderText="Conductor" ReadOnly="True" SortExpression="conductor" />
                            <asp:BoundField DataField="cedula" HeaderText="Cedula" ReadOnly="True" SortExpression="cedula" />
                        </Columns>
                        <FooterStyle BackColor="#5D7B9D" ForeColor="White" Font-Bold="True" />
                        <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <EditRowStyle BackColor="#999999" />
                        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                    </asp:GridView>
                    </td>
                <td align="left" style="width: 100px; height: 21px">
                    &nbsp;
                </td>
            </tr>
            
            <tr>
                <td align="right" style="width: 167px; text-align: center;">
                    &nbsp;
                    </td>
                <td style="width: 139px; text-align: center">
                    &nbsp;<asp:RadioButtonList ID="RadioButtonList1" runat="server" Font-Bold="True" ForeColor="#336677" Width="219px">
                        <asp:ListItem Value="conductor" Selected="True">Ordena por Conductor</asp:ListItem>
                        <asp:ListItem Value="placas">Orden por Placas</asp:ListItem>
                    </asp:RadioButtonList>
                <asp:Button ID="Imprimir" runat="server" Text="Imprimir" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Imprimir_Click" /></td>
                <td align="left" height="1" style="width: 100px; text-align: center;">
                    &nbsp;</td>
            </tr>
            <tr>
          
                <td align="center" colspan="2" style="height: 22px; text-align: center;">                    &nbsp;</td>
                
                <td align="center" colspan="1" style="width: 100px; text-align: left; height: 22px;">
                </td>
            </tr>
            <tr>
                <td align="center" colspan="3" style="text-align: left; height: 1px;">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
        &nbsp;<br />
    </div>    
</asp:Content>