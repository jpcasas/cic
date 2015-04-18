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
                   " SELECT '..' AS CODIGO1 , '...' AS DESCRIPCION1 " & _
                   " FROM EMPRESA AS EMPRESA_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DtSet, "EMPRESA")
            Me.Empresa.DataSource = DtSet.Tables("EMPRESA").DefaultView
            Me.Empresa.DataTextField = "DESCRIPCION"
            Me.Empresa.DataValueField = "CODIGO"
            Me.Empresa.DataBind()
            
            'CARGAR PROCUCTOS
            ssql = " SELECT PRODUCTO.CODIGO +';'+ CAST(ENTRADA AS NVARCHAR(2)) AS CODIGO, PRODUCTO.NOMBRE" & _
                   " FROM PRODUCTO " & _
                   " UNION " & _
                   " SELECT '..' AS CODIGO1, '...' AS NOMBRE1 " & _
                   " FROM PRODUCTO AS PRODUCTO_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DtSet, "PRODUCTO")
            Me.CProducto.DataSource = DtSet.Tables("PRODUCTO").DefaultView
            Me.CProducto.DataTextField = "NOMBRE"
            Me.CProducto.DataValueField = "CODIGO"
            Me.CProducto.DataBind()
                        
            BIBLIOTECA.DesConectar(conn)
        End If
    End Sub
          
    Protected Sub Peso_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ''SYSTEMBE.SYS = ARCHIVO PLANO PARA PESOS DE ENTRADA
        Dim PlanosBasc As New ArchivosPlanos
        Me.PesoSalida.Text = PlanosBasc.LeerArchivoBascula("C:\temp\SYSTEMBE.SYS")
        PlanosBasc.GeneraArchivoBascula("C:\temp", "SYSTEMBE.SYS", 0)
        If Me.Entra.Checked Then
            If Val(Me.PesoSalida.Text) >= Val(Me.PesoEntrada.Text) Then
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "Para " & Me.CProducto.SelectedItem.Text & ", el peso de entrada no puede ser inferior al de salida"
                Me.PesoNeto.Text = 0
            Else
                Me.PesoNeto.Text = Me.PesoEntrada.Text - Me.PesoSalida.Text
            End If
        Else
            If Val(Me.PesoSalida.Text) <= Val(Me.PesoEntrada.Text) Then
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "Para " & Me.CProducto.SelectedItem.Text & ", el peso de salida no puede ser inferior al de entrada"
                Me.PesoNeto.Text = 0
            Else
                Me.PesoNeto.Text = Me.PesoSalida.Text - Me.PesoEntrada.Text
            End If
        End If
    End Sub
    
    Protected Sub Guardar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String = ""
        Dim Biblioteca As New Biblioteca
        Dim mensaje As String = ""
        Dim Seguridad As New Seguridad
        
        If (Val(Me.PesoSalida.Text) <= 0) Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Verifique el peso de salida"
            Exit Sub
        End If
        If Me.Entra.Checked Then
            If (Val(Me.PesoSalida.Text) > Val(Me.PesoEntrada.Text)) Then
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "Verifique el peso de salida"
                Exit Sub
            End If
        Else
            If (Val(Me.PesoSalida.Text) < Val(Me.PesoEntrada.Text)) Then
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "Verifique el peso de salida"
                Exit Sub
            End If
        End If
        
        If Me.NUMEROENTREGA.Text = 0 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Faltan datos para continuar el proceso"
            Exit Sub
        End If
        
        If (Me.CProducto.SelectedItem.Text <> "CENIZA") And (Me.RecibidoPor.Text = "") Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Digite el nombre de la persona que recibió el producto"
            Exit Sub
        End If
        
        ssql = " UPDATE CONTROLMATERIALES" & _
               " SET    PESOSALIDA = " & Me.PesoSalida.Text & ", HORASALIDA = '" & Replace(Format(Date.Now, "hh:mm:ss tt"), ".", "") & "', PESONETO = " & Me.PesoNeto.Text & ", RECIBIDOPOR = '" & Me.RecibidoPor.Text & "', " & _
               "        OBSERVACIONESSAL = '" & Me.OBSERVACIONES.Text & "'" & _
               " WHERE  CODIGOENTRADA = " & Me.NUMEROENTREGA.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
        If Biblioteca.EjecutarSql(mensaje, ssql) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "EntregaMateriales", "Numero:" & Me.NUMEROENTREGA.Text & ";PesoEntrada:" & Me.PesoEntrada.Text & ";PesoSalida:" & Me.PesoSalida.Text & "; PesoNeto:" & Me.PesoNeto.Text, Session("GRUPOUS"))
            ''Imprimir
            ssql = "SELECT     PRODUCTO.NOMBRE AS CODIGOPRODUCTO, EMPRESA.DESCRIPCION AS EMPRESA, CODIGOENTRADA, " & _
                      " CONTROLMATERIALES.FECHA, CONTROLMATERIALES.HORAENTRADA, CONTROLMATERIALES.HORASALIDA, CONTROLMATERIALES.PESOENTRADA, " & _
                      " CONTROLMATERIALES.PESOSALIDA, CONTROLMATERIALES.PESONETO, CONTROLMATERIALES.TRANSPORTADOR, CONTROLMATERIALES.PLACA, " & _
                      " CONTROLMATERIALES.CONDUCTOR, CONTROLMATERIALES.OPERADORBASCULA, CONTROLMATERIALES.RECIBIDOPOR, " & _
                      " CONTROLMATERIALES.DESPACHADOPOR, CONTROLMATERIALES.CENIZAVOLATIL, CONTROLMATERIALES.CENIZAESCORIA, " & _
                      " CONTROLMATERIALES.CENIZAPATIO, CONTROLMATERIALES.INDUSTRIA, CONTROLMATERIALES.OBSERVACIONES, CONTROLMATERIALES.OBSERVACIONESSAL " & _
                   " FROM CONTROLMATERIALES LEFT OUTER JOIN EMPRESA ON CONTROLMATERIALES.EMPRESA = EMPRESA.CODIGO LEFT OUTER JOIN" & _
                        " PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO " & _
                   " WHERE CODIGOENTRADA = " & Me.NUMEROENTREGA.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
            
            Session("SqlReporte") = ssql
            If Me.CProducto.SelectedItem.Text = "CENIZA" Then
                Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE SALIDA CENIZA")
            Else
                Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE SALIDA MATERIALES")
            End If
            Session("Parametro") = Today
            Session("NombreDataTable") = "CONTROLMATERIALES"
            Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
            'Fin Imprimir         
        Else
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = mensaje
        End If
    End Sub
            
    Protected Sub Producto_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim conn As SqlConnection
        Dim Biblioteca As New Biblioteca
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim Mensaje As String = ""
        Dim Numero As String = ""
        
        conn = Biblioteca.Conectar(Mensaje)
        'CARGAR NUMEROS DE ENTRADA
        
        Me.Producto.Text = Mid(Me.CProducto.Text, 1, InStr(Me.CProducto.Text, ";", CompareMethod.Text) - 1)
        Numero = Mid(Me.CProducto.Text, InStr(Me.CProducto.Text, ";", CompareMethod.Text) + 1, 2)
        Me.Entra.Checked = Val(Numero)
        
        ssql = " SELECT     CODIGOENTRADA" & _
               " FROM CONTROLMATERIALES " & _
               " WHERE HORASALIDA IS NULL AND CODIGOPRODUCTO='" & Me.Producto.Text & "'" & _
               " UNION " & _
               " SELECT 0 AS CODIGOENTRADA1 " & _
               " FROM CONTROLMATERIALES AS CONTROLMATERIALES_1"
        DtSet = New DataSet
        DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
        DtAdapter.Fill(DtSet, "CONTROLMATERIALES")
        Me.NUMEROENTREGA.DataSource = DtSet.Tables("CONTROLMATERIALES").DefaultView
        Me.NUMEROENTREGA.DataTextField = "CODIGOENTRADA"
        Me.NUMEROENTREGA.DataValueField = "CODIGOENTRADA"
        Me.NUMEROENTREGA.DataBind()
        Limpiar()
                
        If Me.CProducto.SelectedItem.Text = "CENIZA" Then
            VisibleControl(True)
            Me.Transportador.Visible = False
            Me.LTransportador.Visible = False
        Else
            Me.Transportador.Visible = True
            Me.LTransportador.Visible = True
            VisibleControl(False)
        End If
    End Sub
    
    Private Sub VisibleControl(ByVal Opcion As Boolean)
        Me.Volatil.Visible = Opcion
        Me.Escoria.Visible = Opcion
        Me.Patio.Visible = Opcion
        Me.Industria.Visible = Opcion
    End Sub
    
    Protected Sub Industria_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.Industria.Checked = True Then
            Me.Patio.Checked = False
        End If
    End Sub

    Protected Sub Entrega_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim ssQl As String
        Dim Mensaje As String
        Mensaje = ""
        Try
            conn = BIBLIOTECA.Conectar(Mensaje)
        
            ssQl = " SELECT     CODIGOENTRADA, CODIGOPRODUCTO, PESOENTRADA, EMPRESA, TRANSPORTADOR, CONDUCTOR, PLACA, CENIZAVOLATIL, CENIZAESCORIA, " & _
                                " CENIZAPATIO, Industria, PRODUCTO.NOMBRE " & _
                   " FROM     CONTROLMATERIALES LEFT OUTER JOIN PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO" & _
                   " WHERE     HORASALIDA IS NULL AND CODIGOENTRADA = " & Me.NUMEROENTREGA.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
            dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)
        
            If dTReader.Read() Then
                Me.Empresa.Text = dTReader("EMPRESA")
                If dTReader("NOMBRE") = "CENIZA" Then
                    VisibleControl(True)
                    Me.LTransportador.Visible = False
                    Me.Transportador.Visible = False
                Else
                    VisibleControl(False)
                    Me.LTransportador.Visible = True
                    Me.Transportador.Visible = True
                End If
                Me.CONDUCTOR.Text = dTReader("CONDUCTOR")
                Me.VEHICULO.Text = dTReader("PLACA")
                Me.Industria.Checked = IIf(dTReader("INDUSTRIA") = -1, True, False)
                Me.Patio.Checked = IIf(dTReader("CENIZAPATIO") = -1, True, False)
                Me.Volatil.Checked = IIf(dTReader("CENIZAVOLATIL") = -1, True, False)
                Me.Escoria.Checked = IIf(dTReader("CENIZAESCORIA") = -1, True, False)
                Me.PesoEntrada.Text = dTReader("PESOENTRADA")
                Me.PesoNeto.Text = 0
                Me.PesoSalida.Text = 0
            Else
                'MsgBox("No existe registro de entrada con este número", MsgBoxStyle.Information, "C.E.S.")
                Limpiar()
                Me.mensaje.Text = "No existe registro de entrada con este número"
                Me.PesoEntrada.Text = 0
            End If
            dTReader.Close()
            'CERRAR LA CONEXION
            BIBLIOTECA.DesConectar(conn)
        Catch ex As Exception
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = ex.Message
            'MsgBox(ex.Message)
        End Try
    End Sub
    
    Private Sub Limpiar()
        Me.Empresa.Text = ".."
        Me.Volatil.Checked = False
        Me.Escoria.Checked = False
        Me.Patio.Checked = False
        Me.Industria.Checked = False
        Me.Transportador.Text = ""
        Me.VEHICULO.Text = ""
        Me.CONDUCTOR.Text = ""
        Me.RecibidoPor.Text = ""
        Me.PesoEntrada.Text = 0
        Me.PesoSalida.Text = 0
        Me.PesoNeto.Text = 0
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
                    <asp:Label ID="Label11" runat="server" Font-Bold="True" ForeColor="#336677" Text="Salida de Vehículos" Width="278px"></asp:Label></td>
            </tr>
            <tr>
                <td align="center" colspan="4" style="height: 13px; text-align: left;">
                <asp:CheckBox ID="Entra" runat="server" Visible="False" Width="120px" />
                    <asp:TextBox ID="Producto" runat="server" Visible="False" Width="44px"></asp:TextBox></td>
            </tr>
            <tr>
                <td style="text-align: right;" align="left">
                    <asp:Label ID="Label1" runat="server" ForeColor="#336677" Text="Producto-Insumo" Width="116px"></asp:Label></td>
                <td style="width: 60px">
                    <asp:DropDownList ID="CProducto" runat="server"
                        Width="245px" AutoPostBack="True" OnSelectedIndexChanged="Producto_SelectedIndexChanged">
                    </asp:DropDownList></td>
                <td style="width: 1px; text-align: right;">
                    <asp:Label ID="Label5" runat="server" ForeColor="#336677" Text="Número de Entrada" Width="141px"></asp:Label></td>
                <td style="width: 142px">
                    <asp:DropDownList ID="NUMEROENTREGA" runat="server" OnSelectedIndexChanged="Entrega_SelectedIndexChanged"
                        Width="217px" AutoPostBack="True">
                    </asp:DropDownList></td>
            </tr>
        <tr>
            <td align="left" style="text-align: right;">
                    <asp:Label ID="Label4" runat="server" Text="Empresa" ForeColor="#336677"></asp:Label></td>
            <td colspan="2" style="height: 26px">
                    <asp:DropDownList ID="Empresa" runat="server"
                        Width="288px" AutoPostBack="True" Enabled="False">
                    </asp:DropDownList></td>
            <td style="width: 142px; height: 26px">
            </td>
        </tr>
            <tr>
                <td style="width: 106px; height: 25px;" align="left">
                    <asp:CheckBox ID="Volatil" runat="server" Height="13px" Visible="False" Width="62px" Text="Volatil" ForeColor="#336677" TextAlign="Left" AutoPostBack="false" Enabled="False" /></td>
                <td style="width: 60px; height: 25px;">
                    <asp:CheckBox ID="Escoria" runat="server" Visible="False" Width="75px" ForeColor="#336677" Text="Escoria" TextAlign="Left" AutoPostBack="False" Enabled="False"/></td>
                <td style="width: 1px; height: 25px; text-align: right;">
                <asp:CheckBox ID="Patio" runat="server" Width="53px" Visible="False" ForeColor="#336677" Text="Patio" TextAlign="Left" AutoPostBack="false" Enabled="False" /></td>
                <td style="width: 142px; height: 25px; text-align: right;">
                <asp:CheckBox ID="Industria" runat="server" Visible="False" Width="77px" ForeColor="#336677" Text="Industria" TextAlign="Left" AutoPostBack="False" Enabled="False" /></td>
            </tr>
        <tr>
            <td align="left" style="text-align: right;">
                <asp:Label ID="LTransportador" runat="server" ForeColor="#336677" Text="Transportador" Width="93px"></asp:Label></td>
            <td>
                <asp:TextBox ID="Transportador" runat="server" Width="242px" ReadOnly="True"></asp:TextBox></td>
            <td style="text-align: right">
                <asp:Label ID="Label8" runat="server" ForeColor="#336677" Text="Conductor"></asp:Label></td>
                            <td>
                    <asp:TextBox ID="CONDUCTOR" runat="server" ReadOnly="True"></asp:TextBox></td>
        </tr>
            <tr>
                <td style="text-align: right;" align="left">
                    <asp:Label ID="Label7" runat="server" Text="Vehículo" ForeColor="#336677" Width="66px"></asp:Label></td>
                <td>
                    <asp:TextBox ID="VEHICULO" runat="server" ReadOnly="True"></asp:TextBox></td>
                <td style="text-align: right">
                <asp:Label ID="Label6" runat="server" ForeColor="#336677" Text="Recibido Por" Width="95px"></asp:Label></td>
                <td>
                <asp:TextBox ID="RecibidoPor" runat="server" Width="238px"></asp:TextBox></td>
            </tr>
        <tr>
            <td colspan="2">
                    <asp:Label ID="Label10" runat="server" Font-Bold="True" Text="Información de Pesaje"
                        Width="155px" ForeColor="#336677"></asp:Label></td>
                <td>
                </td>
                <td>
                </td>
        </tr>
            <tr>
                <td style="text-align: right;" align="left">
                    <asp:TextBox ID="PesoEntrada" runat="server" Width="76px" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 60px">
                    <asp:Label ID="Label3" runat="server" ForeColor="#336677" Text="Peso Entrada" Width="196px"></asp:Label></td>
                <td colspan="1" style="width: 1px">
                    </td>
                <td style="width: 142px">
                </td>
            </tr>
        <tr>
            <td align="left" style="height: 26px; text-align: right;">
                <asp:TextBox ID="PesoSalida" runat="server" Width="76px" ReadOnly="True"></asp:TextBox></td>
            <td style="width: 60px; height: 26px;">
                <asp:Button ID="Peso" runat="server" Text="Peso Salida" Font-Bold="True" OnClick="Peso_Click" Width="121px" ForeColor="#336677" /></td>
            <td colspan="1" style="width: 1px; height: 26px;">
                </td>
            <td style="width: 142px; height: 26px;">
            </td>
        </tr>
            <tr>
                <td style="text-align: right;" align="left">
                    <asp:TextBox ID="PesoNeto" runat="server" Width="76px" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 60px; height: 26px;">
                    <asp:Label ID="Label2" runat="server" ForeColor="#336677" Text="Peso Neto" Width="196px"></asp:Label></td>
                <td style="width: 1px; height: 26px;" align="right">
                    </td>
                <td style="width: 142px; height: 26px;">
                    </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="Label12" runat="server" Text="Observaciones" ForeColor="#336677"></asp:Label></td>
                <td colspan="3" rowspan="2">
                    <asp:TextBox ID="OBSERVACIONES" runat="server" Width="455px" Height="41px" Rows="3" TextMode="MultiLine" Wrap="False"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="left">
                </td>
            </tr>
            <tr>
                <td align="left">
                </td>
                <td colspan="3" style="height: 7px">
                    <asp:Label ID="mensaje" runat="server" Height="21px" Width="456px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left">
                    </td>
                <td align="left" colspan="1" style="width: 60px; height: 26px;">
                    </td>
                    <td style="width: 1px; height: 26px;">
                    </td>
                    <td style="width: 142px; height: 26px;">
                    <asp:Button
                        ID="Guardar" runat="server" Font-Bold="True" Text="Guardar" OnClick="Guardar_Click" ForeColor="#336677" /></td>
            </tr>
        </table>
    
    </td>
    </tr>
    </table>
    
        
    </div>    
</asp:Content>