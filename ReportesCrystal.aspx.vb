
Imports CrystalDecisions.CrystalReports.Engine
Imports CrystalDecisions.Shared
Imports System.Data
Imports System.Data.SqlClient

Partial Class ReportesCrystal2
    Inherits System.Web.UI.Page
    Private reporte As ReportDocument

    Private Sub ConfigureCrystalReports()
        Dim DsReportes As New DataSet
        Dim Biblioteca As New Biblioteca
        Dim conn As SqlConnection
        Dim ssql As String = ""
        Dim mensaje As String = ""
        Dim DtAdapter As SqlDataAdapter
        Dim Plano As New ArchivosPlanos





        Try
            reporte = New ReportDocument


            conn = Biblioteca.Conectar(mensaje)
            ssql = Session("SqlReporte")
            reporte.Load(Server.MapPath(Session("NombreReporte")), OpenReportMethod.OpenReportByTempCopy)
            If Session("NombreReporte") <> "Subtotalesxcooperativa.rpt" Then
                DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
                DtAdapter.Fill(DsReportes, Session("NombreDataTable"))
                reporte.SetDataSource(DsReportes)
            End If



            'reporte.

            If Session("NombreReporte") <> "CrystalReport.rpt" And Session("NombreReporte") <> "Fichas.rpt" Then
                reporte.SetParameterValue("FechaMuestra", Session("Parametro"))
            End If


            If Session("NombreReporte") <> "CrystalReport.rpt" And Session("NombreReporte") <> "ReciboSalOficio.rpt" And Session("NombreReporte") <> "ReciboSal.rpt" And Session("NombreReporte") <> "ReciboSalWeb.rpt" And Session("NombreReporte") <> "ReciboSalWebGeneric.rpt" And Session("NombreReporte") <> "ReciboSalOficio1.rpt" And Session("NombreReporte") <> "ReciboSalWebGeneric1.rpt" Then
                reporte.SetParameterValue("Usuario", Session("Usuario"))
            ElseIf Session("NombreReporte") <> "CrystalReport.rpt" Then
                'PARA VALOR EN LETRAS DE LOS REPORTES DE SALIDA 
                Dim MyDataRow As DataRow
                Dim MyDataColumn As DataColumn
                Dim ValorLetras As New ConvertirEnLetras

                For Each MyDataRow In DsReportes.Tables(Session("NombreDataTable")).Rows
                    For Each MyDataColumn In DsReportes.Tables(Session("NombreDataTable")).Columns
                        Select Case MyDataColumn.ColumnName
                            Case "PESONETO"
                                reporte.SetParameterValue("ValorLetras", UCase(ValorLetras.Letras(MyDataRow(MyDataColumn.ColumnName).ToString())) & " KILOGRAMOS")
                            Case "MUESTRAESP"
                                If MyDataRow(MyDataColumn.ColumnName).ToString() <> "" Then
                                    reporte.SetParameterValue("MensajeMuestraEsp", Biblioteca.ValorParametro("MENSAJE MUESTRA ESPECIAL"))
                                Else
                                    reporte.SetParameterValue("MensajeMuestraEsp", " ")
                                End If
                        End Select
                    Next MyDataColumn
                Next MyDataRow

                'FIN PARA VALOR EN LETRAS DE LOS REPORTES DE SALIDA 
            End If
            If Session("NombreReporte") = "ReporteFactura.rpt" Then
                reporte.SetParameterValue("NombreGerente", Biblioteca.ValorParametro("NOMBRE GERENTE"))
                reporte.SetParameterValue("cargo", Biblioteca.ValorParametro("CARGO"))
            End If

            'Dim margins As PageMargins
            'margins = reporte.PrintOptions.PageMargins
            '    reporte.PrintToPrinter            
            Me.myCrystalReportViewer.ReportSource = reporte
            Me.myCrystalReportViewer.DataBind()
            Me.myCrystalReportViewer.DisplayGroupTree = False

            Biblioteca.DesConectar(conn)

        Catch ex As Exception
            Plano.GeneraArchivoBascula("C:\temp", "ErrorReportes.txt", ex.Message & vbCrLf & ssql & ex.ToString())
            Me.Mensaje.Text = ex.Message
        End Try
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ConfigureCrystalReports()
    End Sub

    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        reporte.Close()
    End Sub
End Class
