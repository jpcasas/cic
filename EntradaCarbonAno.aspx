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
        If Me.NUMEROENTRADA.Text = "" Then
            'MsgBox("No se puede insertar un número nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un número nulo"
            Exit Sub
        End If
        Select Case Session("ParamBD")
            Case "Actualizar"
                ssql = " UPDATE HISTORICO_ENTREGAS SET HISTORICO_ENTREGAS.FECHAENTREGA ='" & Me.FECHAENTREGA.Text & "',HISTORICO_ENTREGAS.HORAENTREGA ='" & Me.HORAENTREGA.Text & "',HISTORICO_ENTREGAS.HORASALIDA ='" & Me.HORASALIDA.Text & "',HISTORICO_ENTREGAS.NUMEROENTRADA ='" & Me.NUMEROENTRADA.Text & "',HISTORICO_ENTREGAS.MUESTRAGEN ='" & Me.MUESTRAGEN.Text & "',HISTORICO_ENTREGAS.COOPERATIVA ='" & Me.COOPERATIVA.Text & "',HISTORICO_ENTREGAS.CONDUCTOR ='" & Me.CONDUCTOR.Text & "',HISTORICO_ENTREGAS.CAMION ='" & Me.CAMION.Text & "',HISTORICO_ENTREGAS.MUNICIPIO ='" & Me.Municipio.Text & "',HISTORICO_ENTREGAS.MINA ='" & Me.MINA.Text & "',HISTORICO_ENTREGAS.PESOENTRADA ='" & Me.PESOENTRADA.Text & "',HISTORICO_ENTREGAS.PESOSALIDA ='" & Me.PESOSALIDA.Text & "',HISTORICO_ENTREGAS.PESONETO ='" & Me.PESONETO.Text & "',HISTORICO_ENTREGAS.OPERARIOBASCULA ='" & Me.OPERARIOBASCULA.Text & "',HISTORICO_ENTREGAS.ESTADO ='" & Me.ESTADO.Text & "',HISTORICO_ENTREGAS.MUESTRAESP ='" & Me.MUESTRAESP.Text & "'" & _
                       " WHERE HISTORICO_ENTREGAS.FECHAENTREGA = CONVERT(DATETIME, '" & Format(CDate(session("FECHA")), "yyyy-MM-dd 00:00:00") & "', 102) AND HISTORICO_ENTREGAS.NUMEROENTRADA='" & Trim(Session("Entrega")) & "'"
            Case "Eliminar"
                ssql = " DELETE " & _
                       " FROM HISTORICO_ENTREGAS" & _
                       " WHERE HISTORICO_ENTREGAS.FECHAENTREGA = CONVERT(DATETIME, '" & Format(CDate(session("FECHA")), "yyyy-MM-dd 00:00:00") & "', 102) AND HISTORICO_ENTREGAS.NUMEROENTRADA='" & Trim(Session("Entrega")) & "'"
            Case "Insertar"
                ssql = " INSERT INTO HISTORICO_ENTREGAS (FECHAENTREGA, HORAENTREGA, HORASALIDA, NUMEROENTRADA, MUESTRAGEN, COOPERATIVA, CONDUCTOR, CAMION, MUNICIPIO, MINA, PESOENTRADA, PESOSALIDA, PESONETO, OPERARIOBASCULA, ESTADO, MUESTRAESP)" & _
                       " VALUES('" & Me.FECHAENTREGA.Text & "', '" & Me.HORAENTREGA.Text & "', '" & Me.HORASALIDA.Text & "', '" & Me.NUMEROENTRADA.Text & "', '" & Me.MUESTRAGEN.Text & "', '" & Me.COOPERATIVA.Text & "', '" & Me.CONDUCTOR.Text & "', '" & Me.CAMION.Text & "', '" & Me.Municipio.Text & "', '" & Me.MINA.Text & "', '" & Me.PESOENTRADA.Text & "', '" & Me.PESOSALIDA.Text & "', '" & Me.PESONETO.Text & "', '" & Session("USUARIO") & "', '" & Me.ESTADO.Text & "', '" & Me.MUESTRAESP.Text & "')"
        End Select
        
        Mensaje = ""
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            'Cerrar el explorador
            Seguridad.RegistroAuditoria(Session("Usuario"), Session("ParamBD"), "EntregasManualesAño", "Numero:" & Me.NUMEROENTRADA.Text & ";PesoEntrada:" & Me.PESOENTRADA.Text & ";PesoSalida:" & Me.PESOSALIDA.Text & ";PesoNeto:" & Me.PESONETO.Text & ";Muestra:" & Me.MUESTRAGEN.Text, Session("GRUPOUS"))
            ClientScript = "<script> window.close();" & "<" & "/script>"
            Response.Write(ClientScript)
        Else
            
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        
        Me.BtnActualizar.Text = Session("ParamBd")
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
        
        'Cargar Municipio
        ssql = "SELECT NUMERO,NOMBRE FROM MUNICIPIOS"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "MUNICIPIOS")
        'Combo1 Usuarios
        Me.MUNICIPIO.DataSource = DtSet.Tables("MUNICIPIOS").DefaultView
        Me.MUNICIPIO.DataTextField = "NOMBRE"
        ' Asigna el valor del value en el DropDownList
        Me.MUNICIPIO.DataValueField = "NUMERO"
        Me.MUNICIPIO.DataBind()
        'Fin Cargar Municipio              
        if session("ParamBD") <>"Insertar" then               
            ssql = "SELECT * FROM HISTORICO_ENTREGAS WHERE NUMEROENTRADA ='" & Session("ENTREGA") & "'"
            DtReader = BIBLIOTECA.CargarDataReader(Mensaje, ssql, conn)
            If DtReader.Read Then
                Me.FECHAENTREGA.Text = Format(DtReader("FECHAENTREGA"), "dd/MM/yyyy")
                Me.HORAENTREGA.Text = UCase(Replace(Format(DtReader("HORAENTREGA"), "hh:mm tt"), ".", ""))
                Me.HORASALIDA.Text = UCase(Replace(Format(DtReader("HORASALIDA"), "hh:mm tt"), ".", ""))
                Me.NUMEROENTRADA.Text = Trim(DtReader("NUMEROENTRADA"))
                Me.COOPERATIVA.Text = Trim(DtReader("COOPERATIVA"))
                Me.MUESTRAGEN.Text = Trim(DtReader("MUESTRAGEN"))
                Me.MUESTRAESP.Text = Trim(DtReader("MUESTRAESP"))
                Me.CONDUCTOR.Text = Trim(DtReader("CONDUCTOR"))
                Me.CAMION.Text = Trim(DtReader("CAMION"))
                Me.MINA.Text = Trim(DtReader("MINA"))
                Me.Municipio.Text = Trim(DtReader("MUNICIPIO"))
                Me.PESOENTRADA.Text = DtReader("PESOENTRADA")
                Me.PESOSALIDA.Text = DtReader("PESOSALIDA")
                Me.PESONETO.Text = DtReader("PESONETO")
                Me.OPERARIOBASCULA.Text = DtReader("OPERARIOBASCULA")
                Me.ESTADO.Text = DtReader("ESTADO")
            End If        
        end if
            BIBLIOTECA.DesConectar(conn)
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
        <td style="height: 553px">
            <table>
                <tr>
                    <td align="center" colspan="3" height="1" style="color: #000000">
                        <asp:Label ID="Label17" runat="server" Font-Bold="True" ForeColor="#336677" Text="Entrada Carbón Año" Width="179px"></asp:Label></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 13px">
                    </td>
                    <td style="width: 195px; height: 13px">
                    </td>
                    <td height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Entrada"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="FECHAENTREGA" runat="server" Width="68px"></asp:TextBox><asp:Label
                            ID="Label20" runat="server" Font-Size="0.65em" ForeColor="Silver" Text="(DD/MM/YYYY)" Width="82px"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:CompareValidator ID="cvFecha1" runat="server" ControlToValidate="FECHAENTREGA"
                            ErrorMessage="*" Operator="DataTypeCheck" SetFocusOnError="True" Type="Date"
                            Width="7px"></asp:CompareValidator></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label6" runat="server" Font-Bold="True" ForeColor="#336677" Text="Hora Entrada"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="HORAENTREGA" runat="server" EnableTheming="True" Width="66px"></asp:TextBox><asp:Label ID="Label18" runat="server" Font-Size="0.65em" ForeColor="Silver" Text="(HH:MM AM/PM)" Width="113px"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:RegularExpressionValidator ID="HoraEntr" runat="server" ControlToValidate="HORAENTREGA"
                            ErrorMessage="*" SetFocusOnError="True" ValidationExpression="^((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))$|^([01]\d|2[0-3]) "></asp:RegularExpressionValidator></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label7" runat="server" Font-Bold="True" ForeColor="#336677" Text="Hora Salida"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="HORASALIDA" runat="server" EnableTheming="True" Width="65px"></asp:TextBox><asp:Label ID="Label19" runat="server" Font-Size="0.65em" ForeColor="Silver" Text="(HH:MM AM/PM)" Width="113px"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:RegularExpressionValidator ID="HoraSal" runat="server" ControlToValidate="HORASALIDA"
                            ErrorMessage="*" SetFocusOnError="True" ValidationExpression="^((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))$|^([01]\d|2[0-3]) "></asp:RegularExpressionValidator></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label8" runat="server" Font-Bold="True" ForeColor="#336677" Text="Numero Entrada"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="NUMEROENTRADA" runat="server" EnableTheming="True" Width="85px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label9" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cooperativa"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="COOPERATIVA" runat="server" EnableTheming="True" Width="83px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label10" runat="server" Font-Bold="True" ForeColor="#336677" Text="Número Muestra"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="MUESTRAGEN" runat="server" EnableTheming="True" Width="84px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label11" runat="server" Font-Bold="True" ForeColor="#336677" Text="Muestra Especial"></asp:Label></td>
                    <td align="left" style="height: 1px; width: 195px;">
                        <asp:TextBox ID="MUESTRAESP" runat="server" EnableTheming="True" Width="85px"></asp:TextBox></td>
                    <td align="left" style="height: 1px; width: 106px;">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 26px">
                        <asp:Label ID="Label12" runat="server" Font-Bold="True" ForeColor="#336677" Text="Conductor"></asp:Label></td>
                    <td align="left" colspan="2" style="height: 26px">
                        <asp:TextBox ID="CONDUCTOR" runat="server" EnableTheming="True" Width="195px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 26px">
                        <asp:Label ID="Label16" runat="server" Font-Bold="True" ForeColor="#336677" Text="Placas"></asp:Label></td>
                    <td align="left" style="height: 26px; width: 195px;">
                        <asp:TextBox ID="CAMION" runat="server" EnableTheming="True" Width="57px"></asp:TextBox></td>
                    <td align="left" style="height: 26px; width: 106px;">
                        <asp:RegularExpressionValidator ID="RevPlaca" runat="server" ControlToValidate="CAMION"
                            ErrorMessage="Placa no válida" ValidationExpression="\w\w\w\w\w\w" Visible="False"
                            Width="103px"></asp:RegularExpressionValidator></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 26px">
                        <asp:Label ID="Label3" runat="server" Font-Bold="True" ForeColor="#336677" Text="Proveedor"></asp:Label></td>
                    <td align="left" style="height: 26px; width: 195px;">
                        <asp:TextBox ID="MINA" runat="server" EnableTheming="True" Width="70px"></asp:TextBox></td>
                    <td align="left" style="height: 26px; width: 106px;">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label15" runat="server" Font-Bold="True" ForeColor="#336677" Text="Municipio"></asp:Label></td>
                    <td align="left" colspan="2" height="1">
                        <asp:DropDownList ID="Municipio" runat="server" Width="181px">
                        </asp:DropDownList></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label14" runat="server" Font-Bold="True" ForeColor="#336677" Text="Peso Entrada"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="PESOENTRADA" runat="server" Width="48px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label13" runat="server" Font-Bold="True" ForeColor="#336677" Text="Peso Salida"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="PESOSALIDA" runat="server" Width="48px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label4" runat="server" Font-Bold="True" ForeColor="#336677" Text="Peso Neto"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="PESONETO" runat="server" Width="47px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px; height: 24px">
                        <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Usuario"></asp:Label></td>
                    <td align="left" style="width: 195px; height: 24px">
                        <asp:TextBox ID="OPERARIOBASCULA" runat="server" Width="79px" Enabled="False"></asp:TextBox></td>
                    <td align="left" style="width: 106px; height: 24px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="#336677" Text="Estado"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="ESTADO" runat="server" Width="47px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
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
                    <td align="center" colspan="1" height="1" style="width: 106px">
                        <asp:Label ID="mensaje" runat="server"></asp:Label></td>
                </tr>
            </table>
        </td>
        </tr>
    </table>
    </div>
    </form>
</body>
</html>
