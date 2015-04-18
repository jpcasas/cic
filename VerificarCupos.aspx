<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Verificar Cupos Proveedores" %>

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

    Protected Sub Recalcular_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Mensaje As String = ""
        Dim Conn As SqlConnection
        Dim Biblioteca As New Biblioteca
        Dim dtReader As SqlDataReader
        Dim ssql As String
        Dim Seguridad As New Seguridad
        
        Biblioteca.EjecutarSql(Mensaje, "UPDATE ENTREGAS SET MUESTRAESP = '' WHERE (MUESTRAESP IS NULL)")
        'ActualizarPesoNeto
        ssql = "UPDATE ENTREGAS SET ENTREGAS.PESONETO = PESOENTRADA-PESOSALIDA" & _
               " WHERE (ENTREGAS.PESONETO<>[PESOENTRADA]-[PESOSALIDA]) AND (ENTREGAS.HORASALIDA Is Not Null)"
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            ssql = "SELECT     ENTREGAS.MINA, SUM(ENTREGAS.PESONETO) AS TotPesoNeto, MAX(CONVERT(INT, RIGHT(ENTREGAS.NUMEROENTRADA, CHARINDEX('/', " & _
                          "REVERSE(ENTREGAS.NUMEROENTRADA)) - 1))) AS NEntregas, MINAS.ENTREGAS, MINAS.KGS_ACUM " & _
                   " FROM         ENTREGAS INNER JOIN MINAS ON ENTREGAS.MINA = MINAS.NUMERO" & _
                   " GROUP BY ENTREGAS.MINA, MINAS.ENTREGAS, MINAS.KGS_ACUM " & _
                   " HAVING      (SUM(ENTREGAS.PESONETO) <> MINAS.KGS_ACUM) OR (MAX(CONVERT(INT, RIGHT(ENTREGAS.NUMEROENTRADA, " & _
                   " CHARINDEX('/', REVERSE(ENTREGAS.NUMEROENTRADA)) - 1))) <> MINAS.ENTREGAS - 1)" & _
                   " ORDER BY ENTREGAS.MINA "
                
            Conn = Biblioteca.Conectar(Mensaje)
            dtReader = Biblioteca.CargarDataReader(Mensaje, ssql, Conn)
            While dtReader.Read
                ssql = " UPDATE MINAS SET MINAS.ENTREGAS = " & dtReader("NEntregas") + 1 & ", MINAS.KGS_ACUM = " & dtReader("TotPesoNeto") & "" & _
                       " WHERE MINAS.NUMERO='" & dtReader("MINA") & "'"
                If Not Biblioteca.EjecutarSql(Mensaje, ssql) Then
                    Me.mensaje.Text = Me.mensaje.Text & ";" & Mensaje
                End If
            End While
            dtReader.Close()
            
            'Actualizar Muestras            
            ssql = "SELECT     SUM(PESONETO) AS SumaPesoNeto, RTRIM((CASE PATINDEX('%E%', LTRIM(ENTREGAS.MUESTRAESP)) " & _
                   " WHEN 0 THEN ENTREGAS.MUESTRAGEN ELSE ENTREGAS.MUESTRAESP END)) AS Muestra" & _
                   " FROM ENTREGAS " & _
                   " WHERE HORASALIDA Is Not NULL " & _
                   " GROUP BY RTRIM((CASE PATINDEX('%E%', LTRIM(ENTREGAS.MUESTRAESP)) WHEN 0 THEN ENTREGAS.MUESTRAGEN ELSE ENTREGAS.MUESTRAESP END))"
            dtReader = Biblioteca.CargarDataReader(Mensaje, ssql, Conn)

            While dtReader.Read
                ssql = " UPDATE MUESTRAS " & _
                       " SET MUESTRAS.ACUMPESOS = " & dtReader("SumaPesoNeto") & "" & _
                       " WHERE MUESTRAS.NUMERO='" & dtReader("Muestra") & "'"
                If Not Biblioteca.EjecutarSql(Mensaje, ssql) Then
                    Me.mensaje.Text = Me.mensaje.Text & ";" & Mensaje
                End If
            End While
                               
            ssql = " UPDATE MINAS" & _
                   " SET ENTREGAS = 1, KGS_ACUM = 0 " & _
                   " FROM MINAS LEFT OUTER JOIN ENTREGAS ON MINAS.NUMERO = ENTREGAS.MINA" & _
                   " WHERE (ENTREGAS.FECHAENTREGA IS NULL)"
        
            
            If Not Biblioteca.EjecutarSql(Mensaje, ssql) Then
                Me.mensaje.Text = Me.mensaje.Text & ";" & Mensaje
                Me.mensaje.Text = Mensaje
            End If
            
            Biblioteca.DesConectar(Conn)
        Else
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Me.mensaje.Text & ";" & Mensaje
            Me.mensaje.Text = Mensaje
        End If
        If Me.mensaje.Text <> "" Then
            Me.mensaje.Text = Mensaje
        Else
            Me.mensaje.ForeColor = Color.Blue
            Me.mensaje.Text = "Proceso Terminado Exitosamente"
        End If
        
        Seguridad.RegistroAuditoria(Session("Usuario"), "VerificarCupos", "VerificarCupos", "VerificarCupos", Session("GRUPOUS"))
    End Sub

    Protected Sub Cancelar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("Principal.aspx")
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<script language="javascript" type="text/javascript">
// <!CDATA[

function Button1_onclick() {

}

// ]]>
</script>
    
    <div>
        <table>
            <tr>
                <td align="center" style="width: 470px; height: 25px">
                    </td>
            </tr>
            <tr>
                <td align="center" colspan="1" style="width: 470px; height: 22px">
                    <asp:Label ID="Label1" runat="server" BorderColor="Black" BorderWidth="1px"
                        Font-Bold="True" ForeColor="#336677" Text="En este proceso se recalcularán los cupos disponibles de todos los proveedores actuales, con base en los movimientos de entregas del período actual."
                        Width="468px"></asp:Label></td>
            </tr>
            <tr>
                <td align="center" colspan="1" style="width: 470px; height: 1px;">
                    &nbsp;<asp:Button ID="Recalcular" runat="server" Font-Bold="True" ForeColor="#336677" Text="Recalcular " OnClick="Recalcular_Click" />
                    <asp:Button ID="Cancelar" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cancelar" OnClick="Cancelar_Click" />
                    &nbsp;</td>
            </tr>
            <tr>
                <td align="left" style="width: 470px; height: 21px">
                    &nbsp;<asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>    
</asp:Content>