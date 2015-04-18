    <%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Entrada de Vehículos" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ import Namespace="System.IO.Ports" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Drawing" %>

<script runat="server">
    
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

    Protected Sub Producto_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim conn As SqlConnection
        Dim Biblioteca As New Biblioteca
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim Mensaje As String = ""
        Dim Numero As String = ""
        Dim ReimpresionesPermitidas As Integer
        ReimpresionesPermitidas = Biblioteca.ValorParametro("REIMPRESIONES")
        conn = Biblioteca.Conectar(Mensaje)
        'CARGAR NUMEROS DE ENTRADA
        
        Me.Producto.Text = Mid(Me.CProducto.Text, 1, InStr(Me.CProducto.Text, ";", CompareMethod.Text) - 1)
        Numero = Mid(Me.CProducto.Text, InStr(Me.CProducto.Text, ";", CompareMethod.Text) + 1, 2)
        'ENTREGAS        
        ssql = " SELECT CODIGOENTRADA" & _
               " FROM CONTROLMATERIALES " & _
               " WHERE (FECHA BETWEEN CONVERT(DATETIME, '" & Format(DateAdd(DateInterval.Day, -1, Today), "yyyy-MM-dd 00:00:00") & "', 102)AND CONVERT(DATETIME, '" & Format(Today, "yyyy-MM-dd 00:00:00") & "', 102)) AND CODIGOPRODUCTO='" & Me.Producto.Text & "' AND IMPRESIONESENT <=" & ReimpresionesPermitidas & _
               " UNION " & _
               " SELECT 0 AS CODIGOENTRADA1 " & _
               " FROM CONTROLMATERIALES AS CONTROLMATERIALES_1"
        DtSet = New DataSet
        DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
        DtAdapter.Fill(DtSet, "CONTROLMATERIALES")
        Me.NUMEROENTREGAENT.DataSource = DtSet.Tables("CONTROLMATERIALES").DefaultView
        Me.NUMEROENTREGAENT.DataTextField = "CODIGOENTRADA"
        Me.NUMEROENTREGAENT.DataValueField = "CODIGOENTRADA"
        Me.NUMEROENTREGAENT.DataBind()
        
        'SALIDAS
        ssql = " SELECT     CODIGOENTRADA" & _
       " FROM CONTROLMATERIALES " & _
       " WHERE  HORASALIDA IS NOT NULL AND (FECHA BETWEEN CONVERT(DATETIME, '" & Format(DateAdd(DateInterval.Day, -1, Today), "yyyy-MM-dd 00:00:00") & "', 102)AND CONVERT(DATETIME, '" & Format(Today, "yyyy-MM-dd 00:00:00") & "', 102)) AND CODIGOPRODUCTO='" & Me.Producto.Text & "' AND IMPRESIONESSAL<=" & ReimpresionesPermitidas & _
       " UNION " & _
       " SELECT 0 AS CODIGOENTRADA1 " & _
       " FROM CONTROLMATERIALES AS CONTROLMATERIALES_1"
        DtSet = New DataSet
        DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
        DtAdapter.Fill(DtSet, "CONTROLMATERIALES")
        Me.NUMEROENTREGASAL.DataSource = DtSet.Tables("CONTROLMATERIALES").DefaultView
        Me.NUMEROENTREGASAL.DataTextField = "CODIGOENTRADA"
        Me.NUMEROENTREGASAL.DataValueField = "CODIGOENTRADA"
        Me.NUMEROENTREGASAL.DataBind()
                
        If Me.CProducto.SelectedItem.Text = "CENIZA" Then
            Me.Transportador.Visible = False
            Me.LTransportador.Visible = False
        Else
            Me.Transportador.Visible = True
            Me.LTransportador.Visible = True
        End If
    End Sub

    Protected Sub EntregaEnt_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim ssQl As String
        Dim Mensaje As String
        Dim HoraFiltro As DateTime = DateTime.Now
        
        Me.NUMEROENTREGASAL.Text = 0
        Mensaje = ""
        Try
            conn = BIBLIOTECA.Conectar(Mensaje)
            HoraFiltro = HoraFiltro.AddHours(-1)
            
            ssQl = " SELECT     CODIGOENTRADA, CODIGOPRODUCTO, PESOENTRADA, PESONETO, EMPRESA, TRANSPORTADOR, CONDUCTOR, PLACA, CENIZAVOLATIL, CENIZAESCORIA, " & _
                                " CENIZAPATIO, INDUSTRIA, PRODUCTO.NOMBRE " & _
                   " FROM     CONTROLMATERIALES LEFT OUTER JOIN PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO" & _
                   " WHERE    CODIGOENTRADA = " & Me.NUMEROENTREGAENT.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
            dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)
        
            If dTReader.Read() Then
                Me.Empresa.Text = dTReader("EMPRESA")
                If dTReader("NOMBRE") = "CENIZA" Then
                    Me.LTransportador.Visible = False
                    Me.Transportador.Visible = False
                Else
                    Me.LTransportador.Visible = True
                    Me.Transportador.Visible = True
                End If
                Me.CONDUCTOR.Text = dTReader("CONDUCTOR")
                Me.VEHICULO.Text = dTReader("PLACA")
                Me.PesoNeto.Text = dTReader("PESONETO")
            Else
                'MsgBox("No existe registro de entrada con este número", MsgBoxStyle.Information, "C.E.S.")
                Me.mensaje.Text = "No existe registro de entrada con este número"
                Me.CONDUCTOR.Text = ""
                Me.VEHICULO.Text = ""
                Me.PesoNeto.Text = 0
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
    
    Protected Sub EntregaSal_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim ssQl As String
        Dim Mensaje As String
        Dim HoraFiltro As DateTime = DateTime.Now
        
        Me.NUMEROENTREGAENT.Text = 0
        Mensaje = ""
        Try
            conn = BIBLIOTECA.Conectar(Mensaje)
            HoraFiltro = HoraFiltro.AddHours(-1)
            
            ssQl = " SELECT     CODIGOENTRADA, CODIGOPRODUCTO, PESOENTRADA, PESONETO, EMPRESA, TRANSPORTADOR, CONDUCTOR, PLACA, CENIZAVOLATIL, CENIZAESCORIA, " & _
                                " CENIZAPATIO, INDUSTRIA, PRODUCTO.NOMBRE " & _
                   " FROM     CONTROLMATERIALES LEFT OUTER JOIN PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO" & _
                   " WHERE    CODIGOENTRADA = " & Me.NUMEROENTREGASAL.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
            dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)
        
            If dTReader.Read() Then
                Me.Empresa.Text = dTReader("EMPRESA")
                If dTReader("NOMBRE") = "CENIZA" Then
                    Me.LTransportador.Visible = False
                    Me.Transportador.Visible = False
                Else
                    Me.LTransportador.Visible = True
                    Me.Transportador.Visible = True
                End If
                Me.CONDUCTOR.Text = dTReader("CONDUCTOR")
                Me.VEHICULO.Text = dTReader("PLACA")
                Me.PesoNeto.Text = dTReader("PESONETO")
            Else
                'MsgBox("No existe registro de entrada con este número", MsgBoxStyle.Information, "C.E.S.")
                Me.mensaje.Text = "No existe registro de entrada con este número"
                Me.CONDUCTOR.Text = ""
                Me.VEHICULO.Text = ""
                Me.PesoNeto.Text = 0
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

    Protected Sub Salida_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'salida
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim ssql As String = ""
        Dim mensaje As String = ""
        
        If Me.PesoNeto.Text = "" Then Me.PesoNeto.Text = 0
        If Me.PesoNeto.Text <> 0 Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "Reimprimir", "EntregaMateriales", "Numero:" & Me.NUMEROENTREGAENT.Text & ";Producto:" & Me.CProducto.SelectedItem.Value & ";PesoNeto:" & Me.PesoNeto.Text, Session("GRUPOUS"))
            ''Imprimir
            ssql = "SELECT     PRODUCTO.NOMBRE AS CODIGOPRODUCTO, EMPRESA.DESCRIPCION AS EMPRESA, CODIGOENTRADA, " & _
                      " CONTROLMATERIALES.FECHA, CONTROLMATERIALES.HORAENTRADA, CONTROLMATERIALES.HORASALIDA, CONTROLMATERIALES.PESOENTRADA, " & _
                      " CONTROLMATERIALES.PESOSALIDA, CONTROLMATERIALES.PESONETO, CONTROLMATERIALES.TRANSPORTADOR, CONTROLMATERIALES.PLACA, " & _
                      " CONTROLMATERIALES.CONDUCTOR, CONTROLMATERIALES.OPERADORBASCULA, CONTROLMATERIALES.RECIBIDOPOR, " & _
                      " CONTROLMATERIALES.DESPACHADOPOR, CONTROLMATERIALES.CENIZAVOLATIL, CONTROLMATERIALES.CENIZAESCORIA, " & _
                      " CONTROLMATERIALES.CENIZAPATIO, CONTROLMATERIALES.INDUSTRIA, CONTROLMATERIALES.OBSERVACIONES, CONTROLMATERIALES.OBSERVACIONESSAL " & _
                   " FROM CONTROLMATERIALES LEFT OUTER JOIN EMPRESA ON CONTROLMATERIALES.EMPRESA = EMPRESA.CODIGO LEFT OUTER JOIN" & _
                        " PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO " & _
                   " WHERE CODIGOENTRADA = " & Me.NUMEROENTREGASAL.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
            
            Session("SqlReporte") = ssql
            If Me.CProducto.SelectedItem.Text = "CENIZA" Then
                Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE SALIDA CENIZA")
            Else
                Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE SALIDA MATERIALES")
            End If
            Session("Parametro") = Today
            Session("NombreDataTable") = "CONTROLMATERIALES"
            Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
            
            ssql = " UPDATE CONTROLMATERIALES SET IMPRESIONESSAL = IMPRESIONESSAL + 1 " & _
                   " WHERE CODIGOENTRADA = " & Me.NUMEROENTREGASAL.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
            Biblioteca.EjecutarSql(mensaje, ssql)
            'Fin Imprimir         
        Else
            Biblioteca.MostrarMensaje(Page, "Peso Neto = 0 No se ha registrado salida", 2)
        End If
    End Sub

    Protected Sub Entrada_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Entrada
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim ssql As String = ""
        Dim mensaje As String = ""

        Seguridad.RegistroAuditoria(Session("Usuario"), "Reimprimir", "SalidaMateriales", "Numero:" & Me.NUMEROENTREGAENT.Text & ";Producto:" & Me.CProducto.SelectedItem.Value & ";PesoNeto:" & Me.PesoNeto.Text, Session("GRUPOUS"))
        ''Imprimir
        ssql = "SELECT     PRODUCTO.NOMBRE AS CODIGOPRODUCTO, EMPRESA.DESCRIPCION AS EMPRESA, CODIGOENTRADA, " & _
                  " CONTROLMATERIALES.FECHA, CONTROLMATERIALES.HORAENTRADA, CONTROLMATERIALES.HORASALIDA, CONTROLMATERIALES.PESOENTRADA, " & _
                  " CONTROLMATERIALES.PESOSALIDA, CONTROLMATERIALES.PESONETO, CONTROLMATERIALES.TRANSPORTADOR, CONTROLMATERIALES.PLACA, " & _
                  " CONTROLMATERIALES.CONDUCTOR, CONTROLMATERIALES.OPERADORBASCULA, CONTROLMATERIALES.RECIBIDOPOR, " & _
                  " CONTROLMATERIALES.DESPACHADOPOR, CONTROLMATERIALES.CENIZAVOLATIL, CONTROLMATERIALES.CENIZAESCORIA, " & _
                  " CONTROLMATERIALES.CENIZAPATIO, CONTROLMATERIALES.INDUSTRIA, CONTROLMATERIALES.OBSERVACIONES, CONTROLMATERIALES.OBSERVACIONESSAL " & _
               " FROM CONTROLMATERIALES LEFT OUTER JOIN EMPRESA ON CONTROLMATERIALES.EMPRESA = EMPRESA.CODIGO LEFT OUTER JOIN" & _
                    " PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO " & _
               " WHERE CODIGOENTRADA = " & Me.NUMEROENTREGAENT.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
    
        Session("SqlReporte") = ssql
        If Me.CProducto.SelectedItem.Text = "CENIZA" Then
            Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE ENTRADA CENIZA")
        Else
            Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE ENTRADA MATERIALES")
        End If
        Session("Parametro") = Today
        Session("NombreDataTable") = "CONTROLMATERIALES"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        ssql = " UPDATE CONTROLMATERIALES SET IMPRESIONESENT = IMPRESIONESENT + 1 " & _
               " WHERE CODIGOENTRADA = " & Me.NUMEROENTREGAENT.Text & " AND CODIGOPRODUCTO= '" & Me.Producto.Text & "'"
        Biblioteca.EjecutarSql(mensaje, ssql)
        'Fin Imprimir                 
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<script language="JavaScript" type="text/javascript" > 

</script>
    <div>
    <table border="1" bordercolor="#CCCCCC" style="height: 286px; width: 652px;"> <!-- TABLA USADA COMO MARCO DEL FORMULARIO-->
    <tr>
    <td align="center" style="width: 571px">
    
    <table border="0" style="width: 617px" >
            <tr>
                <td align="center" colspan="3">
                    <asp:Label ID="Label11" runat="server" Font-Bold="True" ForeColor="#336677" Text="Reimpresión de Entradas y Salidas de Vehículos" Width="449px"></asp:Label></td>
            </tr>
            <tr>
                <td align="center" colspan="2" style="height: 13px; text-align: left;">
                    <asp:TextBox ID="Producto" runat="server" Visible="False" Width="44px"></asp:TextBox></td>
                <td align="center" colspan="1">
                </td>
            </tr>
            <tr>
                <td style="width: 106px" align="left">
                    <asp:Label ID="Label1" runat="server" ForeColor="#336677" Text="Producto"></asp:Label></td>
                <td style="width: 369px">
                    <asp:DropDownList ID="CProducto" runat="server"
                        Width="245px" AutoPostBack="True" OnSelectedIndexChanged="Producto_SelectedIndexChanged">
                    </asp:DropDownList></td>
                <td>
                </td>
            </tr>
        <tr>
            <td align="left">
                <asp:Label ID="Label5" runat="server" ForeColor="#336677" Text="Entradas"
                    Width="126px"></asp:Label></td>
            <td colspan="1">
                <asp:DropDownList ID="NUMEROENTREGAENT" runat="server" OnSelectedIndexChanged="EntregaEnt_SelectedIndexChanged"
                        Width="187px" AutoPostBack="True">
                </asp:DropDownList></td>
            <td colspan="1">
                    </td>
        </tr>
        <tr>
            <td align="left" style="width: 106px; height: 26px">
                    <asp:Button
                        ID="Entrada" runat="server" Font-Bold="True" Text="Imprimir Entrada " ForeColor="#336677" OnClick="Entrada_Click" Width="143px" /></td>
            <td colspan="1" style="width: 369px; height: 26px">
            </td>
            <td colspan="1">
            </td>
        </tr>
        <tr>
            <td align="left" style="width: 106px; height: 26px">
            </td>
            <td colspan="1" style="width: 369px; height: 26px">
            </td>
            <td colspan="1">
            </td>
        </tr>
        <tr>
            <td align="left" style="width: 106px; height: 26px">
                <asp:Label ID="Label3" runat="server" ForeColor="#336677" Text="Salidas"
                    Width="124px"></asp:Label></td>
            <td colspan="1" style="width: 369px; height: 26px">
                <asp:DropDownList ID="NUMEROENTREGASAL" runat="server" OnSelectedIndexChanged="EntregaSal_SelectedIndexChanged"
                        Width="187px" AutoPostBack="True">
                </asp:DropDownList></td>
            <td colspan="1">
                        </td>
        </tr>
        <tr>
            <td align="left" style="width: 106px; height: 26px">
                        <asp:Button
                        ID="Salida" runat="server" Font-Bold="True" Text="Imprimir Salida" ForeColor="#336677" OnClick="Salida_Click" Width="144px" /></td>
            <td colspan="1" style="width: 369px; height: 26px">
            </td>
            <td colspan="1">
            </td>
        </tr>
        <tr>
            <td align="left" style="width: 106px; height: 26px">
                    <asp:Label ID="Label4" runat="server" Text="Empresa" ForeColor="#336677"></asp:Label></td>
            <td colspan="1" style="height: 26px; width: 369px;">
                    <asp:DropDownList ID="Empresa" runat="server"
                        Width="288px" AutoPostBack="True" Enabled="False">
                    </asp:DropDownList></td>
            <td colspan="1">
            </td>
        </tr>
            <tr>
                <td style="width: 106px; height: 25px;" align="left">
                <asp:Label ID="LTransportador" runat="server" ForeColor="#336677" Text="Transportador" Width="93px"></asp:Label></td>
                <td style="width: 369px; height: 25px;">
                <asp:TextBox ID="Transportador" runat="server" Width="295px" ReadOnly="True"></asp:TextBox></td>
                <td>
                </td>
            </tr>
        <tr>
            <td align="left" style="width: 106px; height: 26px">
                    <asp:Label ID="Label7" runat="server" Text="Vehículo" ForeColor="#336677" Width="66px"></asp:Label></td>
            <td colspan="1" style="height: 26px; text-align: left; width: 369px;">
                    <asp:TextBox ID="VEHICULO" runat="server" ReadOnly="True"></asp:TextBox></td>
            <td colspan="1">
            </td>
        </tr>
        <tr>
            <td style="width: 106px; height: 21px;" align="left">
                <asp:Label ID="Label8" runat="server" ForeColor="#336677" Text="Conductor"></asp:Label></td>
            <td colspan="1" style="height: 21px; width: 369px;">
                    <asp:TextBox ID="CONDUCTOR" runat="server" ReadOnly="True"></asp:TextBox></td>
            <td colspan="1">
            </td>
        </tr>
        <tr>
            <td colspan="2">
                    <asp:Label ID="Label10" runat="server" Font-Bold="True" Text="Información Final de Pesaje"
                        Width="381px" ForeColor="#336677"></asp:Label></td>
            <td colspan="1">
            </td>
        </tr>
            <tr>
                <td style="width: 106px; height: 26px; text-align: right;" align="left">
                    <asp:TextBox ID="PesoNeto" runat="server" Width="76px" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 369px; height: 26px;">
                    <asp:Label ID="Label2" runat="server" ForeColor="#336677" Text="Peso Neto" Width="196px"></asp:Label></td>
                <td>
                </td>
            </tr>
            <tr>
                <td style="width: 106px; height: 14px;" align="left">
                    </td>
                <td style="width: 369px; height: 14px;">
                </td>
                <td>
                </td>
            </tr>
            <tr>
                <td align="left" colspan="3">
                    <asp:Label ID="mensaje" runat="server" Height="19px" Width="583px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" style="width: 106px; height: 14px;">
                    </td>
                <td align="left" colspan="1" style="width: 369px; height: 14px;">
                    </td>
                <td align="left" colspan="1" style="height: 14px">
                </td>
            </tr>
        </table>
    
    </td>
    </tr>
    </table>
    
        
    </div>    
</asp:Content>