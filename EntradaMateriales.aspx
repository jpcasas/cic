
    <%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Entrada de Vehículos" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ import Namespace="System.IO.Ports" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Drawing" %>

<script runat="server">
    'Private WithEvents RS232 As New System.IO.Ports.SerialPort("COM1", 2400, IO.Ports.Parity.Even, 7, IO.Ports.StopBits.One)
    'Delegate Sub WriteDataDelegate(ByVal str As String)
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim Mensaje As String
        Dim ssql As String
        
        Mensaje = ""
        
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        Me.FECHAENTREGA.Text = Format(Date.Now, "dd/MM/yyyy")
        If Not Page.IsPostBack Then
            Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            
            Mensaje = ""
            conn = BIBLIOTECA.Conectar(Mensaje)
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Mensaje
            
            DtSet = New DataSet
            'CARGAR Empresas
            ssql = " SELECT EMPRESA.CODIGO, EMPRESA.DESCRIPCION " & _
                   " FROM EMPRESA " & _
                   " UNION " & _
                   " SELECT '..' AS CODIGO1, '...' AS DESCRIPCION1  " & _
                   " FROM EMPRESA AS EMPRESA_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DtSet, "EMPRESA")
            Me.Empresa.DataSource = DtSet.Tables("EMPRESA").DefaultView
            Me.Empresa.DataTextField = "DESCRIPCION"
            Me.Empresa.DataValueField = "CODIGO"
            Me.Empresa.DataBind()
            
            'CARGAR PROCUCTOS
            ssql = " SELECT PRODUCTO.CODIGO, PRODUCTO.NOMBRE" & _
                   " FROM PRODUCTO " & _
                   " UNION " & _
                   " SELECT '..' AS CODIGO1, '...' AS NOMBRE1 " & _
                   " FROM PRODUCTO AS PRODUCTO_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DtSet, "PRODUCTO")
            Me.Producto.DataSource = DtSet.Tables("PRODUCTO").DefaultView
            Me.Producto.DataTextField = "NOMBRE"
            Me.Producto.DataValueField = "CODIGO"
            Me.Producto.DataBind()
            BIBLIOTECA.DesConectar(conn)
        End If
    End Sub
          
    Protected Sub Peso_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ''SYSTEMBE.SYS = ARCHIVO PLANO PARA PESOS DE ENTRADA
        Dim PlanosBasc As New ArchivosPlanos
        Me.PesoT.Text = PlanosBasc.LeerArchivoBascula("C:\temp\SYSTEMBE.SYS")
        PlanosBasc.GeneraArchivoBascula("C:\temp", "SYSTEMBE.SYS", 0)
    End Sub
    
    Protected Sub Guardar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim mensaje As String = ""
        Dim Seguridad As New Seguridad
        
        if Me.PesoT.Text = "" then Me.PesoT.Text = 0
        if me.Producto.SelectedItem.Text = "CENIZA" then        
            if me.Patio.Checked=False and me.Industria.Checked=False then
                BIBLIOTECA.MostrarMensaje(Page, "Debe seleccionar sí la ceniza es para Patio ó Industria", 2)
                exit sub
            end if                
            if me.escoria.Checked=False and me.volatil.Checked=False then
                BIBLIOTECA.MostrarMensaje(Page, "Debe seleccionar sí la ceniza es Volatil ó Escoría", 2)
                exit sub
            end if
        end if            
        If Me.PesoT.Text = 0 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El peso de Entrada no puede ser cero"
            Exit Sub
        End If
        If Me.Producto.Text = ".." Or Me.Empresa.Text = ".." Or Me.VEHICULO.Text = "" Or Me.CONDUCTOR.Text = "" Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Faltan datos para continuar el proceso"
            Exit Sub
        End If
        
        ssql = "INSERT INTO CONTROLMATERIALES" & _
                      " (CODIGOENTRADA, CODIGOPRODUCTO, FECHA, HORAENTRADA, PESOENTRADA, EMPRESA, TRANSPORTADOR, CONDUCTOR, PLACA," & _
                      " OPERADORBASCULA, CENIZAVOLATIL, CENIZAESCORIA, CENIZAPATIO, INDUSTRIA, OBSERVACIONES)" & _
               " VALUES     (" & Me.NUMEROENTREGA.Text & ", '" & Me.Producto.Text & "',CONVERT(DATETIME,'" & Format(CDate(Today), "yyyy-MM-dd 00:00:00") & "',102), " & _
               " '" & Replace(Format(CDate(Me.HORAENTREGA.Text), "hh:mm:ss tt"), ".", "") & "', " & Me.PesoT.Text & ", '" & Me.Empresa.Text & "', '" & Me.Transportador.Text & "', " & _
               " '" & Me.CONDUCTOR.Text & "', '" & Me.VEHICULO.Text & "', '" & Session("USUARIO") & "', " & IIf(Me.Volatil.Checked = True, -1, 0) & ", " & IIf(Me.Escoria.Checked = True, -1, 0) & ", " & _
               " " & IIf(Me.Patio.Checked = True, -1, 0) & ", " & IIf(Me.Industria.Checked = True, -1, 0) & ", '" & Me.OBSERVACIONES.Text & "')"
        If Biblioteca.EjecutarSql(mensaje, ssql) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "EntregaMateriales", "Numero:" & Me.NUMEROENTREGA.Text & ";Peso:" & Me.PesoT.Text & ";Producto:" & Me.Producto.SelectedItem.Text & ";Empresa:" & Me.Empresa.SelectedItem.Text & ";Conductor:" & Me.CONDUCTOR.Text, Session("GRUPOUS"))
            ''Imprimir
            ssql = "SELECT     PRODUCTO.NOMBRE AS CODIGOPRODUCTO, EMPRESA.DESCRIPCION AS EMPRESA, CODIGOENTRADA, " & _
                      " CONTROLMATERIALES.FECHA, CONTROLMATERIALES.HORAENTRADA, CONTROLMATERIALES.HORASALIDA, CONTROLMATERIALES.PESOENTRADA, " & _
                      " CONTROLMATERIALES.PESOSALIDA, CONTROLMATERIALES.PESONETO, CONTROLMATERIALES.TRANSPORTADOR, CONTROLMATERIALES.PLACA, " & _
                      " CONTROLMATERIALES.CONDUCTOR, CONTROLMATERIALES.OPERADORBASCULA, CONTROLMATERIALES.RECIBIDOPOR, " & _
                      " CONTROLMATERIALES.DESPACHADOPOR, CONTROLMATERIALES.CENIZAVOLATIL, CONTROLMATERIALES.CENIZAESCORIA, " & _
                      " CONTROLMATERIALES.CENIZAPATIO, CONTROLMATERIALES.INDUSTRIA, CONTROLMATERIALES.OBSERVACIONES " & _
                   " FROM CONTROLMATERIALES LEFT OUTER JOIN EMPRESA ON CONTROLMATERIALES.EMPRESA = EMPRESA.CODIGO LEFT OUTER JOIN" & _
                        " PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO " & _
                   " WHERE CODIGOENTRADA= " & Me.NUMEROENTREGA.Text & " and FECHA = CONVERT(DATETIME, '" & Format(CDate(Today), "yyyy-MM-dd 00:00:00") & "', 102) AND CODIGOPRODUCTO='" & Me.Producto.Text & "'"
            
            Session("SqlReporte") = ssql
            If Me.Producto.SelectedItem.Text = "CENIZA" Then
                Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE ENTRADA CENIZA")
            Else
                Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE ENTRADA MATERIALES")
            End If
            
            Session("Parametro") = Me.FECHAENTREGA.Text
            Session("NombreDataTable") = "CONTROLMATERIALES"
            Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
            Limpiar()
            'Fin Imprimir         
        Else
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = mensaje
        End If
    End Sub
    
    Private Sub Limpiar()
        Me.FECHAENTREGA.Text = Today
        Me.NUMEROENTREGA.Text = ""
        Me.HORAENTREGA.Text = ""
        Me.Producto.Text = ".."
        Me.Volatil.Checked = False
        Me.Escoria.Checked = False
        Me.Patio.Checked = False
        Me.Industria.Checked = False
        Me.Empresa.Text = ".."
        Me.Transportador.Text = ""
        Me.VEHICULO.Text = ""
        Me.CONDUCTOR.Text = ""
        Me.PesoT.Text = 0
        Me.OBSERVACIONES.Text = ""
    End Sub
            
    Protected Sub Producto_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.Producto.SelectedItem.Text = "CENIZA" Then
            VisibleControl(True)
            Me.Transportador.Visible = False
            Me.LTransportador.Visible = False
        Else
            Me.Transportador.Visible = True
            Me.LTransportador.Visible = True
            VisibleControl(False)
        End If
        Me.HORAENTREGA.Text = Format(Date.Now, "hh:mm:ss tt")
        Me.NUMEROENTREGA.Text = GenerarCodigoEntrada()
        
    End Sub
    
    Private Sub VisibleControl(ByVal Opcion As Boolean)
        Me.Volatil.Visible = Opcion
        Me.Escoria.Visible = Opcion
        Me.Patio.Visible = Opcion
        Me.Industria.Visible = Opcion
    End Sub
    
    Private Function GenerarCodigoEntrada() As String
        Dim ssql As String = ""
        Dim conn As SqlConnection
        Dim dtreader As SqlDataReader
        Dim Biblioteca As New Biblioteca
        Dim mensaje As String = ""
        
        ssql = "SELECT   MAX(CODIGOENTRADA) AS MaxCodigo, FECHA, CODIGOPRODUCTO " & _
               " FROM    CONTROLMATERIALES " & _
               " WHERE FECHA = CONVERT(DATETIME, '" & Format(CDate(Today), "yyyy-MM-dd 00:00:00") & "', 102) AND CODIGOPRODUCTO='" & Me.Producto.Text & "'" & _
               " GROUP BY FECHA, CODIGOPRODUCTO" ' 2007-09-03 00:00:00
        conn = Biblioteca.Conectar(mensaje)
        dtreader = Biblioteca.CargarDataReader(mensaje, ssql, conn)
        If dtreader.Read Then
            GenerarCodigoEntrada = Format(Today, "yyyyMMdd") & Right("0" & Val(dtreader("MaxCodigo")) + 1, 2)
        Else
            GenerarCodigoEntrada = Format(Today, "yyyyMMdd") & "01"
        End If
        dtreader.Close()
        Biblioteca.DesConectar(conn)
    End Function

    Protected Sub VEHICULO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If Len(Me.VEHICULO.Text) > 6 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "La placa del vehículo (" & Me.VEHICULO.Text & ") no puede ser superior a 6 caracteres"
            Me.VEHICULO.Text = ""
            Me.VEHICULO.Focus()
            Exit Sub
        End If
        Me.VEHICULO.Text = UCase(Me.VEHICULO.Text)
        Me.CONDUCTOR.Focus()
    End Sub

    Protected Sub CONDUCTOR_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        If Not Biblioteca.SoloLetras(Me.CONDUCTOR.Text) Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El nombre del conductor (" & Me.CONDUCTOR.Text & ") solo puede tener caracteres alfabeticos"
            Me.CONDUCTOR.Text = ""
            Me.CONDUCTOR.Focus()
            Exit Sub
        End If
        Me.CONDUCTOR.Text = UCase(Me.CONDUCTOR.Text)
    End Sub

    Protected Sub Volatil_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.Volatil.Checked = True Then
            Me.Escoria.Checked = False
        End If
    End Sub

    Protected Sub Escoria_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.Escoria.Checked = True Then
            Me.Volatil.Checked = False
        End If
    End Sub

    Protected Sub Patio_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.Patio.Checked = True Then
            Me.Industria.Checked = False
        End If
    End Sub

    Protected Sub Industria_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.Industria.Checked = True Then
            Me.Patio.Checked = False
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<script language="JavaScript" type="text/javascript" > 

</script>
    <div>
    <table border="1" bordercolor="#CCCCCC"> <!-- TABLA USADA COMO MARCO DEL FORMULARIO-->
    <tr>
    <td>
    
    <table border="0">
            <tr>
                <td align="center" colspan="4" style="border-right: #cccccc thin solid; border-top: #cccccc thin solid; border-left: #cccccc thin solid; border-bottom: #cccccc thin solid">
                    <asp:Label ID="Label11" runat="server" Font-Bold="True" ForeColor="#336677" Text="Entrada de Vehículos" Width="278px"></asp:Label></td>
            </tr>
            <tr>
                <td align="center" colspan="4" style="height: 13px">
                </td>
            </tr>
            <tr>
                <td style="width: 106px" align="left">
                    <asp:Label ID="Label1" runat="server" Text="Fecha de Entrega" Width="112px" ForeColor="#336677"></asp:Label></td>
                <td style="width: 72px">
                    <asp:TextBox ID="FECHAENTREGA" runat="server" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 1px; text-align: right;">
                    <asp:Label ID="Label3" runat="server" Text="Número de Entrada" Width="127px" ForeColor="#336677"></asp:Label></td>
                <td style="width: 142px">
                    <asp:TextBox ID="NUMEROENTREGA" runat="server" ReadOnly="True"></asp:TextBox></td>
            </tr>
        <tr>
            <td align="left" style="width: 106px; height: 26px">
                    <asp:Label ID="Label2" runat="server" Text="Hora Entrega" Width="112px" ForeColor="#336677"></asp:Label></td>
            <td style="width: 72px; height: 26px">
                    <asp:TextBox ID="HORAENTREGA" runat="server" ReadOnly="True"></asp:TextBox></td>
            <td style="width: 1px; height: 26px">
            </td>
            <td style="width: 142px; height: 26px">
            </td>
        </tr>
            <tr>
                <td style="width: 106px; height: 25px;" align="left">
                    <asp:Label ID="Label5" runat="server" ForeColor="#336677" Text="Producto-Insumo" Width="133px"></asp:Label></td>
                <td style="width: 72px; height: 25px;">
                    <asp:DropDownList ID="Producto" runat="server"
                        Width="217px" AutoPostBack="True" OnSelectedIndexChanged="Producto_SelectedIndexChanged">
                    </asp:DropDownList></td>
                <td style="text-align: right;">
                    <asp:CheckBox ID="Volatil" runat="server" Height="13px" Visible="False" Width="62px" Text="Volatil" ForeColor="#336677" TextAlign="Left" OnCheckedChanged="Volatil_CheckedChanged" AutoPostBack="True" /></td>
                <td style="width: 142px; height: 25px; text-align: right;">
                    <asp:CheckBox ID="Escoria" runat="server" Visible="False" Width="75px" ForeColor="#336677" Text="Escoria" TextAlign="Left" OnCheckedChanged="Escoria_CheckedChanged" AutoPostBack="True" /></td>
            </tr>
        <tr>
            <td align="left" style="width: 106px; height: 26px">
            </td>
            <td style="width: 72px; height: 26px">
            </td>
            <td style="text-align: right;">
                <asp:CheckBox ID="Patio" runat="server" Width="53px" Visible="False" ForeColor="#336677" Text="Patio" TextAlign="Left" OnCheckedChanged="Patio_CheckedChanged" AutoPostBack="True" /></td>
            <td style="width: 142px; height: 26px; text-align: right;">
                <asp:CheckBox ID="Industria" runat="server" Visible="False" Width="77px" ForeColor="#336677" Text="Industria" TextAlign="Left" OnCheckedChanged="Industria_CheckedChanged" AutoPostBack="True" /></td>
        </tr>
            <tr>
                <td style="width: 106px; height: 28px;" align="left">
                    <asp:Label ID="Label4" runat="server" Text="Empresa" ForeColor="#336677"></asp:Label></td>
                <td colspan="2" style="height: 28px">
                    <asp:DropDownList ID="Empresa" runat="server"
                        Width="288px" AutoPostBack="True">
                    </asp:DropDownList></td>
                <td style="width: 142px; height: 28px;">
                </td>
            </tr>
        <tr>
            <td style="width: 106px; height: 21px;" align="left">
                <asp:Label ID="LTransportador" runat="server" ForeColor="#336677" Text="Transportador" Width="153px"></asp:Label></td>
            <td colspan="2" style="height: 21px">
                <asp:TextBox ID="Transportador" runat="server" Width="295px"></asp:TextBox></td>
            <td style="width: 142px; height: 21px;">
            </td>
        </tr>
        <tr>
            <td style="width: 106px" align="left">
                    <asp:Label ID="Label7" runat="server" Text="Vehículo" ForeColor="#336677"></asp:Label></td>
            <td style="width: 72px">
                    <asp:TextBox ID="VEHICULO" runat="server" AutoPostBack="True" OnTextChanged="VEHICULO_TextChanged"></asp:TextBox></td>
            <td style="width: 1px">
            </td>
            <td style="width: 142px">
            </td>
        </tr>
        <tr>
            <td style="width: 106px" align="left">
                    <asp:Label ID="Label8" runat="server" Text="Conductor" ForeColor="#336677"></asp:Label></td>
            <td style="width: 72px">
                    <asp:TextBox ID="CONDUCTOR" runat="server" AutoPostBack="True" OnTextChanged="CONDUCTOR_TextChanged"></asp:TextBox></td>
                <td style="width: 1px">
                </td>
                <td style="width: 142px">
                </td>
        </tr>
            <tr>
                <td colspan="2" style="height: 26px">
                    <asp:Label ID="Label10" runat="server" Font-Bold="True" Text="Información de Carga de Ingreso"
                        Width="293px" ForeColor="#336677"></asp:Label></td>
                <td style="height: 26px; width: 1px;" align="right">
                 <asp:Button ID="Btn_NoQuitar" runat="server" Text="R" Height="0px" Width="0px" />
                    
                     <!--<OBJECT classid="clsid:65AD5FCC-C2F4-4B9B-B8B8-C084B148B3EC"> -->
                </td>
                <td style="height: 26px; width: 142px;">
                    </td>                    
            </tr>
            <tr>
                <td style="width: 106px; height: 26px;" align="left">
                    <asp:TextBox ID="PesoT" runat="server" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 72px; height: 26px;">
                <asp:Button ID="Peso" runat="server" Text="Peso Entrada" Font-Bold="True" OnClick="Peso_Click" Width="121px" ForeColor="#336677" /></td>
                <td style="width: 1px; height: 26px;" align="right">
                    </td>
                <td style="width: 142px; height: 26px;">
                    </td>
            </tr>
            <tr>
                <td style="width: 106px" align="left">
                    <asp:Label ID="Label12" runat="server" Text="Observaciones" ForeColor="#336677"></asp:Label></td>
                <td colspan="3" rowspan="2">
                    <asp:TextBox ID="OBSERVACIONES" runat="server" Width="455px" Height="41px" Rows="3" TextMode="MultiLine" Wrap="False"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="left" style="width: 106px; height: 22px;">
                </td>
            </tr>
            <tr>
                <td align="left" style="width: 106px; height: 7px;">
                </td>
                <td colspan="3" style="height: 7px">
                    <asp:Label ID="mensaje" runat="server" Height="21px" Width="456px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" style="width: 106px;">
                    </td>
                <td align="left" colspan="1" style="width: 72px;">
                    </td>
                    <td style="width: 1px">
                    </td>
                    <td style="width: 142px">
                    <asp:Button
                        ID="Guardar" runat="server" Font-Bold="True" Text="Guardar" OnClick="Guardar_Click" ForeColor="#336677" /></td>
            </tr>
        </table>
    
    </td>
    </tr>
    </table>
    
        
    </div>    
</asp:Content>