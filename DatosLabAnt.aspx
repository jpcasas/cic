<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Análisis de Laboratorio Periodos Anteriores" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        If Not Page.IsPostBack Then
            'define el valor para la comparacion
            cvFecha1.ValueToCompare = Today
            cvFecha2.ValueToCompare = Today
            Me.FECHAIN.Text = Today
            Me.FECHAFIN.Text = Today
            
            Dim Mensaje As String = ""
            Dim Biblioteca As New Biblioteca
            
            Mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            Mensaje = ""
        End If
    End Sub

    Protected Sub VER_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        CargarGridView
    End Sub

    private sub CargarGridView
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim ssql As String
        Dim Mensaje As String
        
        Mensaje = ""
        If Me.FECHAIN.Text = "" Or Me.FECHAFIN.Text = "" Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Debe digitar el intervalo de fechas"
            Exit Sub
        End If
        
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = " SELECT HISTORICO_MUESTRAS.NUMERO as [Cód Muestra], LEFT(DAY(FECHAMUESTRA), 2) + '/' + RIGHT('0' + LEFT(MONTH(FECHAMUESTRA), 2), 2) + '/' + LEFT(YEAR(FECHAMUESTRA),4) AS [Fecha Análisis], " & _
               " HISTORICO_MUESTRAS.HUMEDADRES AS [% Hum Res], HISTORICO_MUESTRAS.HUMEDADSUP AS [%Hum Sup], HISTORICO_MUESTRAS.CENIZAS AS [% Cenizas], HISTORICO_MUESTRAS.MATVOLATIL AS [% Mat Volátil], HISTORICO_MUESTRAS.AZUFRE AS [% Azufre], HISTORICO_MUESTRAS.PODERCALORHHV AS [HHV Poder Calorífico], HISTORICO_MUESTRAS.ANALISTA AS [Análista], HISTORICO_MUESTRAS.ESTADO AS [Estado]" & _
               " FROM HISTORICO_MUESTRAS" & _
               " WHERE FECHAMUESTRA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)"
        
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "HISTORICO_MUESTRAS")
        'llenar datagrid
        Me.MUESTRAS.DataSource = DtSet.Tables("HISTORICO_MUESTRAS").DefaultView
        Me.MUESTRAS.DataBind()
        Session("SqlReporte") = ssql
        Me.Imprimir.Visible = True
        BIBLIOTECA.DesConectar(conn)
    end sub
    
    Protected Sub ImportarExcel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim NombreArchivo As String
        Dim Cargado As Boolean
        Dim Seguridad As New Seguridad
        
        Cargado = False
        NombreArchivo = ""
        If (RutaSubir.PostedFile.ContentLength > 0) Then
            '(Me.RutaSubir1.PostedFile <> Nothing) Or 
            
            NombreArchivo = System.IO.Path.GetFileName(RutaSubir.PostedFile.FileName)
            Dim SaveLocation As String
            SaveLocation = Server.MapPath("Documentos") + "\\" + NombreArchivo
            Try
                RutaSubir.PostedFile.SaveAs(SaveLocation)
                Cargado = True
            Catch ex As Exception
                Cargado = False
                'mensaje.ForeColor = System.Drawing.Color.Red
                'mensaje.Text = "Error no "                
            End Try
        Else
            mensaje.ForeColor = System.Drawing.Color.Red
            mensaje.Text = "Por favor seleccione un archivo para subir"
            Exit Sub
        End If
        If Cargado Then
            Dim Importar As New ArchivosExcel
            Me.mensaje.ForeColor = System.Drawing.Color.Blue
            'mensaje.Text = Importar.ImportarExcelLaboratorio("HISTORICO_Muestras", Server.MapPath("Documentos") & "\" & NombreArchivo, Session("Usuario"), Me.FECHAIN.Text, Me.FECHAFIN.Text)
            Me.mensaje.Text = Importar.ImportarCsvLab("HISTORICO_Muestras", Server.MapPath("Documentos") & "\" & NombreArchivo, Session("Usuario"), Me.FECHAIN.Text, Me.FECHAFIN.Text)
            Seguridad.RegistroAuditoria(Session("Usuario"), "Importar", "DatosLabAnt", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text & ";Tabla:HISTORICO_Muestras", Session("GRUPOUS"))
        Else
            mensaje.ForeColor = System.Drawing.Color.Red
            mensaje.Text = "El archivo no fue transferido al servidor "
        End If
    End Sub
    
    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Session("TituloReporte") = "Listado de Muestras de Períodos Anteriores"
        'Dim Biblioteca As New Biblioteca
        'Biblioteca.AbreVentana("Reportes.aspx", Page)
        '  Response.Redirect("Reportes.aspx")        
        
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        
        ssql = " SELECT * FROM HISTORICO_MUESTRAS " & _
               " WHERE FECHAMUESTRA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "DatosLabAnt.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "Historico_Muestras"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Historico_Muestras", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text, Session("GRUPOUS"))
    End Sub

    Protected Sub Calcular_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Mensaje As String
        Dim Calcular As New CalcularDatosLaboratorio
        Dim Seguridad As New Seguridad
        Dim MuestraCalc As String = ""
        Dim EstadoMuestraCalc As String = ""
        
        If Me.CTodo.Checked Then            
            Mensaje = Calcular.CalcularMuestras("HISTORICO_MUESTRAS", True, Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00"), Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00"))
            Seguridad.RegistroAuditoria(Session("Usuario"), "Calcular", "Todo", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text & ";Muestra:" & Me.MuestraCalcular.Text.Trim & ";Tabla:HISTORICO_MUESTRAS", Session("GRUPOUS"))
        Else
            If Me.MuestraCalcular.Text = "" Then
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "Seleccione la muestra que desea calcular"
                Exit Sub
            End If
            MuestraCalc = Mid(Me.MuestraCalcular.Text, 1, InStr(Me.MuestraCalcular.Text, ";", CompareMethod.Text) - 1)
            EstadoMuestraCalc = Mid(Me.MuestraCalcular.Text, InStr(Me.MuestraCalcular.Text, ";", CompareMethod.Text) + 1, Len(Me.MuestraCalcular.Text))
            
            If EstadoMuestraCalc = "CA" Or EstadoMuestraCalc = "CE" Then
                Me.mensaje.ForeColor = Color.Blue
                Me.mensaje.Text = "Esta muestra ya fué calculada Anteriormente"
                Exit Sub
            End If
            Mensaje = Calcular.CalcularMuestras("HISTORICO_MUESTRAS", False, , , MuestraCalc)
            Seguridad.RegistroAuditoria(Session("Usuario"), "Calcular", "Individual", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text & ";Muestra:" & Me.MuestraCalcular.Text.Trim & ";Tabla:HISTORICO_MUESTRAS", Session("GRUPOUS"))
        End If
        CargarGridView
        me.mensaje.ForeColor=Color.Blue
        Me.mensaje.Text = Mensaje        
    End Sub

    Protected Sub MUESTRAS_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        Dim index As Integer = Convert.ToInt32(e.CommandArgument)
        Dim row As GridViewRow = MUESTRAS.Rows(index)
        Me.MuestraCalcular.Text = Trim(Server.HtmlDecode(row.Cells(1).Text)) & ";" & Server.HtmlDecode(row.Cells(10).Text)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
        <table border="0">
            <tr>
                <td align="left" style="width: 126px; height: 25px;">
                    <asp:TextBox ID="MuestraCalcular" runat="server" Height="15px" Width="15px" Visible="False"></asp:TextBox></td>
                <td align="right" style="width: 524px; height: 25px;">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Inicial" Width="119px"></asp:Label>
                    <asp:TextBox ID="FECHAIN" runat="server"></asp:TextBox></td>
                <td style="width: 53px; height: 25px;" align="left">
                    <asp:CompareValidator ID="cvFecha1" runat="server" ErrorMessage="Fecha no valida" Width="140px" ControlToValidate="FECHAIN" Type="Date" Operator="DataTypeCheck" SetFocusOnError="True"></asp:CompareValidator></td>
                <td align="left" style="width: 200px; height: 25px;">
                
                </td>
            </tr>
            <tr>
                <td align="left" style="width: 126px; height: 27px;">
                
                </td>
                <td align="right" style="width: 524px; height: 27px;">
                    <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Final" Width="118px"></asp:Label>
                    <asp:TextBox ID="FECHAFIN" runat="server"></asp:TextBox>
                </td>
                <td style="width: 53px; height: 27px;" align="left">
                    <asp:CompareValidator ID="cvFecha2" runat="server" ErrorMessage="Fecha no valida" Width="140px" ControlToValidate="FECHAFIN" Type="Date" Operator="DataTypeCheck" SetFocusOnError="True"></asp:CompareValidator></td>
                <td align="left" style="height: 1px; width: 200px;">
                
                <asp:Button ID="VER" runat="server" OnClick="VER_Click" Text="VER" Font-Bold="True" ForeColor="#336677" /><asp:Button ID="Imprimir" runat="server" Font-Bold="True" ForeColor="#336677" OnClick="Imprimir_Click"
                        Text="Imprimir" Visible="False" /></td>                    
            </tr>
            <tr>
                <td align="left" style="width: 126px; height: 1px;">
                
                </td>
                <td align="right" style="width: 524px; height: 1px" valign="top">
                    <asp:FileUpload ID="RutaSubir" runat="server" Width="370px" /></td>
                <td align="left" style="width: 53px; height: 1px;" valign="top">
                    <asp:Button ID="ImportarExcel" runat="server" OnClick="ImportarExcel_Click" Text="Importar Valores"
                        ToolTip="Importar Datos de Laboratorio " Font-Bold="True" ForeColor="#336677" Width="114px" /></td>
                <td align="left" style="height: 1px; width: 200px;" id="calc">
                    <asp:CheckBox ID="CTodo" runat="server" ForeColor="#336677" Text="Calcular Todo" Width="142px" Height="18px" /><asp:Button ID="Calcular" runat="server" Text="Calcular" Font-Bold="True" ForeColor="#336677" OnClick="Calcular_Click" /></td>
            </tr>
            <tr>
                <td align="left" colspan="2">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
                <td align="left" height="1" style="width: 53px">
                </td>
                <td align="left" height="1" style="height: 1px; width: 200px;">
                    </td>
            </tr>
            <tr>
                <td align="left" colspan="4" height="1">
                    <asp:GridView ID="MUESTRAS" runat="server" Caption="Análisis de Laboratorio Periodos Anteriores" CellPadding="3" ForeColor="#336677" Font-Overline="False" OnRowCommand="MUESTRAS_RowCommand" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None" BorderWidth="1px">
                        <FooterStyle BackColor="White" Font-Bold="True" ForeColor="#000066" />
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Center" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="False" ForeColor="White" />
                        <AlternatingRowStyle Font-Bold="False" Font-Italic="False" Wrap="False" />
                        <Columns>
                            <asp:CommandField ButtonType="Button" SelectText="" ShowSelectButton="True" />
                        </Columns>
                    </asp:GridView>                    
                </td>
            </tr>
            <tr>
                <td align="left" style="width: 126px">
                
                </td>
                <td style="width: 524px" align="right">
                
                </td>
                <td align="left" height="1" style="width: 53px">
                
                </td>
                <td align="left" height="1" style="height: 1px; width: 200px;">
                
                </td>
            </tr>
        </table>
    </div>    
</asp:Content>