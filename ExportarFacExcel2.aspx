<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Exportar Facturación a Excel" %>

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
            
        Dim ssql As String = ""
        Dim Biblioteca As New Biblioteca
        Dim Mensaje As String = ""
        Dim MensajeFormulas As String = ""
        Dim CadenaWhere As String = ""
        Dim CadenaGroupBy As String = ""
        Dim SsqlTmp As String
        Dim conn As SqlConnection
        Dim DtReader As SqlDataReader
        Dim HUMLIMITPR As Double = 0
        Dim CENLIMITPR As Double = 0
        Dim HUMLIMITES As Double = 0
        Dim CENLIMITES As Double = 0
        Dim CadenaFormula As String
        Dim Seguridad As New Seguridad
        Dim CadenaCoopAudit As String = "" 'Para descripción de la audirotia
        Dim NombreArchivo As String
        Dim ArchivoExcel As New ArchivosExcel
        
        HUMLIMITPR = Val(Biblioteca.ValorParametro("HUMLIMITPR"))
        CENLIMITPR = Val(Biblioteca.ValorParametro("CENLIMITPR"))
        HUMLIMITES = Val(Biblioteca.ValorParametro("HUMLIMITES"))
        CENLIMITES = Val(Biblioteca.ValorParametro("CENLIMITES"))
        
        'Se carga todo el contenido del detalle
                     
        ssql = "SELECT HISTORICO_ENTREGAS.FECHAENTREGA, HISTORICO_ENTREGAS.HORAENTREGA, HISTORICO_ENTREGAS.NUMEROENTRADA, HISTORICO_ENTREGAS.COOPERATIVA, HISTORICO_ENTREGAS.MINA, HISTORICO_ENTREGAS.MUNICIPIO, " & _
                      " HISTORICO_ENTREGAS.CAMION, HISTORICO_ENTREGAS.PESONETO, HISTORICO_MUESTRAS.NUMERO, HISTORICO_ENTREGAS.PESONETO, HISTORICO_MUESTRAS.HUMEDADTOT, " & _
                      " HISTORICO_MUESTRAS.CENIZAS, HISTORICO_MUESTRAS.MATVOLATIL, HISTORICO_MUESTRAS.AZUFRE, " & _
                      " HISTORICO_MUESTRAS.PODERCALORLHV,HISTORICO_MUESTRAS.FACTORB, HISTORICO_ENTREGAS.MUESTRAESP, HISTORICO_MUESTRAS_1.HUMEDADTOT AS HUMEDADTOT1, " & _
                      " HISTORICO_MUESTRAS_1.CENIZAS AS CENIZAS1, HISTORICO_MUESTRAS_1.MATVOLATIL AS MATVOLATIL1, " & _
                      " HISTORICO_MUESTRAS_1.AZUFRE AS AZUFRE1, HISTORICO_MUESTRAS_1.PODERCALORLHV AS PODERCALORLHV1, HISTORICO_MUESTRAS_1.FACTORB AS FACTORB1 " & _
               " FROM         HISTORICO_ENTREGAS LEFT OUTER JOIN " & _
                      " HISTORICO_MUESTRAS ON HISTORICO_ENTREGAS.MUESTRAGEN = HISTORICO_MUESTRAS.NUMERO LEFT OUTER JOIN " & _
                      " HISTORICO_MUESTRAS AS HISTORICO_MUESTRAS_1 ON HISTORICO_ENTREGAS.MUESTRAESP = HISTORICO_MUESTRAS_1.NUMERO " & _
               " WHERE "
        
        'Se valida las fechas        
        CadenaWhere = CadenaWhere & " (HISTORICO_ENTREGAS.FECHAENTREGA " & _
                                    " BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
                                    "     AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        
        ssql = ssql & CadenaWhere
        conn = Biblioteca.Conectar(Mensaje)
        If Biblioteca.EjecutarSql(Mensaje, "DELETE FROM FACTURA_TMPXLS") Then ' Reiniciar la tabla temporal            
            DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
            'Se carga la tabla temporal con las quitando muestras con muestra especial y agregando su propia muestra especial
            While DtReader.Read
                If Trim(DtReader("MUESTRAESP").ToString) <> "" Then
                    SsqlTmp = " INSERT INTO FACTURA_TMPXLS ( FECHAENTREGA, HORAENTREGA, COOPERATIVA, MINA, NUMEROENTRADA, MUNICIPIO, ACUMPESOS, HUMEDADTOT, CENIZAS, MATVOLATIL, AZUFRE, PODERCALORLHV, FACTORB, PESOCORREGIDO, PODERCALORTOT, NUMERO, VALORTOTALPESOS, PRECIO_GCAL, CAMION)" & _
                              " VALUES (CONVERT(DATETIME, '" & Format(CDate(DtReader("FECHAENTREGA")), "yyyy-MM-dd 00:00:00") & "', 102),'" & Replace(Format(CDate(DtReader("HORAENTREGA").ToString), "hh:mm:ss tt"), ".", "") & "', '" & Trim(DtReader("COOPERATIVA")) & "', '" & Trim(DtReader("MINA")) & "', '" & Trim(DtReader("NUMEROENTRADA")) & "', '" & DtReader("MUNICIPIO") & "', " & Replace(DtReader("PESONETO"), ",", ".") & ", " & Replace(DtReader("HUMEDADTOT1"), ",", ".") & ", " & Replace(DtReader("CENIZAS1"), ",", ".") & ", " & Replace(DtReader("MATVOLATIL1"), ",", ".") & ", " & Replace(DtReader("AZUFRE1"), ",", ".") & ", " & Replace(DtReader("PODERCALORLHV1"), ",", ".") & ", " & Replace(DtReader("FACTORB1"), ",", ".") & ", 0, 0, '" & DtReader("MUESTRAESP") & "', 0, 0, '" & DtReader("CAMION") & "')"
                Else
                    SsqlTmp = " INSERT INTO FACTURA_TMPXLS ( FECHAENTREGA, HORAENTREGA, COOPERATIVA, MINA, NUMEROENTRADA, MUNICIPIO, ACUMPESOS, HUMEDADTOT, CENIZAS, MATVOLATIL, AZUFRE, PODERCALORLHV, FACTORB, PESOCORREGIDO, PODERCALORTOT, NUMERO, VALORTOTALPESOS, PRECIO_GCAL, CAMION)" & _
                              " VALUES (CONVERT(DATETIME, '" & Format(CDate(DtReader("FECHAENTREGA")), "yyyy-MM-dd 00:00:00") & "', 102), '" & Replace(Format(CDate(DtReader("HORAENTREGA").ToString), "hh:mm:ss tt"), ".", "") & "', '" & Trim(DtReader("COOPERATIVA")) & "', '" & Trim(DtReader("MINA")) & "', '" & Trim(DtReader("NUMEROENTRADA")) & "', '" & DtReader("MUNICIPIO") & "', " & Replace(DtReader("PESONETO"), ",", ".") & ", " & Replace(DtReader("HUMEDADTOT"), ",", ".") & ", " & Replace(DtReader("CENIZAS"), ",", ".") & ", " & Replace(DtReader("MATVOLATIL"), ",", ".") & ", " & Replace(DtReader("AZUFRE"), ",", ".") & ", " & Replace(DtReader("PODERCALORLHV"), ",", ".") & ", " & Replace(DtReader("FACTORB"), ",", ".") & ", 0, 0, '" & DtReader("NUMERO") & "', 0, 0, '" & DtReader("CAMION") & "')"
                End If
                Biblioteca.EjecutarSql(Mensaje, SsqlTmp)
            End While
            DtReader.Close()
        End If
        '**************************FORMULAS
        
        ssql = "SELECT FORMULAS.NOMBRE, FORMULAS.CONTENIDO, FORMULAS.ORDEN" & _
                               " FROM FORMULAS" & _
                               " ORDER BY FORMULAS.ORDEN"
        'conn = Biblioteca.Conectar(Mensaje)
        DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
        While DtReader.Read

            CadenaFormula = "UPDATE FACTURA_TMPXLS SET FACTURA_TMPXLS." & Trim(DtReader("NOMBRE")) & " = " & Trim(DtReader("CONTENIDO"))
            Biblioteca.EjecutarSql(MensajeFormulas, CadenaFormula)

            If Trim(DtReader("NOMBRE")) = "PESOCORREGIDO" Then
                CadenaFormula = " UPDATE FACTURA_TMPXLS" & _
                                " SET PESOCORREGIDO = 0" & _
                                " WHERE (NUMERO LIKE '%E%') AND (HUMEDADTOT >= " & HUMLIMITES & ") OR (NUMERO LIKE '%E%') AND (CENIZAS >= " & CENLIMITES & ")"
                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)

                CadenaFormula = " UPDATE    FACTURA_TMPXLS" & _
                                " SET PESOCORREGIDO = 0 " & _
                                " WHERE (HUMEDADTOT >= " & HUMLIMITPR & ") OR (CENIZAS >= " & CENLIMITPR & ")"
                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)

                CadenaFormula = "UPDATE FACTURA_TMPXLS SET FACTURA_TMPXLS.PESOCORREGIDO = ROUND(FACTURA_TMPXLS.PESOCORREGIDO,2)"

                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)
            End If
        End While
        'FIN FORMULAS
        ssql = "SELECT     FACTURA_TMPXLS.FECHAENTREGA AS fecha, FACTURA_TMPXLS.CAMION AS placa, FACTURA_TMPXLS.NUMEROENTRADA AS código, " & _
                      " MINAS.DESCRIPCION AS mina, MUNICIPIOS.NOMBRE AS mpio, HISTORICO_ENTREGAS.PESOENTRADA AS pesent, " & _
                      " HISTORICO_ENTREGAS.PESOSALIDA AS pessal, FACTURA_TMPXLS.ACUMPESOS AS peso_bas, FACTURA_TMPXLS.HORAENTREGA AS horaentra, " & _
                      " HISTORICO_ENTREGAS.HORASALIDA AS horasal, FACTURA_TMPXLS.HUMEDADTOT AS humedad, ((100-FACTURA_TMPXLS.HUMEDADTOT)/100)*FACTURA_TMPXLS.CENIZAS AS cenizas, " & _
                      " ((100-FACTURA_TMPXLS.HUMEDADTOT)/100)*FACTURA_TMPXLS.MATVOLATIL AS volatil, ((100-FACTURA_TMPXLS.HUMEDADTOT)/100)*FACTURA_TMPXLS.AZUFRE AS azufre, FACTURA_TMPXLS.PODERCALORLHV AS pcal, " & _
                      " FACTURA_TMPXLS.PESOCORREGIDO AS p_correg, (1.02033 - 0.000042) * POWER(FACTURA_TMP.HUMEDADTOT+ FACTURA_TMP.CENIZAS,2) as FACTORB AS f_b, FACTURA_TMPXLS.PODERCALORTOT AS t_mcal, " & _
                      " rtrim(FACTURA_TMPXLS.NUMERO) AS cod_m" & _
               " FROM      FACTURA_TMPXLS LEFT OUTER JOIN HISTORICO_ENTREGAS ON FACTURA_TMPXLS.FECHAENTREGA = HISTORICO_ENTREGAS.FECHAENTREGA AND " & _
                      "    FACTURA_TMPXLS.NUMEROENTRADA = HISTORICO_ENTREGAS.NUMEROENTRADA LEFT OUTER JOIN MUNICIPIOS ON FACTURA_TMPXLS.MUNICIPIO = MUNICIPIOS.NUMERO LEFT OUTER JOIN" & _
                      "    MINAS ON FACTURA_TMPXLS.MINA = MINAS.NUMERO LEFT OUTER JOIN COOPERATIVAS ON FACTURA_TMPXLS.COOPERATIVA = COOPERATIVAS.NUMERO" & _
               " ORDER BY  FACTURA_TMPXLS.COOPERATIVA,fecha, horaentra"
        
        'NombreArchivo = Server.MapPath("Documentos") & "\DATOS_FINAL_FAC" & Format(Today, "ddMMMyyyy") & ".xls"
        NombreArchivo = Server.MapPath("Documentos") & "\DATOS_FINAL_FAC" & Format(Today, "ddMMMyyyy") & ".csv"
        If File.Exists(NombreArchivo) Then
            File.Delete(NombreArchivo)
        End If
        
       ' ArchivoExcel.ExportarExcel(Mensaje, ssql, NombreArchivo)
       ArchivoExcel.ExportarExcelCsv(Mensaje, ssql, NombreArchivo)
        Seguridad.RegistroAuditoria(Session("Usuario"), "Exportar", "Factura", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text, Session("GRUPOUS"))
        If Mensaje <> "" Then
            Me.mensaje.ForeColor = System.Drawing.Color.Red
            Me.mensaje.Text = Mensaje
        Else
        '    Response.Redirect("Documentos\DATOS_FINAL_FAC" & Format(Today, "ddMMMyyyy") & ".xls", True)
        Response.Redirect("Documentos\DATOS_FINAL_FAC" & Format(Today, "ddMMMyyyy") & ".csv", True)
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
                <td align="right" style="width: 80px; height: 25px">
                    <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Inicial para exportación"
                        Width="234px"></asp:Label></td>
                <td align="left" style="width: 222px; height: 25px">
                    <asp:TextBox ID="FECHAIN" runat="server" Width="96px"></asp:TextBox>
                    <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="FECHAIN"
                        ErrorMessage="*" Operator="DataTypeCheck" SetFocusOnError="True" Type="Date"
                        Width="1px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="right" style="width: 80px; height: 25px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Final" Width="232px"></asp:Label></td>
                <td align="left" style="width: 222px; height: 25px">
                    <asp:TextBox ID="FECHAFIN" runat="server" Width="96px"></asp:TextBox>
                    <asp:CompareValidator ID="cvFecha1" runat="server" ControlToValidate="FECHAFIN" ErrorMessage="*"
                        Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="1px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="right" colspan="1" style="width: 80px; height: 22px">
                    </td>
                <td align="left" colspan="1" style="width: 222px; height: 22px">
                </td>
            </tr>
            <tr>
                <td align="center" colspan="1" height="1" style="width: 80px">
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