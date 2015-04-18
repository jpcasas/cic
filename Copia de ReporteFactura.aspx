<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="REPORTE PARA FACTURACIÓN MENSUAL" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        If Not Page.IsPostBack Then
            cvFecha1.ValueToCompare = Today
            cvFecha2.ValueToCompare = Today
            Me.FECHAIN.Text = Today
            Me.FECHAFIN.Text = Today
            Call Actualizar()
        End If
        Me.mensaje.Text = ""
    End Sub
    
    Private Sub Actualizar()
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim ssql As String
        Dim Mensaje As String = ""
            
        Mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
        If Mensaje = "" Then
            Response.Redirect("Principal.aspx")
        Else
            CType(Master.FindControl("Label1"), Label).Text = Mensaje
        End If
        Mensaje = ""
        ssql = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT COOPERATIVAS.NUMERO, COOPERATIVAS.DESCRIPCION" & _
               " FROM COOPERATIVAS " & _
               " ORDER BY COOPERATIVAS.NUMERO"
        
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "COOPERATIVAS")
        'llenar datagrid
        Me.COOPERATIVAS.DataSource = DtSet.Tables("COOPERATIVAS").DefaultView
        Me.COOPERATIVAS.DataBind()
        BIBLIOTECA.DesConectar(conn)
    End Sub
       
    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim I As Integer
        Dim LNUMERO As Label
        Dim CIMPRIMIR As CheckBox
            
        Dim ssql As String = ""
        Dim Biblioteca As New Biblioteca
        Dim Mensaje As String = ""
        Dim MensajeFormulas As String = ""
        Dim CadenaWhere As String = ""
        Dim CadenaGroupBy As String = ""
        Dim Periodo As String
        Dim Contador As Integer = 0
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
                                    "     AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)) AND "
            
        CadenaWhere = CadenaWhere & "("
        For I = 0 To COOPERATIVAS.Rows.Count - 1
            Dim row As GridViewRow = COOPERATIVAS.Rows(I)
            LNUMERO = row.FindControl("NUMERO")
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            If CIMPRIMIR.Checked = True Then
                Contador = Contador + 1
                'se definen las cooperativas que se incluiran en el reporte
                CadenaWhere = CadenaWhere & " HISTORICO_ENTREGAS.COOPERATIVA = '" & Trim(LNUMERO.Text) & "' OR"
                CadenaCoopAudit = CadenaCoopAudit & "-" & Trim(LNUMERO.Text)
            End If
        Next
        
        If Contador = 0 Then  'para quitar el AND final
            Me.mensaje.ForeColor = Color.Blue
            Me.mensaje.Text = "Seleccione una cooperativa"
            Exit Sub
        Else
            CadenaWhere = Left(CadenaWhere, Len(CadenaWhere) - 2)
            CadenaWhere = CadenaWhere & ")"
        End If
        
        ssql = ssql & CadenaWhere
        conn = Biblioteca.Conectar(Mensaje)
        If Biblioteca.EjecutarSql(Mensaje, "DELETE FROM FACTURA_TMP") Then ' Reiniciar la tabla temporal            
            DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
            'Se carga la tabla temporal con las quitando muestras con muestra especial y agregando su propia muestra especial
            While DtReader.Read
                If Trim(DtReader("MUESTRAESP").ToString) <> "" Then
                    SsqlTmp = " INSERT INTO FACTURA_TMP ( FECHAENTREGA, HORAENTREGA, COOPERATIVA, MINA, NUMEROENTRADA, MUNICIPIO, ACUMPESOS, HUMEDADTOT, CENIZAS, MATVOLATIL, AZUFRE, PODERCALORLHV, FACTORB, PESOCORREGIDO, PODERCALORTOT, NUMERO, VALORTOTALPESOS, PRECIO_GCAL, CAMION)" & _
                              " VALUES (CONVERT(DATETIME, '" & Format(CDate(DtReader("FECHAENTREGA")), "yyyy-MM-dd 00:00:00") & "', 102),'" & Replace(Format(CDate(DtReader("HORAENTREGA").ToString), "hh:mm:ss tt"), ".", "") & "', '" & Trim(DtReader("COOPERATIVA")) & "', '" & Trim(DtReader("MINA")) & "', '" & Trim(DtReader("NUMEROENTRADA")) & "', '" & DtReader("MUNICIPIO") & "', " & Replace(DtReader("PESONETO"), ",", ".") & ", " & Replace(DtReader("HUMEDADTOT1"), ",", ".") & ", " & Replace(DtReader("CENIZAS1"), ",", ".") & ", " & Replace(DtReader("MATVOLATIL1"), ",", ".") & ", " & Replace(DtReader("AZUFRE1"), ",", ".") & ", " & Replace(DtReader("PODERCALORLHV1"), ",", ".") & ", " & Replace(DtReader("FACTORB1"), ",", ".") & ", 0, 0, '" & DtReader("MUESTRAESP") & "', 0, 0, '" & DtReader("CAMION") & "')"
                Else
                    SsqlTmp = " INSERT INTO FACTURA_TMP ( FECHAENTREGA, HORAENTREGA, COOPERATIVA, MINA, NUMEROENTRADA, MUNICIPIO, ACUMPESOS, HUMEDADTOT, CENIZAS, MATVOLATIL, AZUFRE, PODERCALORLHV, FACTORB, PESOCORREGIDO, PODERCALORTOT, NUMERO, VALORTOTALPESOS, PRECIO_GCAL, CAMION)" & _
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

            CadenaFormula = "UPDATE FACTURA_TMP SET FACTURA_TMP." & Trim(DtReader("NOMBRE")) & " = " & Trim(DtReader("CONTENIDO"))
            Biblioteca.EjecutarSql(MensajeFormulas, CadenaFormula)

            If Trim(DtReader("NOMBRE")) = "PESOCORREGIDO" Then
                CadenaFormula = " UPDATE FACTURA_TMP" & _
                                " SET PESOCORREGIDO = 0" & _
                                " WHERE (NUMERO LIKE '%E%') AND (HUMEDADTOT >= " & HUMLIMITES & ") OR (NUMERO LIKE '%E%') AND (CENIZAS >= " & CENLIMITES & ")"
                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)

                CadenaFormula = " UPDATE    FACTURA_TMP" & _
                                " SET PESOCORREGIDO = 0 " & _
                                " WHERE (HUMEDADTOT >= " & HUMLIMITPR & ") OR (CENIZAS >= " & CENLIMITPR & ")"
                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)

                CadenaFormula = "UPDATE FACTURA_TMP SET FACTURA_TMP.PESOCORREGIDO = ROUND(FACTURA_TMP.PESOCORREGIDO,2)"

                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)
            End If
        End While
        'FIN FORMULAS
        ssql = "SELECT  FACTURA_TMP.COOPERATIVA, FACTURA_TMP.FECHAENTREGA, FACTURA_TMP.HORAENTREGA, FACTURA_TMP.NUMEROENTRADA, FACTURA_TMP.ACUMPESOS, FACTURA_TMP.HUMEDADTOT, " & _
                      " round(((100-FACTURA_TMP.HUMEDADTOT)/100)*FACTURA_TMP.CENIZAS,2) as CENIZAS, round(((100-FACTURA_TMP.HUMEDADTOT)/100)*FACTURA_TMP.MATVOLATIL,2) as MATVOLATIL, round(((100-FACTURA_TMP.HUMEDADTOT)/100)*FACTURA_TMP.AZUFRE,2) as AZUFRE, FACTURA_TMP.PODERCALORLHV, round((1.02033 - 0.000042) * POWER(FACTURA_TMP.HUMEDADTOT+ FACTURA_TMP.CENIZAS,2),2) as FACTORB, " & _
                      " FACTURA_TMP.PESOCORREGIDO, FACTURA_TMP.PODERCALORTOT, FACTURA_TMP.NUMERO, FACTURA_TMP.VALORTOTALPESOS/1000 as VALORTOTALPESOS, " & _
                      " FACTURA_TMP.PRECIO_GCAL, FACTURA_TMP.CAMION, COOPERATIVAS.DESCRIPCION AS NCOOPERATIVA,MINAS.UNIDAD ," & _
                      " MINAS.DESCRIPCION AS MINA , MUNICIPIOS.NOMBRE AS MUNICIPIO" & _
               " FROM FACTURA_TMP LEFT OUTER JOIN MUNICIPIOS ON FACTURA_TMP.MUNICIPIO = MUNICIPIOS.NUMERO LEFT OUTER JOIN " & _
                      " MINAS ON FACTURA_TMP.MINA = MINAS.NUMERO LEFT OUTER JOIN" & _
                      " COOPERATIVAS ON FACTURA_TMP.COOPERATIVA = COOPERATIVAS.NUMERO" & _
                      " ORDER BY FACTURA_TMP.COOPERATIVA, FACTURA_TMP.FECHAENTREGA, FACTURA_TMP.HORAENTREGA"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "ReporteFactura.rpt"
        Session("NombreDataTable") = "FACTURA_TMP"
        Periodo = "PERIODO DEL "
        Periodo = Periodo & Format(CDate(Me.FECHAIN.Text), "dd/MMM/yyyy")
        Session("Parametro") = Periodo & " AL " & Format(CDate(Me.FECHAFIN.Text), "dd/MMM/yyyy")
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Factura", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text & ";Cooperativas:" & CadenaCoopAudit, Session("GRUPOUS"))
        If Mensaje <> "" Then
            Me.mensaje.ForeColor = System.Drawing.Color.Red
            Me.mensaje.Text = Mensaje
        Else
        
        End If
        Biblioteca.DesConectar(conn)
    End Sub
    
    
    
    Private Sub ImprimirExcel()
        
        'para enviar factura a excel
        Dim I As Integer
        Dim LNUMERO As Label
        Dim CIMPRIMIR As CheckBox
            
        Dim ssql As String = ""
        Dim Biblioteca As New Biblioteca
        Dim Mensaje As String = ""
        Dim CadenaWhere As String = ""
        Dim Periodo As String
        Dim Contador As Integer = 0
        
        'Se carga todo el contenido del detalle
        ssql = "SELECT     HISTORICO_ENTREGAS.FECHAENTREGA AS Fecha, HISTORICO_ENTREGAS.CAMION AS Placa, " & _
               "      HISTORICO_ENTREGAS.NUMEROENTRADA AS [Código Entrada], RTRIM(MINAS.DESCRIPCION) AS Mina, RTRIM(MUNICIPIOS.NOMBRE) AS Municipio, " & _
               "      HISTORICO_ENTREGAS.PESONETO AS [Peso Báscula Kg], HISTORICO_MUESTRAS.HUMEDADTOT AS [% Humedad Total], " & _
               "      HISTORICO_MUESTRAS.CENIZAS AS [% Cenizas], HISTORICO_MUESTRAS.MATVOLATIL AS [% Materia Volatil], " & _
               "      HISTORICO_MUESTRAS.AZUFRE AS [% Azufre], HISTORICO_MUESTRAS.PODERCALORLHV AS [Poder Calorifico LHV Kcal/Kg], " & _
               "      ROUND(HISTORICO_ENTREGAS.PESONETO * HISTORICO_MUESTRAS.FACTORB, 2) AS [Peso Corregido Kg], HISTORICO_MUESTRAS.FACTORB, " & _
               "      ROUND(HISTORICO_ENTREGAS.PESONETO * HISTORICO_MUESTRAS.FACTORB * HISTORICO_MUESTRAS.PODERCALORLHV / 1000, 2) AS [Total MCal]," & _
               "      HISTORICO_ENTREGAS.MUESTRAGEN AS [Código Muestra], 3 AS [Unidad 3/4], HISTORICO_ENTREGAS.COOPERATIVA, " & _
               "      COOPERATIVAS.DESCRIPCION " & _
               " FROM HISTORICO_ENTREGAS LEFT OUTER JOIN COOPERATIVAS ON HISTORICO_ENTREGAS.COOPERATIVA = COOPERATIVAS.NUMERO LEFT OUTER JOIN" & _
               "      HISTORICO_MUESTRAS ON HISTORICO_ENTREGAS.MUESTRAGEN = HISTORICO_MUESTRAS.NUMERO LEFT OUTER JOIN MINAS ON HISTORICO_ENTREGAS.MINA = MINAS.NUMERO LEFT OUTER JOIN" & _
               "      MUNICIPIOS ON HISTORICO_ENTREGAS.MUNICIPIO = MUNICIPIOS.NUMERO " & _
               " WHERE "
        'Se valida las fechas
        CadenaWhere = CadenaWhere & " (HISTORICO_ENTREGAS.FECHAENTREGA " & _
                                    " BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
                                    "     AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)) AND "
            
        CadenaWhere = CadenaWhere & "("
        For I = 0 To COOPERATIVAS.Rows.Count - 1
            Dim row As GridViewRow = COOPERATIVAS.Rows(I)
            LNUMERO = row.FindControl("NUMERO")
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            If CIMPRIMIR.Checked = True Then
                Contador = Contador + 1
                'se definen las coopertavas que se incluiran en el reporte
                CadenaWhere = CadenaWhere & " HISTORICO_ENTREGAS.COOPERATIVA = '" & Trim(LNUMERO.Text) & "' OR"
            End If
        Next
        If Contador = 0 Then  'para quitar el AND final
            Me.mensaje.ForeColor = Color.Blue
            Me.mensaje.Text = "Seleccione una cooperativa"
            Exit Sub
        Else
            CadenaWhere = Left(CadenaWhere, Len(CadenaWhere) - 2)
            CadenaWhere = CadenaWhere & ")"
        End If
        ssql = ssql & CadenaWhere & " ORDER BY HISTORICO_ENTREGAS.COOPERATIVA, FECHAENTREGA "
        Session("SqlReporte") = ssql
        'Biblioteca.AbreVentana("Reportes.aspx", Page)
        
        Periodo = Format(CDate(Me.FECHAIN.Text), "dd/MMM/yyyy")
        Periodo = Periodo & " AL " & Format(CDate(Me.FECHAFIN.Text), "dd/MMM/yyyy")
        
        Dim NombreArchivo As String
                
        NombreArchivo = "Factura_" & Format(Date.Now, "ddMMyyyy_hhmms_tt")
        NombreArchivo = Replace(NombreArchivo, ".", "") & ".xls"
        
        '        Dim GenerarFacturaExcel As New GenerarFacturaExcel
        '        GenerarFacturaExcel.GenerarFacturaExcel(Mensaje, ssql, Server.MapPath("Documentos") & "\" & NombreArchivo, Session("Usuario"), False, Session("Contrasena"), Periodo)
        If Mensaje <> "" Then
            Me.mensaje.ForeColor = System.Drawing.Color.Red
            Me.mensaje.Text = Mensaje
        Else
            Response.Redirect("documentos\" & NombreArchivo, True)
        End If
    End Sub

    Protected Sub Todas_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim I As Integer
        Dim CIMPRIMIR As CheckBox
        For I = 0 To COOPERATIVAS.Rows.Count - 1
            Dim row As GridViewRow = COOPERATIVAS.Rows(I)
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            CIMPRIMIR.Checked = True
        Next
    End Sub

    Protected Sub Ninguna_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim I As Integer
        Dim CIMPRIMIR As CheckBox
        For I = 0 To COOPERATIVAS.Rows.Count - 1
            Dim row As GridViewRow = COOPERATIVAS.Rows(I)
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            CIMPRIMIR.Checked = False
        Next
    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
        <table>
            <tr>
                <td align="left" colspan="4" style="height: 27px">
                    <asp:Label ID="Label2F" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Inicial"
                        Width="119px"></asp:Label><asp:TextBox ID="FECHAIN" runat="server"></asp:TextBox><asp:CompareValidator
                            ID="cvFecha1" runat="server" ControlToValidate="FECHAIN" ErrorMessage="Fecha no valida"
                            Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="140px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="left" colspan="4" style="height: 27px">
                    <asp:Label ID="Label1F" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Final"
                        Width="118px"></asp:Label><asp:TextBox ID="FECHAFIN" runat="server"></asp:TextBox><asp:CompareValidator
                            ID="cvFecha2" runat="server" ControlToValidate="FECHAFIN" ErrorMessage="Fecha no valida"
                            Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="140px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="left" colspan="3" style="height: 27px">
                    <asp:Button ID="Todas" runat="server" Text="Todas" Font-Bold="True" Font-Italic="False" ForeColor="#336677" CommandName="Todas" OnClick="Todas_Click"/><asp:Button ID="Ninguna" runat="server" Text="Ninguna" Font-Bold="True" Font-Italic="False" ForeColor="#336677" CommandName="Ninguna" OnClick="Ninguna_Click"/>
                    <asp:Button ID="Imprimir" runat="server" Text="Imprimir" Font-Bold="True" Font-Italic="False" ForeColor="#336677" CommandName="Insertar" OnClick="Imprimir_Click" /></td>
            </tr>
            <tr>
                <td align="left" colspan="3" style="height: 27px">
                    <asp:Label ID="mensaje" runat="server" Width="593px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" colspan="3" style="height: 27px">
                    <asp:GridView ID="COOPERATIVAS" runat="server" BackColor="White" BorderColor="#CCCCCC"
                        BorderStyle="None" BorderWidth="1px" CellPadding="3" Height="140px" Width="483px" AutoGenerateColumns="False">
                        <FooterStyle BackColor="White" ForeColor="#000066" />
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Left" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <Columns>
                            <asp:TemplateField HeaderText="Nombre">
                                <ItemTemplate>
                                    <asp:Label ID="DESCRIPCION" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.DESCRIPCION") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="C&#243;digo">
                                <ItemTemplate>
                                    <asp:Label ID="NUMERO" runat="server" Text='<%# DataBinder.Eval(Container, "DataItem.NUMERO") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Imprimir">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IMPRIMIR" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    &nbsp;
                </td>
            </tr>
        </table>
    </div>    
</asp:Content>