<%@ Page Language="VB" %>

<%@ Register Assembly="CrystalDecisions.Web, Version=10.2.3600.0, Culture=neutral, PublicKeyToken=692fbea5521e1304"
    Namespace="CrystalDecisions.Web" TagPrefix="CR" %>

<%@ import Namespace="System.Data.SqlClient" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="CrystalDecisions.CrystalReports.Engine" %>
<%@ import Namespace="CrystalDecisions.Shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim reporte As ReportDocument
        reporte = New ReportDocument
        Dim DsReportes As New DataSet
        Dim Biblioteca As New Biblioteca
        Dim conn As SqlConnection
        Dim ssql As String = ""
        Dim mensaje As String = ""
        Dim DtAdapter As SqlDataAdapter
        Dim Plano As New ArchivosPlanos
        
        Try
            conn = Biblioteca.Conectar(mensaje)
            ssql = Session("SqlReporte")
            DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DsReportes, Session("NombreDataTable"))
        
            'reporte.
            reporte.Load(Server.MapPath(Session("NombreReporte")), OpenReportMethod.OpenReportByTempCopy)
            reporte.SetDataSource(DsReportes)
            reporte.SetParameterValue("FechaMuestra", Session("Parametro"))
            If Session("NombreReporte") <> "ReciboSal.rpt" And Session("NombreReporte") <> "ReciboSalWeb.rpt" And Session("NombreReporte") <> "ReciboSalWebGeneric.rpt" Then
                reporte.SetParameterValue("Usuario", Session("Usuario"))
            Else
                'PARA VALOR EN LETRAS DE LOS REPORTES DE SALIDA 
                Dim MyDataRow As DataRow
                Dim MyDataColumn As DataColumn
                Dim ValorLetras As New ConvertirEnLetras
                
                For Each MyDataRow In DsReportes.Tables(Session("NombreDataTable")).Rows
                    For Each MyDataColumn In DsReportes.Tables(Session("NombreDataTable")).Columns
                        Select Case MyDataColumn.ColumnName
                            Case "PESONETO"
                                reporte.SetParameterValue("ValorLetras", UCase(ValorLetras.Letras(MyDataRow(MyDataColumn.ColumnName).ToString())) & " KILOGRAMOS")
                        End Select
                    Next MyDataColumn
                Next MyDataRow
                
                'FIN PARA VALOR EN LETRAS DE LOS REPORTES DE SALIDA 
            End If
            If Session("NombreReporte") = "ReporteFactura.rpt" Then
                reporte.SetParameterValue("NombreGerente", Biblioteca.ValorParametro("NOMBRE GERENTE"))
            End If
            'Dim margins As PageMargins
            'margins = reporte.PrintOptions.PageMargins
            '    reporte.PrintToPrinter            
            Me.ContenedorReportes.ReportSource = reporte
            Me.ContenedorReportes.DataBind()
            Me.ContenedorReportes.DisplayGroupTree = False
            'reporte.Dispose()
            Biblioteca.DesConectar(conn)
            
        Catch ex As Exception
            'MsgBox(ex.Message)
            Plano.GeneraArchivoBascula("C:\temp", "ErrorReportes.txt", ex.Message & vbCrLf & ex.InnerException.Message & vbCrLf & ssql)
        End Try
    End Sub
    
    
    
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Generación de Reportes</title>
    <link href="/aspnet_client/System_Web/2_0_50727/CrystalReportWebFormViewer3/css/default.css"
        rel="stylesheet" type="text/css" />
    
</head>
<body>
    <form id="form1" runat="server">
    <div>
        &nbsp;&nbsp;
        <CR:CrystalReportViewer ID="ContenedorReportes" runat="server" AutoDataBind="true" PrintMode="ActiveX"/>
    </div>
    </form>
</body>
</html>
