<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="ReImpresión de Entregas" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.mensaje.Text = ""
        
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        
        If Not Page.IsPostBack Then
            CargarInicio
        End If
    End Sub

private Sub CargarInicio
    Dim BIBLIOTECA As New Biblioteca
    Dim conn As SqlConnection
    Dim DtAdapter As SqlDataAdapter
    Dim DtSet As DataSet
    Dim HoraFiltro As DateTime = DateTime.Now
    Dim ReimpresionesPermitidas As Integer
    Dim ssql As String
    Dim Mensaje As String = ""    
        
        ReimpresionesPermitidas = BIBLIOTECA.ValorParametro("REIMPRESIONES")
            
            Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            Mensaje = ""
            HoraFiltro = HoraFiltro.AddHours(-1)
            HoraFiltro = HoraFiltro
            conn = BIBLIOTECA.Conectar(Mensaje)
            ssql = " SELECT     NUMEROENTRADA" & _
                   " FROM ENTREGAS" & _
                   " WHERE FECHAENTREGA = CONVERT(DATETIME, '" & Format(Today, "yyyy-MM-dd 00:00:00") & "', 102) AND HORAENTREGA > CONVERT(DATETIME, '" & Replace(Format(HoraFiltro, " hh:mm:00 tt"), ".", "") & "', 102) AND IMPRESIONESENT<= " & ReimpresionesPermitidas & "" & _
                   " UNION " & _
                   " SELECT '..' AS NUMEROENTRADA1" & _
                   " FROM ENTREGAS AS ENTREGAS_1"
            
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "ENTREGAS")
            'Combo1 Entradas
            Me.NENTRADA.DataSource = DtSet.Tables("ENTREGAS").DefaultView
            Me.NENTRADA.DataTextField = "NUMEROENTRADA"
            ' Asigna el valor del value en el DropDownList
            Me.NENTRADA.DataValueField = "NUMEROENTRADA"
            Me.NENTRADA.DataBind()
            'CARGAR Salidas
            
            ssql = " SELECT     NUMEROENTRADA" & _
                   " FROM ENTREGAS" & _
                   " WHERE FECHAENTREGA = CONVERT(DATETIME, '" & Format(Today, "yyyy-MM-dd 00:00:00") & "', 102) AND HORASALIDA > CONVERT(DATETIME, '" & Replace(Format(HoraFiltro, " hh:mm:00 tt"), ".", "") & "', 102) AND IMPRESIONESSAL<= " & ReimpresionesPermitidas & "" & _
                   " UNION " & _
                   " SELECT '..' AS NUMEROENTRADA1" & _
                   " FROM ENTREGAS AS ENTREGAS_1"
            
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
           
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "SALIDAS")
            'Combo1 Entradas
            Me.NSalida.DataSource = DtSet.Tables("SALIDAS").DefaultView
            Me.NSalida.DataTextField = "NUMEROENTRADA"
            ' Asigna el valor del value en el DropDownList
            Me.NSalida.DataValueField = "NUMEROENTRADA"
            Me.NSalida.DataBind()
            
            BIBLIOTECA.DesConectar(conn)
end sub

    Protected Sub Entrega_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Seguridad As New Seguridad
        Dim Mensaje As String = ""
        
        ''Imprimir        
        
        Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE ENTRADA")
        
        ssql = "SELECT     ENTREGAS.NUMEROENTRADA, ENTREGAS.PESOENTRADA, ENTREGAS.FECHAENTREGA, ENTREGAS.OPERARIOBASCULA, " & _
                      " ENTREGAS.OBSERVACION_ETR, MUNICIPIOS.NOMBRE AS MUNICIPIO, MINAS.DESCRIPCION AS MINA, " & _
                      " COOPERATIVAS.DESCRIPCION AS COOPERATIVA, ENTREGAS.CONDUCTOR, ENTREGAS.CAMION, ENTREGAS.MUESTRAGEN, PESOSALIDA, PESONETO, OBSERVACION_SAL, HORAENTREGA, HORASALIDA, IMPRESIONESENT" & _
               " FROM   ENTREGAS LEFT OUTER JOIN MUNICIPIOS ON ENTREGAS.MUNICIPIO = MUNICIPIOS.NUMERO LEFT OUTER JOIN " & _
                      " MINAS ON ENTREGAS.MINA = MINAS.NUMERO LEFT OUTER JOIN COOPERATIVAS ON ENTREGAS.COOPERATIVA = COOPERATIVAS.NUMERO" & _
               " WHERE ENTREGAS.NUMEROENTRADA = '" & Me.NENTRADA.Text & "'"
        
        
        'Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("Parametro") = Today
        Session("NombreDataTable") = "Entregas"
        
        ssql = "UPDATE ENTREGAS " & _
               " SET IMPRESIONESENT = IMPRESIONESENT + 1 " & _
               " WHERE ENTREGAS.NUMEROENTRADA = '" & Me.NENTRADA.Text & "'"               
        Biblioteca.EjecutarSql(Mensaje, ssql)
        Seguridad.RegistroAuditoria(Session("Usuario"), "ReImprimir", "ReImprimir", "Entrega:" & Me.NENTRADA.Text & ";EsDeEntrada?:SI", Session("GRUPOUS"))
        
        CargarInicio
        'Fin Imprimir

    End Sub

    Protected Sub Salida_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Seguridad As New Seguridad
        Dim Mensaje As String = ""
        
        ''Imprimir        
        
        Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE SALIDA")
        
        ssql = "SELECT     ENTREGAS.NUMEROENTRADA, ENTREGAS.PESOENTRADA, ENTREGAS.FECHAENTREGA, ENTREGAS.OPERARIOBASCULA, " & _
                      " ENTREGAS.OBSERVACION_ETR, MUNICIPIOS.NOMBRE AS MUNICIPIO, MINAS.DESCRIPCION AS MINA, " & _
                      " COOPERATIVAS.DESCRIPCION AS COOPERATIVA, ENTREGAS.CONDUCTOR, ENTREGAS.CAMION, ENTREGAS.MUESTRAGEN, PESOSALIDA, PESONETO, OBSERVACION_SAL, HORAENTREGA, HORASALIDA, IMPRESIONESSAL, COALESCE(MUESTRAESP,'') AS MUESTRAESP " & _
               " FROM   ENTREGAS LEFT OUTER JOIN MUNICIPIOS ON ENTREGAS.MUNICIPIO = MUNICIPIOS.NUMERO LEFT OUTER JOIN " & _
                      " MINAS ON ENTREGAS.MINA = MINAS.NUMERO LEFT OUTER JOIN COOPERATIVAS ON ENTREGAS.COOPERATIVA = COOPERATIVAS.NUMERO" & _
               " WHERE ENTREGAS.NUMEROENTRADA = '" & Me.NSalida.Text & "'"
               
        'Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("Parametro") = Today
        Session("NombreDataTable") = "Entregas"
        
        ssql = "UPDATE ENTREGAS " & _
               " SET IMPRESIONESSAL = IMPRESIONESSAL + 1 " & _
               " WHERE ENTREGAS.NUMEROENTRADA = '" & Me.NSalida.Text & "'"
        Biblioteca.EjecutarSql(Mensaje, ssql)
        Seguridad.RegistroAuditoria(Session("Usuario"), "ReImprimir", "ReImprimir", "Entrega:" & Me.NENTRADA.Text & ";EsDeEntrada?:NO", Session("GRUPOUS"))
        CargarInicio
        'Fin Imprimir

    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
        <table>
            <tr>
                <td align="right" style="width: 101px; height: 13px">
                </td>
                <td style="width: 166px; height: 13px">
                </td>
                <td height="1" style="width: 79px">
                </td>
                <td height="1" style="width: 79px">
                </td>
                <td height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 101px; height: 13px;">
                    <asp:Label ID="Label2" runat="server" ForeColor="#336677" Text="Entradas"></asp:Label></td>
                <td style="width: 166px; height: 13px;">
                    <asp:DropDownList ID="NENTRADA" runat="server" 
                        Width="162px" AutoPostBack="True">
                    </asp:DropDownList></td>
                <td height="1" style="width: 79px">
                    &nbsp;</td>
                <td height="1" style="width: 79px">
                    <asp:Label ID="Label1" runat="server" ForeColor="#336677" Text="Salidas" Width="80px">
                    </asp:Label></td>
                <td height="1" style="width: 79px">
                <asp:DropDownList ID="NSalida" runat="server" 
                        Width="162px" AutoPostBack="True">
                </asp:DropDownList></td>
            </tr>
            <tr>
                <td align="right" style="width: 101px; height: 13px">
                </td>
                <td style="width: 166px; height: 13px">
                </td>
                <td height="1" style="width: 79px">
                </td>
                <td height="1" style="width: 79px">
                </td>
                <td height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 101px; height: 13px">
                </td>
                <td style="width: 166px; height: 13px">
                    <asp:Button ID="Entrada" runat="server" Font-Bold="True" ForeColor="#336677"
                         Text="Entrada" ToolTip="Imprimir Entrega "
                        Width="114px" OnClick="Entrega_Click" /></td>
                <td height="1" style="width: 79px">
                </td>
                <td height="1" style="width: 79px">
                </td>
                <td height="1" style="width: 79px">
                    <asp:Button ID="Salida" runat="server" Font-Bold="True" ForeColor="#336677"
                         Text="Salida" ToolTip="Imprimir Salida"
                        Width="114px" OnClick="Salida_Click"/></td>
            </tr>
            <tr>
                <td align="right" style="text-align: left;" colspan="5">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
            <tr>
                <td align="center" colspan="2" style="height: 26px">
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                    &nbsp;&nbsp;
                    </td>
                <td align="center" colspan="1" height="1" style="width: 79px">
                </td>
                <td align="center" colspan="1" height="1" style="width: 79px">
                </td>
                <td align="center" colspan="1" height="1" style="width: 79px">
                    </td>
            </tr>
        </table>
    </div>    
</asp:Content>