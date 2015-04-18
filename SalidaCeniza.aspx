<%@ Page Language="VB" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ClientScript As String
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Mensaje As String
        Dim Seguridad As New Seguridad
        
        ssql = ""
        If Me.CODIGOENTRADA.Text = "" Or Me.FECHA.Text = "" Then
            'MsgBox("No se puede insertar un número nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un número nulo"
            Exit Sub
        End If
        If Me.Patio.Checked = False And Me.Industria.Checked = False Then
            Biblioteca.MostrarMensaje(Page, "Debe seleccionar sí la ceniza es para Patio ó Industria", 2)
            Exit Sub
        End If
        If Me.Escoria.Checked = False And Me.Volatil.Checked = False Then
            Biblioteca.MostrarMensaje(Page, "Debe seleccionar sí la ceniza es Volatil ó Escoría", 2)
            Exit Sub
        End If
        If Me.CODIGOPRODUCTO.Text.Trim = "" Then
            Me.CODIGOPRODUCTO.Text = "02"
        End If
        Select Case Session("ParamBDProd")
            Case "Actualizar"
                ssql = " UPDATE CONTROLMATERIALES SET " & _
                                " CONTROLMATERIALES.CODIGOENTRADA = '" & Me.CODIGOENTRADA.Text & "', " & _
                                " CONTROLMATERIALES.CODIGOPRODUCTO = '" & Me.CODIGOPRODUCTO.Text & "'," & _
                                " CONTROLMATERIALES.FECHA = CONVERT(DATETIME, '" & Format(CDate(Me.FECHA.Text), "yyyy-MM-dd 00:00:00") & "', 102)," & _
                                " CONTROLMATERIALES.HORAENTRADA = '" & Me.HORAENTRADA.Text & "'," & _
                                " CONTROLMATERIALES.HORASALIDA = '" & Me.HORASALIDA.Text & "', " & _
                                " CONTROLMATERIALES.PESOENTRADA = " & Me.PESOENTRADA.Text & ", " & _
                                " CONTROLMATERIALES.PESOSALIDA = " & Me.PESOSALIDA.Text & ", " & _
                                " CONTROLMATERIALES.PESONETO = " & Me.PESONETO.Text & "," & _
                                " CONTROLMATERIALES.EMPRESA = '" & Me.Empresa.SelectedItem.Value & "', " & _
                                " CONTROLMATERIALES.CONDUCTOR = '" & Me.CONDUCTOR.Text & "', " & _
                                " CONTROLMATERIALES.PLACA = '" & Me.PLACA.Text.ToUpper & "', " & _
                                " CONTROLMATERIALES.OPERADORBASCULA = '" & Me.OPERADORBASCULA.Text.ToUpper & "', " & _
                                " CONTROLMATERIALES.RECIBIDOPOR = '" & Me.RECIBIDOPOR.Text.ToUpper & "', " & _
                                " CONTROLMATERIALES.DESPACHADOPOR = '" & Me.DESPACHADOPOR.Text.ToUpper & "', " & _
                                " CONTROLMATERIALES.CENIZAVOLATIL = " & IIf(Me.Volatil.Checked = True, -1, 0) & "," & _
                                " CONTROLMATERIALES.CENIZAESCORIA = " & IIf(Me.Escoria.Checked = True, -1, 0) & "," & _
                                " CONTROLMATERIALES.CENIZAPATIO = " & IIf(Me.Patio.Checked = True, -1, 0) & "," & _
                                " CONTROLMATERIALES.INDUSTRIA = " & IIf(Me.Industria.Checked = True, -1, 0) & "," & _
                                " CONTROLMATERIALES.IMPRESIONESENT = " & IIf(Me.IMPRESIONESENT.Text = "", 0, Me.IMPRESIONESENT.Text) & "," & _
                                " CONTROLMATERIALES.IMPRESIONESSAL = " & IIf(Me.IMPRESIONESSAL.Text = "", 0, Me.IMPRESIONESSAL.Text) & "" & _
                      " WHERE CODIGOENTRADA = " & Me.CODIGOENTRADA.Text & " AND CODIGOPRODUCTO= '" & Me.CODIGOPRODUCTO.Text & "'"
            Case "Eliminar"
                ssql = " DELETE " & _
                      " FROM CONTROLMATERIALES" & _
                      " WHERE CODIGOENTRADA = " & Me.CODIGOENTRADA.Text & " AND CODIGOPRODUCTO= '" & Me.CODIGOPRODUCTO.Text & "'"
            Case "Insertar"
                ssql = " INSERT INTO CONTROLMATERIALES ( CODIGOENTRADA, CODIGOPRODUCTO, FECHA, HORAENTRADA, HORASALIDA, PESOENTRADA, PESOSALIDA, PESONETO, EMPRESA, CONDUCTOR, PLACA, OPERADORBASCULA, RECIBIDOPOR, DESPACHADOPOR, CENIZAVOLATIL, CENIZAESCORIA, CENIZAPATIO, INDUSTRIA,OBSERVACIONES,OBSERVACIONESSAL,IMPRESIONESENT,IMPRESIONESSAL )" & _
                       " VALUES('" & Me.CODIGOENTRADA.Text & "', '" & Me.CODIGOPRODUCTO.Text & "', CONVERT(DATETIME, '" & Format(CDate(Me.FECHA.Text), "yyyy-MM-dd 00:00:00") & "', 102), '" & Me.HORAENTRADA.Text & "', '" & Me.HORASALIDA.Text & "', " & Me.PESOENTRADA.Text & ", " & Me.PESOSALIDA.Text & ", " & Me.PESONETO.Text & ", '" & Me.Empresa.SelectedItem.Value & "', '" & Me.CONDUCTOR.Text.ToUpper & "', '" & Me.PLACA.Text.ToUpper & "', '" & Me.OPERADORBASCULA.Text.ToUpper & "', '" & Me.RECIBIDOPOR.Text.ToUpper & "', '" & Me.DESPACHADOPOR.Text.ToUpper & "', " & IIf(Me.Volatil.Checked = True, -1, 0) & ", " & IIf(Me.Escoria.Checked = True, -1, 0) & ", " & IIf(Me.Patio.Checked = True, -1, 0) & ", " & IIf(Me.Industria.Checked = True, -1, 0) & ", '-','-'," & IIf(Me.IMPRESIONESENT.Text = "", 0, Me.IMPRESIONESENT.Text) & "," & IIf(Me.IMPRESIONESSAL.Text = "", 0, Me.IMPRESIONESSAL.Text) & ")"
        End Select
        
        Mensaje = ""
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), Session("ParamBD"), "SalidaCeniza", "Numero:" & Me.CODIGOENTRADA.Text & ";PesoEntrada:" & Me.PESOENTRADA.Text & ";PesoSalida:" & Me.PESOSALIDA.Text & ";PesoNeto:" & Me.PESONETO.Text, Session("GRUPOUS"))
            'Cerrar el explorador            
            ClientScript = "<script> window.close();" & "<" & "/script>"
            Response.Write(ClientScript)
        Else
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Mensaje
        End If
    End Sub
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        
        Me.BtnActualizar.Text = Session("ParamBDProd")
        If Not Page.IsPostBack Then
            Actualizar()
        End If
    End Sub
    Private Sub Actualizar()
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtReader As SqlDataReader
        Dim ssql As String
        Dim Mensaje As String = ""
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
                
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        
        'CARGAR Empresas
        ssql = " SELECT EMPRESA.CODIGO, EMPRESA.DESCRIPCION " & _
               " FROM EMPRESA " & _
               " UNION " & _
               " SELECT '..' AS CODIGO1, '...' AS DESCRIPCION1  " & _
               " FROM EMPRESA AS EMPRESA_1"
        DtSet = New DataSet
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtAdapter.Fill(DtSet, "EMPRESA")
        Me.Empresa.DataSource = DtSet.Tables("EMPRESA").DefaultView
        Me.Empresa.DataTextField = "DESCRIPCION"
        Me.Empresa.DataValueField = "CODIGO"
        Me.Empresa.DataBind()
        
        If Session("ParamBDProd") <> "Insertar" Then
            ssql = " SELECT * " & _
              " FROM   CONTROLMATERIALES INNER JOIN " & _
                       " PRODUCTO ON CONTROLMATERIALES.CODIGOPRODUCTO = PRODUCTO.CODIGO " & _
              " WHERE PRODUCTO.NOMBRE LIKE '%CENIZA%' AND CODIGOENTRADA = '" & Trim(Session("CodSal")) & "'"
            
            DtReader = BIBLIOTECA.CargarDataReader(Mensaje, ssql, conn)
            If DtReader.Read Then
                Me.CODIGOENTRADA.Text = Trim(DtReader("CODIGOENTRADA"))
                Me.FECHA.Text = Format(DtReader("FECHA"), "dd/MM/yyyy")
                Me.HORAENTRADA.Text = UCase(Replace(Format(DtReader("HORAENTRADA"), "hh:mm tt"), ".", ""))
                Me.HORASALIDA.Text = UCase(Replace(Format(CDate(IIf(DtReader("HORASALIDA").ToString = "", Today, DtReader("HORASALIDA").ToString)), "hh:mm tt"), ".", ""))
                Me.PESOENTRADA.Text = DtReader("PESOENTRADA")
                Me.PESOSALIDA.Text = DtReader("PESOSALIDA")
                Me.PESONETO.Text = DtReader("PESONETO")
                Me.Empresa.Text = Trim(DtReader("EMPRESA"))
                Me.CONDUCTOR.Text = Trim(DtReader("CONDUCTOR").ToString)
                Me.PLACA.Text = Trim(DtReader("PLACA").ToString)
                Me.OPERADORBASCULA.Text = DtReader("OPERADORBASCULA").ToString
                Me.RECIBIDOPOR.Text = DtReader("RECIBIDOPOR").ToString
                Me.DESPACHADOPOR.Text = DtReader("DESPACHADOPOR").ToString
                Me.Industria.Checked = IIf(DtReader("INDUSTRIA") = -1, True, False)
                Me.Patio.Checked = IIf(DtReader("CENIZAPATIO") = -1, True, False)
                Me.Volatil.Checked = IIf(DtReader("CENIZAVOLATIL") = -1, True, False)
                Me.Escoria.Checked = IIf(DtReader("CENIZAESCORIA") = -1, True, False)
                Me.IMPRESIONESENT.Text = DtReader("IMPRESIONESENT").ToString
                Me.IMPRESIONESSAL.Text = DtReader("IMPRESIONESSAL").ToString
                Me.CODIGOPRODUCTO.Text = DtReader("CODIGOPRODUCTO").ToString
                DtReader.Close()
            End If
        Else
            ssql = " SELECT * " & _
              " FROM PRODUCTO" & _
              " WHERE PRODUCTO.NOMBRE LIKE '%CENIZA%'"
            DtReader = BIBLIOTECA.CargarDataReader(Mensaje, ssql, conn)
            Me.CODIGOENTRADA.ReadOnly = False
            If DtReader.Read Then
                Me.CODIGOPRODUCTO.Text = DtReader("CODIGO").ToString
                DtReader.Close()
            Else
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "No podra crear una salida de ceniza," & vbCrLf & " Verifique el nombre del producto ceniza "
            End If
        End If
        BIBLIOTECA.DesConectar(conn)
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

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Entradas Carbon Mes</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <table style="border-right: #cccccc thin double; padding-right: 1px; border-top: #cccccc thin double; padding-left: 1px; padding-bottom: 1px; border-left: #cccccc thin double; padding-top: 1px; border-bottom: #cccccc thin double"> <!-- TABLA USADA COMO MARCO DEL FORMULARIO-->
        <tr>
        <td style="height: 372px">
            <table>
                <tr>
                    <td align="center" colspan="5" height="1" style="color: #000000">
                        <asp:Label ID="Label17" runat="server" Font-Bold="True" ForeColor="#336677" Text="Salida Ceniza" Width="179px"></asp:Label></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 13px">
                    </td>
                    <td style="width: 195px; height: 13px">
                    </td>
                    <td style="width: 20px; height: 13px;">
                    </td>
                    <td style="width: 106px; height: 13px">
                        &nbsp;</td>
                    <td style="width: 106px; height: 13px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="FECHA" runat="server" Width="68px"></asp:TextBox><asp:Label
                            ID="Label20" runat="server" Font-Size="0.65em" ForeColor="Silver" Text="(DD/MM/YYYY)" Width="82px"></asp:Label></td>
                    <td align="left" height="1" style="width: 20px">
                        <asp:CompareValidator ID="cvFecha1" runat="server" ControlToValidate="FECHA"
                            ErrorMessage="*" Operator="DataTypeCheck" SetFocusOnError="True" Type="Date"
                            Width="7px"></asp:CompareValidator></td>
                    <td align="left" height="1" style="text-align: right">
                        <asp:Label ID="Label12" runat="server" Font-Bold="True" ForeColor="#336677" Text="Conductor"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:TextBox ID="CONDUCTOR" runat="server" EnableTheming="True" Width="195px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="right">
                        <asp:Label ID="Label8" runat="server" Font-Bold="True" ForeColor="#336677" Text="Numero Entrada"></asp:Label></td>
                    <td align="left" height="1">
                        <asp:TextBox ID="CODIGOENTRADA" runat="server" EnableTheming="True" Width="101px" ReadOnly="True"></asp:TextBox></td>
                    <td align="left" height="1">
                        </td>
                    <td align="left" height="1" style="text-align: right">
                        <asp:Label ID="Label16" runat="server" Font-Bold="True" ForeColor="#336677" Text="Placa"></asp:Label></td>
                    <td align="left" height="1">
                        <asp:TextBox ID="PLACA" runat="server" EnableTheming="True" Width="57px" Wrap="False"></asp:TextBox><asp:RegularExpressionValidator ID="RevPlaca" runat="server" ControlToValidate="CAMION"
                            ErrorMessage="Placa no válida" ValidationExpression="\w\w\w\w\w\w" Visible="False"
                            Width="94px"></asp:RegularExpressionValidator></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label6" runat="server" Font-Bold="True" ForeColor="#336677" Text="Hora Entrada"></asp:Label>
                    </td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="HORAENTRADA" runat="server" EnableTheming="True" Width="66px"></asp:TextBox>
                        <asp:Label ID="Label19" runat="server" Font-Size="0.65em" ForeColor="Silver" Text="(HH:MM AM/PM)" Width="113px"></asp:Label></td>
                    <td align="left" height="1" style="width: 20px">
                        <asp:RegularExpressionValidator ID="HoraEntr" runat="server" ControlToValidate="HORAENTRADA"
                            ErrorMessage="*" SetFocusOnError="True" ValidationExpression="^((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))$|^([01]\d|2[0-3]) "></asp:RegularExpressionValidator></td>
                    <td align="left" height="1" style="text-align: right">
                        <asp:Label ID="Label3" runat="server" Font-Bold="True" ForeColor="#336677" Text="Operador Bascula" Width="134px"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:TextBox ID="OPERADORBASCULA" runat="server" EnableTheming="True" Width="186px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label7" runat="server" Font-Bold="True" ForeColor="#336677" Text="Hora Salida"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="HORASALIDA" runat="server" EnableTheming="True" Width="65px"></asp:TextBox>
                        <asp:Label ID="Label2" runat="server" Font-Size="0.65em" ForeColor="Silver" Text="(HH:MM AM/PM)" Width="113px"></asp:Label></td>
                    <td align="left" height="1" style="width: 20px">
                        <asp:RegularExpressionValidator ID="HoraSal" runat="server" ControlToValidate="HORASALIDA"
                            ErrorMessage="*" SetFocusOnError="True" ValidationExpression="^((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))$|^([01]\d|2[0-3]) "></asp:RegularExpressionValidator></td>
                    <td align="left" height="1" style="text-align: right">
                        <asp:Label ID="Label15" runat="server" Font-Bold="True" ForeColor="#336677" Text="Recibido Por"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:TextBox ID="RECIBIDOPOR" runat="server" Width="184px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label14" runat="server" Font-Bold="True" ForeColor="#336677" Text="Peso Entrada"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="PESOENTRADA" runat="server" Width="48px">0</asp:TextBox></td>
                    <td align="left" height="1" style="width: 20px">
                    </td>
                    <td align="left" height="1" style="text-align: right">
                        <asp:Label ID="Label11" runat="server" Font-Bold="True" ForeColor="#336677" Text="Despachado Por"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:TextBox ID="DESPACHADOPOR" runat="server" Width="183px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label13" runat="server" Font-Bold="True" ForeColor="#336677" Text="Peso Salida"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="PESOSALIDA" runat="server" Width="48px">0</asp:TextBox></td>
                    <td align="left" height="1" style="width: 20px">
                    </td>
                    <td align="left" height="1" style="text-align: right">
                        <asp:CheckBox ID="Volatil" runat="server" AutoPostBack="True" Font-Bold="True" ForeColor="#336677"
                            Height="13px" OnCheckedChanged="Volatil_CheckedChanged" Text="Volatil" TextAlign="Left" Width="82px" /></td>
                    <td align="left" height="1" style="width: 106px">
                        &nbsp;<asp:CheckBox ID="Escoria" runat="server" AutoPostBack="True" Font-Bold="True" ForeColor="#336677"
                            OnCheckedChanged="Escoria_CheckedChanged" Text="Escoria" TextAlign="Left"
                            Width="75px" /></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label4" runat="server" Font-Bold="True" ForeColor="#336677" Text="Peso Neto"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="PESONETO" runat="server" Width="47px">0</asp:TextBox></td>
                    <td align="left" height="1" style="width: 20px">
                    </td>
                    <td align="left" height="1" style="text-align: right">
                        <asp:CheckBox ID="Patio" runat="server" AutoPostBack="True" Font-Bold="True" ForeColor="#336677"
                            OnCheckedChanged="Patio_CheckedChanged" Text="Patio" TextAlign="Left"
                            Width="72px" /></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:CheckBox ID="Industria" runat="server" AutoPostBack="True" Font-Bold="True"
                            ForeColor="#336677" OnCheckedChanged="Industria_CheckedChanged" Text="Industria"
                            TextAlign="Left" Width="94px" /></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label9" runat="server" Font-Bold="True" ForeColor="#336677" Text="Empresa"></asp:Label></td>
                    <td align="left" colspan="2" height="1" style="text-align: left">
                        <asp:DropDownList ID="Empresa" runat="server" AutoPostBack="True" Width="210px">
                        </asp:DropDownList>
                    </td>                        
                    <td>
                        </td>
                        
                    <td align="left" height="1" style="width: 106px">
                        </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="#336677" Text="ReImpresiones Entrada"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="IMPRESIONESENT" runat="server" EnableTheming="True" Width="57px">0</asp:TextBox></td>
                    <td align="left" height="1" style="width: 20px">
                    </td>
                    <td align="left" height="1" style="text-align: right;">
                        <asp:Label ID="Label21" runat="server" Font-Bold="True" ForeColor="#336677" Text="ReImpresiones Salida"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:TextBox ID="IMPRESIONESSAL" runat="server" EnableTheming="True" Width="57px">0</asp:TextBox></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 24px">
                        </td>
                    <td align="left" style="width: 195px; height: 24px">
                        <asp:TextBox ID="CODIGOPRODUCTO" runat="server" EnableTheming="True" Width="84px" Visible="False"></asp:TextBox></td>
                    <td align="left" style="width: 20px; height: 24px">
                    </td>
                    <td align="left" style="width: 106px; height: 24px">
                    </td>
                    <td align="left" style="width: 106px; height: 24px">
                    </td>
                </tr>
                <tr>
                    <td align="center" colspan="2" style="height: 26px">
                        &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                        &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                        &nbsp;<asp:Button ID="BtnActualizar" runat="server" Font-Bold="True" Font-Italic="False"
                            Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677"
                            OnClick="BtnActualizar_Click" Text="Acualizar" />
                    </td>
                    <td align="center" colspan="1" height="1" style="width: 20px">
                        </td>
                    <td align="center" colspan="1" height="1" style="width: 106px">
                    </td>
                    <td align="center" colspan="1" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="center" colspan="4" height="1">
                        <asp:Label ID="mensaje" runat="server"></asp:Label></td>
                    <td align="center" colspan="1" height="1">
                    </td>
                </tr>
            </table>
        </td>
        </tr>
    </table>
    </div>
    </form>
</body>
</html>
