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
        
    End Sub
    
    Private Sub Actualizar()
        
    End Sub

    Protected Sub CODIGOS_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
       
    End Sub
    
    Protected Sub Text_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
       
    End Sub
    
    Protected Sub BtnNuevo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub

    Protected Sub CODIGO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub

    Protected Sub Eliminar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        
        ssql = "SELECT  *   FROM(COOPERATIVAS, MINAS) WHERE MINAS.NUMERO LIKE COOPERATIVAS.NUMERO+'%'"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "CrystalReport.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "DataTable1"
        
    End Sub

    Protected Sub ImportarExcel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Biblioteca.AbreVentana("ImportarCooperativas.aspx", Page)
    End Sub
    
    </script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    





    <div>
        &nbsp;&nbsp;
                    
                  

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
                ServiceMethod="GetCompletionList"
                MinimumPrefixLength="1" 
                CompletionInterval="1000"
                EnableCaching="true">
                
                </ajaxToolkit:AutoCompleteExtender>                    
     
        <table>
            <tr>
                <td align="right" style="width: 167px; height: 6px;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Número" ForeColor="#336677"></asp:Label></td>
                <td colspan="2" style="height: 6px">
                    <asp:TextBox runat="server" ID="myTextBox" Width="300" autocomplete="off"  AutoPostBack="true" OnTextChanged="CODIGOS_SelectedIndexChanged"/></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 11px;">
                    <asp:Label ID="Label8" runat="server" Font-Bold="True" ForeColor="#336677" Text="Selección"></asp:Label></td>

                <td style="width: 123px; height: 11px;">
                    &nbsp;<asp:DropDownList ID="CODIGOS" runat="server" OnSelectedIndexChanged="CODIGOS_SelectedIndexChanged"
                        Width="286px" AutoPostBack="True">
                    </asp:DropDownList>
                    &nbsp;
                    
                    
                    
                    </td>
                <td style="width: 79px; height: 11px;">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label1" runat="server" Text="Número" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 123px" align="left">
                    <asp:TextBox ID="NUMERO" runat="server" OnTextChanged="CODIGO_TextChanged"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                    </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label3" runat="server" Text="Descripción" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="DESCRIPCION" runat="server" EnableTheming="True" Width="279px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label4" runat="server" Text="Cupo Limite" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 123px" align="left">
                    <asp:TextBox ID="CUPOLIMITE" runat="server"></asp:TextBox></td>
                                        
                <td align="left" height="1" style="width: 79px">
                    </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 24px;">
                    <asp:Label ID="Label2" runat="server" Text="Entregas" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 123px; height: 24px;" align="left">
                    <asp:TextBox ID="ENTREGAS" runat="server"></asp:TextBox></td>
                <td align="left" style="width: 79px; height: 24px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label7" runat="server" Font-Bold="True" ForeColor="#336677" Text="Kgrs Acumulados"></asp:Label></td>
                <td style="width: 123px" align="left">
                    <asp:TextBox ID="KGS_ACUM" runat="server"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label5" runat="server" Text="Estado" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 123px" align="left">
                    <asp:TextBox ID="ESTADO" runat="server"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="center" colspan="2" style="height: 26px; text-align: right;">                    
                    <asp:Button ID="ImportarExcel" runat="server" Font-Bold="True" ForeColor="#336677"
                        OnClick="ImportarExcel_Click" Text="Importar" ToolTip="Importar Datos desde Archivo Csv"
                        Width="114px" />
                    <asp:Button ID="BtnNuevo" runat="server" OnClick="BtnNuevo_Click" Text="Nuevo" ForeColor="#336677" Font-Bold="True" />
                    <asp:Button ID="BtnActualizar" runat="server" Text="Acualizar" OnClick="BtnActualizar_Click" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" />&nbsp;
                    <asp:Button ID="Eliminar" runat="server" Text="Eliminar" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Eliminar_Click" /></td>
                <td align="center" colspan="1" height="1" style="width: 79px; text-align: left;">
                <asp:Button ID="Imprimir" runat="server" Text="Imprimir" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Imprimir_Click" /></td>
            </tr>
            <tr>
                <td align="center" colspan="3" style="text-align: left; height: 1px;">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>    
</asp:Content>