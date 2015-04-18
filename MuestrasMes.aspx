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
        If Me.ACUMPESOS.Text = "" Then
            'MsgBox("No se puede insertar un número nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un número nulo"
            Exit Sub
        End If
        Select Case Session("ParamBD")
            Case "Actualizar"
                ssql = " UPDATE MUESTRAS SET MUESTRAS.NUMERO ='" & Me.NUMERO.Text & "',MUESTRAS.FECHAMUESTRA =CONVERT(DATETIME, '" & Format(CDate(Me.FECHAMUESTRA.Text), "yyyy-MM-dd 00:00:00") & "', 102),MUESTRAS.COOPERATIVA ='" & Me.COOPERATIVA.Text & "',MUESTRAS.ESTADO ='" & Me.ESTADO.Text & "',MUESTRAS.ACUMPESOS ='" & Replace(Me.ACUMPESOS.Text, ",", ".") & "',MUESTRAS.ENTREGA ='" & Me.ENTREGA.Text & "'" & _
                       " WHERE MUESTRAS.NUMERO='" & Trim(Session("MUESTRA")) & "' AND MUESTRAS.ENTREGA='" & Trim(Session("Entrega")) & "'"
            Case "Eliminar"
                ssql = " DELETE " & _
                       " FROM MUESTRAS" & _
                       " WHERE MUESTRAS.NUMERO='" & Trim(Session("MUESTRA")) & "' AND MUESTRAS.ENTREGA = '" & Trim(Session("ENTREGA")) & "'"
            Case "Insertar"
                ssql = " INSERT INTO MUESTRAS (NUMERO, ENTREGA, COOPERATIVA,FECHAMUESTRA,ACUMPESOS, ESTADO)" & _
                       " VALUES('" & Me.NUMERO.Text & "', '" & Me.ENTREGA.Text & "', '" & Me.COOPERATIVA.Text & "',CONVERT(DATETIME, '" & Format(CDate(Me.FECHAMUESTRA.Text), "yyyy-MM-dd 00:00:00") & "', 102), '" & Replace(Me.ACUMPESOS.Text, ",", ".") & "', '" & Me.ESTADO.Text & "')"
        End Select
        
        Mensaje = ""
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), Session("ParamBD"), "MuestrasManualesMes", "Numero:" & Me.NUMERO.Text & ";Entrega:" & Me.ENTREGA.Text & ";Coop:" & Me.COOPERATIVA.Text & ";AcumPesos:" & Me.ACUMPESOS.Text, Session("GRUPOUS"))
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
                
        Mensaje = ""
        If Session("parambd") <> "Insertar" Then
            conn = BIBLIOTECA.Conectar(Mensaje)
            ssql = " SELECT * FROM MUESTRAS " & _
                   " WHERE NUMERO ='" & TRIM(Session("MUESTRA")) & "' AND ENTREGA='"& TRIM(SESSION("Entrega")) &"'"
            DtReader = BIBLIOTECA.CargarDataReader(Mensaje, ssql, conn)
            If DtReader.Read Then
                Me.NUMERO.Text = DtReader("NUMERO")
                Me.ENTREGA.Text = DtReader("ENTREGA")
                Me.FECHAMUESTRA.Text = Format(DtReader("FECHAMUESTRA"), "dd/MM/yyyy")
                Me.COOPERATIVA.Text = DtReader("COOPERATIVA")
                Me.ESTADO.Text = DtReader("ESTADO")
                Me.ACUMPESOS.Text = DtReader("ACUMPESOS")
            End If
            BIBLIOTECA.DesConectar(conn)
        End If
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Tabla Muestras Mes</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <table style="border-right: #cccccc thin double; padding-right: 1px; border-top: #cccccc thin double; padding-left: 1px; padding-bottom: 1px; border-left: #cccccc thin double; padding-top: 1px; border-bottom: #cccccc thin double"> <!-- TABLA USADA COMO MARCO DEL FORMULARIO-->
        <tr>
        <td style="height: 200px" valign="top">
            <table>
                <tr>
                    <td align="center" colspan="3" height="1" style="color: #000000">
                        <asp:Label ID="Label17" runat="server" Font-Bold="True" ForeColor="#336677" Text="Tabla Muestras Mes" Width="179px"></asp:Label></td>
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
                        <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cód Muestra"></asp:Label></td>
                    <td align="left" style="width: 195px">
                        <asp:TextBox ID="NUMERO" runat="server" Width="151px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                        </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Nro Entrega"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="ENTREGA" runat="server" EnableTheming="True" Width="150px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label6" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Muestra"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="FECHAMUESTRA" runat="server" EnableTheming="True" Width="86px"></asp:TextBox><asp:Label
                            ID="Label20" runat="server" Font-Size="0.65em" ForeColor="Silver" Text="(DD/MM/YYYY)"
                            Width="82px"></asp:Label></td>
                    <td align="left" height="1" style="width: 106px">
                        <asp:CompareValidator ID="cvFecha1" runat="server" ControlToValidate="FECHAMUESTRA"
                            ErrorMessage="*" Operator="DataTypeCheck" SetFocusOnError="True" Type="Date"
                            Width="7px"></asp:CompareValidator></td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label7" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cooperativa"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="COOPERATIVA" runat="server" EnableTheming="True" Width="98px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                        </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label8" runat="server" Font-Bold="True" ForeColor="#336677" Text="Peso Acumulado"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        <asp:TextBox ID="ACUMPESOS" runat="server" EnableTheming="True" Width="100px"></asp:TextBox></td>
                    <td align="left" height="1" style="width: 106px">
                    </td>
                </tr>
                <tr>
                    <td align="right" style="width: 167px">
                        <asp:Label ID="Label9" runat="server" Font-Bold="True" ForeColor="#336677" Text="Estado"></asp:Label></td>
                    <td align="left" height="1" style="width: 195px">
                        &nbsp;<asp:TextBox ID="ESTADO" runat="server" EnableTheming="True" Width="65px"></asp:TextBox></td>
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
                        </td>
                </tr>
                <tr>
                    <td align="center" colspan="3" height="1">
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
