<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="REPORTE PARA CORPOBOYACÁ" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>
<%@ import Namespace="System.IO" %>

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
        ssql = "SELECT MINAS.NUMERO, MINAS.DESCRIPCION" & _
               " FROM MINAS " & _
               " ORDER BY MINAS.NUMERO"
        
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "MINAS")
        'llenar datagrid
        Me.MINAS.DataSource = DtSet.Tables("MINAS").DefaultView
        Me.MINAS.DataBind()
        BIBLIOTECA.DesConectar(conn)
    End Sub
       


    Protected Sub Todas_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim I As Integer
        Dim CIMPRIMIR As CheckBox
        For I = 0 To MINAS.Rows.Count - 1
            Dim row As GridViewRow = MINAS.Rows(I)
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            CIMPRIMIR.Checked = True
        Next
    End Sub

    Protected Sub Ninguna_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim I As Integer
        Dim CIMPRIMIR As CheckBox
        For I = 0 To MINAS.Rows.Count - 1
            Dim row As GridViewRow = MINAS.Rows(I)
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            CIMPRIMIR.Checked = False
        Next
    End Sub
    
    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        GenerarReporte(False)
    End Sub
    
    Protected Sub ImprimirExcel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        GenerarReporte(True)
    End Sub
    
    Private Sub GenerarReporte(ByVal Excel As Boolean)
        Dim I As Integer
        Dim LNUMERO As Label
        Dim CIMPRIMIR As CheckBox
            
        Dim ssql As String = ""
        Dim Biblioteca As New Biblioteca
        Dim Mensaje As String = ""
        Dim CadenaWhere As String = ""
        Dim CadenaGroupBy As String = ""
        Dim Periodo As String
        Dim Contador As Integer = 0
        Dim SsqlTmp As String
        Dim conn As SqlConnection
        Dim DtReader As SqlDataReader
        Dim Seguridad As New Seguridad
        Dim NombreArchivo As String
        Dim ArchivoExcel As New ArchivosExcel
        
        'Se carga todo el contenido del detalle
                     
        ssql = " SELECT HISTORICO_MUESTRAS.NUMERO, HISTORICO_MUESTRAS.ANOCORTE, HISTORICO_MUESTRAS.MESCORTE, HISTORICO_ENTREGAS.NUMEROENTRADA, HISTORICO_ENTREGAS.COOPERATIVA, HISTORICO_ENTREGAS.MINA, HISTORICO_ENTREGAS.MUNICIPIO, HISTORICO_ENTREGAS.PESONETO, HISTORICO_MUESTRAS.HUMEDADTOT, " & _
                      " HISTORICO_MUESTRAS.CENIZAS, HISTORICO_MUESTRAS.MATVOLATIL, HISTORICO_MUESTRAS.AZUFRE, " & _
                      " HISTORICO_MUESTRAS.PODERCALORLHV, HISTORICO_ENTREGAS.MUESTRAESP, HISTORICO_MUESTRAS_1.HUMEDADTOT AS HUMEDADTOT1, " & _
                      " HISTORICO_MUESTRAS_1.CENIZAS AS CENIZAS1, HISTORICO_MUESTRAS_1.MATVOLATIL AS MATVOLATIL1, " & _
                      " HISTORICO_MUESTRAS_1.AZUFRE AS AZUFRE1, HISTORICO_MUESTRAS_1.PODERCALORLHV AS PODERCALORLHV1, " & _
                      " HISTORICO_MUESTRAS_1.ANOCORTE AS ANOCORTE1, HISTORICO_MUESTRAS_1.MESCORTE AS MESCORTE1, HISTORICO_MUESTRAS_1.NUMERO AS NUMERO1, HISTORICO_MUESTRAS.HUMEDADSUP" & _
               " FROM HISTORICO_ENTREGAS LEFT OUTER JOIN " & _
                      " HISTORICO_MUESTRAS ON HISTORICO_ENTREGAS.MUESTRAGEN = HISTORICO_MUESTRAS.NUMERO LEFT OUTER JOIN " & _
                      " HISTORICO_MUESTRAS AS HISTORICO_MUESTRAS_1 ON HISTORICO_ENTREGAS.MUESTRAESP = HISTORICO_MUESTRAS_1.NUMERO " & _
               " WHERE "
        
        'Se valida las fechas        
        CadenaWhere = CadenaWhere & " (HISTORICO_ENTREGAS.FECHAENTREGA " & _
                                    " BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
                                    "     AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)) AND PESONETO > 0 AND "
            
        CadenaWhere = CadenaWhere & "("
        For I = 0 To MINAS.Rows.Count - 1
            Dim row As GridViewRow = MINAS.Rows(I)
            LNUMERO = row.FindControl("NUMERO")
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            If CIMPRIMIR.Checked = True Then
                Contador = Contador + 1
                'se definen las cooperativas que se incluiran en el reporte
                CadenaWhere = CadenaWhere & " HISTORICO_ENTREGAS.MINA = '" & Trim(LNUMERO.Text) & "' OR"
            End If
        Next
        
        If Contador = 0 Then  'para quitar el AND final
            Me.mensaje.ForeColor = Color.Blue
            Me.mensaje.Text = "Seleccione un Proveedor"
            Exit Sub
        Else
            CadenaWhere = Left(CadenaWhere, Len(CadenaWhere) - 2)
            CadenaWhere = CadenaWhere & ")"
        End If
        
        ssql = ssql & CadenaWhere
        
        If Biblioteca.EjecutarSql(Mensaje, "DELETE FROM CORPOBOYACATMP") Then ' Reiniciar la tabla temporal
            conn = Biblioteca.Conectar(Mensaje)
            DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
            'Se carga la tabla temporal con las quitando muestras con muestra especial y agregando su propia muestra especial
            While DtReader.Read
                If Trim(DtReader("MUESTRAESP").ToString) <> "" Then
                    SsqlTmp = " INSERT INTO CORPOBOYACATMP  (NUMERO, ANOCORTE, MESCORTE, NUMEROENTRADA,COOPERATIVA, MINA, MUNICIPIO, PESONETO, HUMEDADTOT, CENIZAS, MATVOLATIL, AZUFRE, PODERCALORLHV,HUMEDADSUP)" & _
                              " VALUES ('" & DtReader("NUMERO1") & "', " & DtReader("ANOCORTE1") & "," & DtReader("MESCORTE1") & ",'" & DtReader("NUMEROENTRADA") & "','" & DtReader("COOPERATIVA") & "','" & DtReader("MINA") & "' , '" & DtReader("MUNICIPIO") & "', " & Replace(DtReader("PESONETO"), ",", ".") & ", " & Replace(DtReader("HUMEDADTOT1"), ",", ".") & ", " & Replace(DtReader("CENIZAS1"), ",", ".") & ", " & Replace(DtReader("MATVOLATIL1"), ",", ".") & " ," & Replace(DtReader("AZUFRE1"), ",", ".") & " , " & Replace(DtReader("PODERCALORLHV1"), ",", ".") & " , " & Replace(DtReader("HUMEDADSUP"), ",", ".") & ")"
                Else
                    SsqlTmp = " INSERT INTO CORPOBOYACATMP  (NUMERO, ANOCORTE, MESCORTE, NUMEROENTRADA,COOPERATIVA, MINA, MUNICIPIO, PESONETO, HUMEDADTOT, CENIZAS, MATVOLATIL, AZUFRE, PODERCALORLHV,HUMEDADSUP)" & _
                              " VALUES ('" & DtReader("NUMERO") & "', " & DtReader("ANOCORTE") & "," & DtReader("MESCORTE") & ",'" & DtReader("NUMEROENTRADA") & "','" & DtReader("COOPERATIVA") & "','" & DtReader("MINA") & "' , '" & DtReader("MUNICIPIO") & "', " & Replace(DtReader("PESONETO"), ",", ".") & ", " & Replace(DtReader("HUMEDADTOT"), ",", ".") & ", " & Replace(DtReader("CENIZAS"), ",", ".") & ", " & Replace(DtReader("MATVOLATIL"), ",", ".") & " ," & Replace(DtReader("AZUFRE"), ",", ".") & " , " & Replace(DtReader("PODERCALORLHV"), ",", ".") & " , " & Replace(DtReader("HUMEDADSUP"), ",", ".") & ")"
                End If
                Biblioteca.EjecutarSql(Mensaje, SsqlTmp)
                if mensaje <>"" then
                    mensaje = mensaje & "Proveedor " & DtReader("MINA")
                end if
            End While
        End If
        
        'Si no presenta errores
        If Mensaje <> "" Then
            Me.mensaje.ForeColor = System.Drawing.Color.Red
            Me.mensaje.Text = Mensaje
        Else
            If Not Excel Then
                ssql = "SELECT     COOPERATIVAS.DESCRIPCION AS COOPERATIVA, CORPOBOYACATMP.MINA, MINAS.DESCRIPCION AS NOMMINA, MUNICIPIOS.NOMBRE AS MUNICIPIO, " & _
                            " SUM(CORPOBOYACATMP.PESONETO) AS PESONETO, ROUND(SUM(CORPOBOYACATMP.HUMEDADTOT) / COUNT(CORPOBOYACATMP.COOPERATIVA),2) AS HUMEDADTOT," & _
                            " ROUND(((100-AVG(CORPOBOYACATMP.HUMEDADSUP))/100)*(SUM(CORPOBOYACATMP.CENIZAS) / COUNT(CORPOBOYACATMP.COOPERATIVA)), 2) AS CENIZAS, " & _
                            " ROUND(((100-AVG(CORPOBOYACATMP.HUMEDADSUP))/100)*(SUM(CORPOBOYACATMP.MATVOLATIL) / COUNT(CORPOBOYACATMP.COOPERATIVA)), 2) AS MATVOLATIL, " & _
                            " ROUND(((100-AVG(CORPOBOYACATMP.HUMEDADSUP))/100)*(SUM(CORPOBOYACATMP.AZUFRE) / COUNT(CORPOBOYACATMP.COOPERATIVA)), 2) AS AZUFRE, " & _
                            " ROUND(SUM(CORPOBOYACATMP.PODERCALORLHV) / COUNT(CORPOBOYACATMP.COOPERATIVA), 2) AS PODERCALORTOT" & _
                        " FROM     CORPOBOYACATMP LEFT OUTER JOIN MUNICIPIOS ON CORPOBOYACATMP.MUNICIPIO = MUNICIPIOS.NUMERO LEFT OUTER JOIN " & _
                            " COOPERATIVAS ON CORPOBOYACATMP.COOPERATIVA = COOPERATIVAS.NUMERO LEFT OUTER JOIN MINAS ON CORPOBOYACATMP.MINA = MINAS.NUMERO " & _
                        " GROUP BY CORPOBOYACATMP.COOPERATIVA, CORPOBOYACATMP.MINA, MINAS.DESCRIPCION, COOPERATIVAS.DESCRIPCION, MUNICIPIOS.NOMBRE " & _
                        " ORDER BY CORPOBOYACATMP.MINA"
                
                Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
                Session("SqlReporte") = ssql
                Session("NombreReporte") = "CorpoBoyaca.rpt"
                Session("NombreDataTable") = "CORPOBOYACA"
                Periodo = "PERIODO DEL "
                Periodo = Periodo & Format(CDate(Me.FECHAIN.Text), "dd/MMM/yyyy")
                Session("Parametro") = Periodo & " AL " & Format(CDate(Me.FECHAFIN.Text), "dd/MMM/yyyy")
                Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "CorpoBoyaca", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text, Session("GRUPOUS"))
            Else
                ssql = "SELECT     COOPERATIVAS.DESCRIPCION AS COOPERATIVA, CORPOBOYACATMP.MINA, MINAS.DESCRIPCION AS NOMMINA, MUNICIPIOS.NOMBRE AS MUNICIPIO, " & _
                            " SUM(CORPOBOYACATMP.PESONETO) AS PESONETO, ROUND(SUM(CORPOBOYACATMP.HUMEDADTOT) / COUNT(CORPOBOYACATMP.COOPERATIVA),2) AS HUMEDADTOT," & _
                            " ROUND(((100-AVG(CORPOBOYACATMP.HUMEDADSUP))/100)*(SUM(CORPOBOYACATMP.CENIZAS) / COUNT(CORPOBOYACATMP.COOPERATIVA)), 2) AS CENIZAS, " & _
                            " ROUND(((100-AVG(CORPOBOYACATMP.HUMEDADSUP))/100)*(SUM(CORPOBOYACATMP.MATVOLATIL) / COUNT(CORPOBOYACATMP.COOPERATIVA)), 2) AS MATVOLATIL, " & _
                            " ROUND(((100-AVG(CORPOBOYACATMP.HUMEDADSUP))/100)*(SUM(CORPOBOYACATMP.AZUFRE) / COUNT(CORPOBOYACATMP.COOPERATIVA)), 2) AS AZUFRE, " & _
                            " ROUND(SUM(CORPOBOYACATMP.PODERCALORLHV) / COUNT(CORPOBOYACATMP.COOPERATIVA), 2) AS PODERCALORTOT" & _
                        " FROM     CORPOBOYACATMP LEFT OUTER JOIN MUNICIPIOS ON CORPOBOYACATMP.MUNICIPIO = MUNICIPIOS.NUMERO LEFT OUTER JOIN " & _
                            " COOPERATIVAS ON CORPOBOYACATMP.COOPERATIVA = COOPERATIVAS.NUMERO LEFT OUTER JOIN MINAS ON CORPOBOYACATMP.MINA = MINAS.NUMERO " & _
                        " GROUP BY CORPOBOYACATMP.COOPERATIVA, CORPOBOYACATMP.MINA, MINAS.DESCRIPCION, COOPERATIVAS.DESCRIPCION, MUNICIPIOS.NOMBRE " & _
                        " ORDER BY CORPOBOYACATMP.MINA"
                
                NombreArchivo = Server.MapPath("Documentos") & "\CORPOBOYACA" & Format(Today, "ddMMMyyyy") & ".csv"
                If File.Exists(NombreArchivo) Then
                    File.Delete(NombreArchivo)
                End If
                ArchivoExcel.ExportarExcelCsv(Mensaje, ssql, NombreArchivo)
                If Mensaje <> "" Then
                    Me.mensaje.ForeColor = System.Drawing.Color.Red
                    Me.mensaje.Text = Mensaje
                Else
                    Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "CorpoBoyacaExcel", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text, Session("GRUPOUS"))
                    Response.Redirect("Documentos\CORPOBOYACA" & Format(Today, "ddMMMyyyy") & ".csv", True)
                End If

            End If
            
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
        <br />
        <table>
            <tr>
                <td align="left" colspan="4" style="height: 27px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Inicial"
                        Width="119px"></asp:Label><asp:TextBox ID="FECHAIN" runat="server"></asp:TextBox><asp:CompareValidator
                            ID="cvFecha1" runat="server" ControlToValidate="FECHAIN" ErrorMessage="Fecha no valida"
                            Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="140px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="left" colspan="4" style="height: 27px">
                    <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="Fecha Final"
                        Width="118px"></asp:Label><asp:TextBox ID="FECHAFIN" runat="server"></asp:TextBox><asp:CompareValidator
                            ID="cvFecha2" runat="server" ControlToValidate="FECHAFIN" ErrorMessage="Fecha no valida"
                            Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="140px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="left" colspan="3" style="height: 27px">
                    <asp:Button ID="Todas" runat="server" Text="Todas" Font-Bold="True" Font-Italic="False" ForeColor="#336677" CommandName="Todas" OnClick="Todas_Click"/><asp:Button ID="Ninguna" runat="server" Text="Ninguna" Font-Bold="True" Font-Italic="False" ForeColor="#336677" CommandName="Ninguna" OnClick="Ninguna_Click"/>
                    <asp:Button ID="Imprimir" runat="server" Text="Imprimir" Font-Bold="True" Font-Italic="False" ForeColor="#336677" CommandName="Insertar" OnClick="Imprimir_Click" />
                    <asp:Button ID="ImprimirExcel" runat="server" Text="Excel" Font-Bold="True" Font-Italic="False" ForeColor="#336677" CommandName="Insertar" OnClick="ImprimirExcel_Click" /></td>
            </tr>
            <tr>
                <td align="left" colspan="3" style="height: 27px">
                    <asp:Label ID="mensaje" runat="server" Width="593px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" colspan="3" style="height: 27px">
                    <asp:GridView ID="MINAS" runat="server" BackColor="White" BorderColor="#CCCCCC"
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