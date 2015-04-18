<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Exportar Información a Archivo Excel - DIARIA " %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ import Namespace="System.Drawing" %>
<%@ import Namespace="System.IO" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        If Not Page.IsPostBack Then
            'define el valor para la comparacion
            cvFecha1.ValueToCompare = Today
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

    Protected Sub CrearArchivo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Mensaje As String = ""
        Dim ssql As String
        Dim ArchivoExcel As New ArchivosExcel
        Dim NombreArchivo As String
        Dim Seguridad As New Seguridad
        Dim BIBLIOTECA As New Biblioteca
        
        BIBLIOTECA.EjecutarSql(Mensaje, "UPDATE ENTREGAS SET MUESTRAESP = '' WHERE (MUESTRAESP IS NULL)")
        
        ssql = " SELECT     ENTREGAS.FECHAENTREGA AS fecha, ENTREGAS.CAMION AS placa, ENTREGAS.NUMEROENTRADA AS codigo,COOPERATIVAS.DESCRIPCION AS cooperativa, COOPERATIVAS.NUMERO AS cod_coop , RTRIM(MINAS.DESCRIPCION) AS mina," & _
                    " RTRIM(MUNICIPIOS.NOMBRE) AS mpio, ENTREGAS.PESOENTRADA AS pesent, ENTREGAS.PESOSALIDA AS pessal, " & _
               " ENTREGAS.PESONETO AS peso_bas, ENTREGAS.HORAENTREGA AS horaentra, ENTREGAS.HORASALIDA AS horasal, " & _
               " RTRIM((CASE PATINDEX('%E%', LTRIM(ENTREGAS.MUESTRAESP)) WHEN 0 THEN ENTREGAS.MUESTRAGEN ELSE ENTREGAS.MUESTRAESP END)) AS cod_m,ENTREGAS.OPERARIOBASCULA AS operador, ENTREGAS.TOMADORMUESTRA as [Toma Muestras], ENTREGAS.impresionesent, ENTREGAS.impresionessal" & _
               " FROM         ENTREGAS LEFT OUTER JOIN " & _
                     " COOPERATIVAS ON ENTREGAS.COOPERATIVA = COOPERATIVAS.NUMERO LEFT OUTER JOIN" & _
                     " MUESTRAS ON ENTREGAS.MUESTRAGEN = MUESTRAS.NUMERO LEFT OUTER JOIN" & _
                     " MINAS ON ENTREGAS.MINA = MINAS.NUMERO LEFT OUTER JOIN " & _
                     " MUNICIPIOS ON ENTREGAS.MUNICIPIO = MUNICIPIOS.NUMERO" & _
               " WHERE (ENTREGAS.FECHAENTREGA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME,'" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)) AND (ENTREGAS.HORASALIDA IS NOT NULL)" & _
               " ORDER BY ENTREGAS.COOPERATIVA, CONVERT(INT,RIGHT(ENTREGAS.NUMEROENTRADA, CHARINDEX('/', REVERSE(ENTREGAS.NUMEROENTRADA)) - 1))"
        'NombreArchivo = Server.MapPath("Documentos") & "\DATOS_FINAL_DIARIO" & Format(Today, "ddMMMyyyy") & ".xls"
        NombreArchivo = Server.MapPath("Documentos") & "\DATOS_FINAL_DIARIO" & Format(Today, "ddMMMyyyy") & ".csv"
        If File.Exists(NombreArchivo) Then
            File.Delete(NombreArchivo)
        End If
        'ArchivoExcel.ExportarExcel(Mensaje, ssql, NombreArchivo)
        ArchivoExcel.ExportarExcelCsv(Mensaje, ssql, NombreArchivo)
        Seguridad.RegistroAuditoria(Session("Usuario"), "Exportar", "Diario", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text, Session("GRUPOUS"))
        If Mensaje <> "" Then
            Me.mensaje.ForeColor = System.Drawing.Color.Red
            Me.mensaje.Text = Mensaje
        Else
            'Response.Redirect("Documentos\DATOS_FINAL_DIARIO" & Format(Today, "ddMMMyyyy") & ".xls", True)
            Response.Redirect("Documentos\DATOS_FINAL_DIARIO" & Format(Today, "ddMMMyyyy") & ".csv", True)
        End If
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
        <br />
        <br />
        <table>
            <tr>
                <td align="right" style="width: 84px; height: 25px">
                    <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Inicial para exportación"
                        Width="229px"></asp:Label></td>
                <td align="left" style="width: 222px; height: 25px">
                    <asp:TextBox ID="FECHAIN" runat="server" Width="96px"></asp:TextBox>
                    <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="FECHAIN"
                        ErrorMessage="*" Operator="DataTypeCheck" SetFocusOnError="True" Type="Date"
                        Width="1px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="right" style="width: 84px; height: 25px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Final" Width="228px"></asp:Label></td>
                <td align="left" style="width: 222px; height: 25px">
                    <asp:TextBox ID="FECHAFIN" runat="server" Width="96px"></asp:TextBox>
                    <asp:CompareValidator ID="cvFecha1" runat="server" ControlToValidate="FECHAFIN" ErrorMessage="*"
                        Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="1px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="right" colspan="1" style="width: 84px; height: 22px">
                    </td>
                <td align="left" colspan="1" style="width: 222px; height: 22px">
                </td>
            </tr>
            <tr>
                <td align="right" colspan="1" height="1" style="width: 84px">
                    &nbsp; &nbsp;&nbsp;</td>
                <td align="left" colspan="1" height="1" style="width: 222px">
                    <asp:Button ID="CrearArchivo" runat="server" Font-Bold="True" ForeColor="#336677" Text="Crear Archivo" OnClick="CrearArchivo_Click" Width="106px" />
                    <asp:Button ID="Cancelar" runat="server" Font-Bold="True" ForeColor="#336677" Text="Cancelar" OnClick="Cancelar_Click" /></td>
            </tr>
            <tr>
                <td align="left" colspan="2" style="height: 21px">
                    &nbsp;<asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>    
</asp:Content>