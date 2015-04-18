<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="REPORTE CARBÓN SUMINISTRADO VS. CALOR" %>

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
        'Me.MINAS.DataSource = DtSet.Tables("COOPERATIVAS").DefaultView
        'Me.MINAS.DataBind()
        BIBLIOTECA.DesConectar(conn)
    End Sub
       
    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim I As Integer
        Dim LNUMERO As System.Web.UI.WebControls.DataControlFieldCell
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
        
        HUMLIMITPR = Val(Biblioteca.ValorParametro("HUMLIMITPR"))
        CENLIMITPR = Val(Biblioteca.ValorParametro("CENLIMITPR"))
        HUMLIMITES = Val(Biblioteca.ValorParametro("HUMLIMITES"))
        CENLIMITES = Val(Biblioteca.ValorParametro("CENLIMITES"))
        
        'Se carga todo el contenido del detalle
        ', HISTORICO_MUESTRAS.HUMEDADSUP " & _          
        ssql = "SELECT HISTORICO_ENTREGAS.NUMEROENTRADA, HISTORICO_ENTREGAS.COOPERATIVA, HISTORICO_ENTREGAS.MINA, HISTORICO_ENTREGAS.MUNICIPIO, HISTORICO_ENTREGAS.PESONETO, HISTORICO_MUESTRAS.HUMEDADTOT, " & _
                      " HISTORICO_MUESTRAS.CENIZAS, HISTORICO_MUESTRAS.MATVOLATIL, HISTORICO_MUESTRAS.AZUFRE, " & _
                      " HISTORICO_MUESTRAS.PODERCALORLHV,HISTORICO_MUESTRAS.FACTORB, HISTORICO_ENTREGAS.MUESTRAESP, HISTORICO_MUESTRAS_1.HUMEDADTOT AS HUMEDADTOT1, " & _
                      " HISTORICO_MUESTRAS_1.CENIZAS AS CENIZAS1, HISTORICO_MUESTRAS_1.MATVOLATIL AS MATVOLATIL1, " & _
                      " HISTORICO_MUESTRAS_1.AZUFRE AS AZUFRE1, HISTORICO_MUESTRAS_1.PODERCALORLHV AS PODERCALORLHV1, HISTORICO_MUESTRAS_1.FACTORB AS FACTORB1" & _
               " FROM         HISTORICO_ENTREGAS LEFT OUTER JOIN " & _
                      " HISTORICO_MUESTRAS ON HISTORICO_ENTREGAS.MUESTRAGEN = HISTORICO_MUESTRAS.NUMERO LEFT OUTER JOIN " & _
                      " HISTORICO_MUESTRAS AS HISTORICO_MUESTRAS_1 ON HISTORICO_ENTREGAS.MUESTRAESP = HISTORICO_MUESTRAS_1.NUMERO " & _
               " WHERE "
        
        'Se valida las fechas        
        CadenaWhere = CadenaWhere & " (HISTORICO_ENTREGAS.FECHAENTREGA " & _
                                    " BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) " & _
                                    "     AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)) AND "
            
        CadenaWhere = CadenaWhere & "("
        
        
        
        
        
        
        For I = 0 To GridView1.Rows.Count - 1
            Dim row As GridViewRow = GridView1.Rows(I)
            LNUMERO = CType(row.Controls(0), System.Web.UI.WebControls.DataControlFieldCell)
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            If CIMPRIMIR.Checked = True Then
                Contador = Contador + 1
                'se definen las cooperativas que se incluiran en el reporte
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
        
        ssql = ssql & CadenaWhere
        conn = Biblioteca.Conectar(Mensaje)
        If Biblioteca.EjecutarSql(Mensaje, "DELETE FROM CARBON_VS_CALORTMP") Then ' Reiniciar la tabla temporal            
            DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
            'Se carga la tabla temporal con las quitando muestras con muestra especial y agregando su propia muestra especial
            While DtReader.Read
                If Trim(DtReader("MUESTRAESP").ToString) <> "" Then
                    SsqlTmp = " INSERT INTO CARBON_VS_CALORTMP  (NUMEROENTRADA,COOPERATIVA, MINA, MUNICIPIO, ACUMPESOS, HUMEDADTOT, CENIZAS, MATVOLATIL, AZUFRE, PODERCALORLHV, FACTORB, NUMERO)" & _
                              " VALUES ('" & DtReader("NUMEROENTRADA") & "','" & DtReader("COOPERATIVA") & "','" & DtReader("MINA") & "' , '" & DtReader("MUNICIPIO") & "', " & Replace(DtReader("PESONETO"), ",", ".") & ", " & Replace(DtReader("HUMEDADTOT1"), ",", ".") & ", " & Replace(DtReader("CENIZAS1"), ",", ".") & ", " & Replace(DtReader("MATVOLATIL1"), ",", ".") & " ," & Replace(DtReader("AZUFRE1"), ",", ".") & " , " & Replace(DtReader("PODERCALORLHV1"), ",", ".") & "," & Replace(DtReader("FACTORB1"), ",", ".") & ",'" & DtReader("MUESTRAESP") & "')" ' & Replace(DtReader("HUMEDADSUP"), ",", ".") & ")"
                Else
                    SsqlTmp = " INSERT INTO CARBON_VS_CALORTMP  (NUMEROENTRADA,COOPERATIVA, MINA, MUNICIPIO, ACUMPESOS, HUMEDADTOT, CENIZAS, MATVOLATIL, AZUFRE, PODERCALORLHV,FACTORB)" & _
                              " VALUES ('" & DtReader("NUMEROENTRADA") & "','" & DtReader("COOPERATIVA") & "','" & DtReader("MINA") & "' , '" & DtReader("MUNICIPIO") & "', " & Replace(DtReader("PESONETO"), ",", ".") & ", " & Replace(DtReader("HUMEDADTOT"), ",", ".") & ", " & Replace(DtReader("CENIZAS"), ",", ".") & ", " & Replace(DtReader("MATVOLATIL"), ",", ".") & " ," & Replace(DtReader("AZUFRE"), ",", ".") & " , " & Replace(DtReader("PODERCALORLHV"), ",", ".") & "," & Replace(DtReader("FACTORB"), ",", ".") & ")" ', " & Replace(DtReader("HUMEDADSUP"), ",", ".") & ")"
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

            CadenaFormula = "UPDATE CARBON_VS_CALORTMP SET CARBON_VS_CALORTMP." & Trim(DtReader("NOMBRE")) & " = " & Trim(DtReader("CONTENIDO"))
            Biblioteca.EjecutarSql(MensajeFormulas, CadenaFormula)

            If Trim(DtReader("NOMBRE")) = "PESOCORREGIDO" Then
                CadenaFormula = " UPDATE CARBON_VS_CALORTMP" & _
                                " SET PESOCORREGIDO = 0" & _
                                " WHERE (NUMERO LIKE '%E%') AND (HUMEDADTOT >= " & HUMLIMITES & ") OR (NUMERO LIKE '%E%') AND (CENIZAS >= " & CENLIMITES & ")"
                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)

                CadenaFormula = " UPDATE    CARBON_VS_CALORTMP" & _
                                " SET PESOCORREGIDO = 0 " & _
                                " WHERE (HUMEDADTOT >= " & HUMLIMITPR & ") OR (CENIZAS >= " & CENLIMITPR & ")"
                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)

                CadenaFormula = "UPDATE CARBON_VS_CALORTMP SET CARBON_VS_CALORTMP.PESOCORREGIDO = ROUND(CARBON_VS_CALORTMP.PESOCORREGIDO,2)"

                Biblioteca.EjecutarSql(Mensaje, CadenaFormula)
            End If
        End While
        'FIN FORMULAS
        ssql = "SELECT     COOPERATIVAS.DESCRIPCION AS COOPERATIVA, CARBON_VS_CALORTMP.COOPERATIVA AS CODIGO, " & _
                  " SUM(CARBON_VS_CALORTMP.ACUMPESOS)/1000 AS PESONETOTON, " & _
                  " ROUND(SUM(PODERCALORTOT), 2) AS MCAL, " & _
                  " ROUND(SUM(VALORTOTALPESOS)/1000, 5) AS VALOR " & _
               " FROM         CARBON_VS_CALORTMP LEFT OUTER JOIN COOPERATIVAS ON CARBON_VS_CALORTMP.COOPERATIVA = COOPERATIVAS.NUMERO " & _
               " GROUP BY CARBON_VS_CALORTMP.COOPERATIVA, COOPERATIVAS.DESCRIPCION " & _
               " ORDER BY CODIGO"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "CarbonVsCalor.rpt"
        Session("NombreDataTable") = "CARBONVSCALOR"
        Periodo = "PERIODO DEL "
        Periodo = Periodo & Format(CDate(Me.FECHAIN.Text), "dd/MMM/yyyy")
        Session("Parametro") = Periodo & " AL " & Format(CDate(Me.FECHAFIN.Text), "dd/MMM/yyyy")
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "CarbonVsCalor", "FechaIn:" & Me.FECHAIN.Text & ";FechaFin:" & Me.FECHAFIN.Text, Session("GRUPOUS"))
        
        If Mensaje <> "" Then
            Me.mensaje.ForeColor = System.Drawing.Color.Red
            Me.mensaje.Text = Mensaje
        Else
        
        End If
    End Sub

    Protected Sub Todas_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim I As Integer
        Dim CIMPRIMIR As CheckBox
        For I = 0 To GridView1.Rows.Count - 1
            Dim row As GridViewRow = GridView1.Rows(I)
            CIMPRIMIR = row.FindControl("IMPRIMIR")
            CIMPRIMIR.Checked = True
        Next
    End Sub

    Protected Sub Ninguna_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim I As Integer
        Dim CIMPRIMIR As CheckBox
        For I = 0 To GridView1.Rows.Count - 1
            Dim row As GridViewRow = GridView1.Rows(I)
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
                    </td>
            </tr>
            <tr>
                <td align="left" colspan="3" style="height: 27px">
                    <asp:Label ID="mensaje" runat="server" Width="593px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" colspan="3" style="height: 27px">
                    &nbsp;
                    &nbsp;&nbsp;
                    <asp:GridView ID="GridView1" runat="server" AllowSorting="True" AutoGenerateColumns="False"
                        DataKeyNames="NUMERO" DataSourceID="ObjectDataSource1" CellPadding="4" ForeColor="#333333" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="NUMERO" HeaderText="C&#243;digo" ReadOnly="True" SortExpression="NUMERO" />
                            <asp:BoundField DataField="DESCRIPCION" HeaderText="Nombre" SortExpression="DESCRIPCION" />
                            <asp:TemplateField HeaderText="Imprimir">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IMPRIMIR" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                        <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <EditRowStyle BackColor="#999999" />
                        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                    </asp:GridView>
                    <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" DataObjectTypeName="DataSet1+COOPERATIVASDataTable"
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DataSet1TableAdapters.COOPERATIVASTableAdapter"
                        UpdateMethod="Update"></asp:ObjectDataSource>
                </td>
            </tr>
        </table>
    </div>    
</asp:Content>