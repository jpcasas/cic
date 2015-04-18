<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Entradas Carbón Mes" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim Mensaje As String
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
        If mensaje = "" Then
            Response.Redirect("Principal.aspx")
        Else
            CType(Master.FindControl("Label1"), Label).Text = mensaje
        End If
    End Sub

    Private Sub CargarGridView(ByVal ssql As String)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim Mensaje As String
        
        Mensaje = ""
        Mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
        If Mensaje = "" Then
            Response.Redirect("Principal.aspx")
        Else
            CType(Master.FindControl("Label1"), Label).Text = Mensaje
        End If
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        DtAdapter.Fill(DtSet, "ENTREGAS")
        'llenar datagrid
        Me.MUESTRAS.DataSource = DtSet.Tables("ENTREGAS").DefaultView
        Me.MUESTRAS.DataBind()
        BIBLIOTECA.DesConectar(conn)
    End Sub
    
    Protected Sub MUESTRAS_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs)
        Dim index As Integer = Convert.ToInt32(e.CommandArgument)
        Dim row As GridViewRow = MUESTRAS.Rows(index)
        'Nombre de Botones = : EntrCarbMes;TblMuestrasMes;AnalisisLabAno;EntrCarbAno;TblMuestrasAno
        Select Case Me.NomBoton.Text
            Case "EntrCarbMes"
                Me.Muestra.Text = ""
                Me.Entrega.Text = Trim(Server.HtmlDecode(row.Cells(2).Text))
                Me.Fecha.Text = ""
            Case "TblMuestrasMes"
                Me.Muestra.Text = Trim(Server.HtmlDecode(row.Cells(1).Text))
                Me.Entrega.Text = Trim(Server.HtmlDecode(row.Cells(2).Text))
                Me.Fecha.Text = ""
            Case "AnalisisLabAno"
                Me.Muestra.Text = Trim(Server.HtmlDecode(row.Cells(1).Text))
                Me.Entrega.Text = Trim(Server.HtmlDecode(row.Cells(2).Text))
                Me.Fecha.Text = ""
            Case "EntrCarbAno"
                Me.Muestra.Text = Trim(Server.HtmlDecode(row.Cells(2).Text))
                Me.Entrega.Text = Trim(Server.HtmlDecode(row.Cells(1).Text))
                Me.Fecha.Text = ""
            Case "TblMuestrasAno"
                Me.Muestra.Text = Trim(Server.HtmlDecode(row.Cells(1).Text))
                Me.Entrega.Text = Trim(Server.HtmlDecode(row.Cells(2).Text))
                Me.Fecha.Text = ""
            Case Else
                Me.Muestra.Text = ""
                Me.Entrega.Text = ""
                Me.Fecha.Text = ""
        End Select
        'Session("EntregaEditar") = Trim(Server.HtmlDecode(row.Cells(1).Text)) & Server.HtmlDecode(row.Cells(2).Text)
    End Sub

    Protected Sub EntrCarbMes_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim CadenaEntrega As String = ""
        Dim CadenaCooperativa As String = ""
        Dim CadenaMuestra As String = ""
        Dim CadenaFecha As String = ""
        Dim CadenaPlaca As String = ""
        Dim CadenaConductor As String = ""
        Dim CadenaWhere As String = ""
        
        If Me.EntregaIN.Text <> "" And Me.EntregaFIN.Text <> "" Then
            CadenaEntrega = "(NUMEROENTRADA BETWEEN '" & Me.EntregaIN.Text & "' AND '" & Me.EntregaFIN.Text & "')"
        End If
        If Me.CoopIn.Text <> "" And Me.CoopFin.Text <> "" Then
            CadenaCooperativa = "( ENTREGAS.COOPERATIVA BETWEEN  '" & Me.CoopIn.Text & "' AND '" & Me.CoopFin.Text & "')"
        End If
        If Me.MuestraIn.Text <> "" And Me.MuestraFin.Text <> "" Then
            CadenaMuestra = "(MUESTRAGEN BETWEEN  '" & Me.MuestraIn.Text & "' AND '" & Me.MuestraFin.Text & "')"
        End If
        If Me.FechaIn.Text <> "" And Me.FechaFin.Text <> "" Then
            CadenaFecha = "(FECHAENTREGA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FechaIn.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FechaFin.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        End If
        If Me.PlacaIn.Text <> "" And Me.PlacaFin.Text <> "" Then
            CadenaPlaca = " (CAMION BETWEEN '" & Trim(Me.PlacaIn.Text) & "' AND '" & Trim(Me.PlacaFin.Text) & "')"
        End If
        If Me.ConductorIn.Text <> "" And Me.ConductorFin.Text <> "" Then
            CadenaConductor = " CONDUCTOR BETWEEN '" & Me.ConductorIn.Text & "' AND '" & Me.ConductorFin.Text & "'"
        End If
       
        If CadenaEntrega <> "" Then
            CadenaWhere = CadenaEntrega & " AND "
        End If
        If CadenaCooperativa <> "" Then
            CadenaWhere = CadenaWhere & CadenaCooperativa & " AND "
        End If
        If CadenaMuestra <> "" Then
            CadenaWhere = CadenaWhere & CadenaMuestra & " AND "
        End If
        If CadenaFecha <> "" Then
            CadenaWhere = CadenaWhere & CadenaFecha & " AND "
        End If
        If CadenaPlaca <> "" Then
            CadenaWhere = CadenaWhere & CadenaPlaca & " AND "
        End If
        If CadenaConductor <> "" Then
            CadenaWhere = CadenaWhere & CadenaConductor & " AND "
        End If
        
        If CadenaWhere <> "" Then
            CadenaWhere = " WHERE " & Left(CadenaWhere, Len(CadenaWhere) - 4)
        Else
            CadenaWhere = " WHERE NUMEROENTRADA='XXX'"
        End If
        
        ssql = " SELECT RIGHT('0' + LEFT(DAY(FECHAENTREGA), 2), 2) + '/' + RIGHT('0' + LEFT(MONTH(FECHAENTREGA), 2), 2) + '/' + LEFT(YEAR(FECHAENTREGA), 4) AS [Fecha Entrega], " & _
                        " NUMEROENTRADA as [Numero Entrada],  MUESTRAGEN as [Muestra Generada], MUESTRAESP as [Muestra Especial], MINAS.DESCRIPCION as Proveedor, Conductor, " & _
                        " PESONETO as [Peso Neto], CAMION AS [Placa], OPERARIOBASCULA as [Operario Báscula],ENTREGAS.TOMADORMUESTRA as [Toma Muestras], ENTREGAS.Estado " & _
               " FROM ENTREGAS LEFT OUTER JOIN MINAS ON ENTREGAS.MINA = MINAS.NUMERO " & _
               CadenaWhere
        
        CargarGridView(ssql)
        'para títulos Guia
        CType(Master.FindControl("Label1"), Label).Text = CType(Master.FindControl("Label1"), Label).Text & "\" & Me.EntrCarbMes.Text
        Me.MUESTRAS.Caption = Me.EntrCarbMes.Text
        Me.NomBoton.Text = "EntrCarbMes"
    End Sub
    
    Protected Sub TblMuestrasMes_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim CadenaEntrega As String = ""
        Dim CadenaCooperativa As String = ""
        Dim CadenaMuestra As String = ""
        Dim CadenaFecha As String = ""
        Dim CadenaWhere As String = ""
        
        If Me.EntregaIN.Text <> "" And Me.EntregaFIN.Text <> "" Then
            CadenaEntrega = "(ENTREGA BETWEEN '" & Me.EntregaIN.Text & "' AND '" & Me.EntregaFIN.Text & "')"
        End If
        If Me.CoopIn.Text <> "" And Me.CoopFin.Text <> "" Then
            CadenaCooperativa = "( COOPERATIVA BETWEEN  '" & Me.CoopIn.Text & "' AND '" & Me.CoopFin.Text & "')"
        End If
        If Me.MuestraIn.Text <> "" And Me.MuestraFin.Text <> "" Then
            CadenaMuestra = "(NUMERO BETWEEN  '" & Me.MuestraIn.Text & "' AND '" & Me.MuestraFin.Text & "')"
        End If
        If Me.FechaIn.Text <> "" And Me.FechaFin.Text <> "" Then
            CadenaFecha = "(FECHAMUESTRA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FechaIn.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FechaFin.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        End If
       
        If CadenaEntrega <> "" Then
            CadenaWhere = CadenaEntrega & " AND "
        End If
        If CadenaCooperativa <> "" Then
            CadenaWhere = CadenaWhere & CadenaCooperativa & " AND "
        End If
        If CadenaMuestra <> "" Then
            CadenaWhere = CadenaWhere & CadenaMuestra & " AND "
        End If
        If CadenaFecha <> "" Then
            CadenaWhere = CadenaWhere & CadenaFecha & " AND "
        End If
        If CadenaWhere <> "" Then
            CadenaWhere = " WHERE " & Left(CadenaWhere, Len(CadenaWhere) - 4)
        Else
            CadenaWhere = " WHERE ENTREGA='XXX'"
        End If
        
        ssql = " SELECT NUMERO as [Cód Muestra], ENTREGA as [Nro. Entrega], COOPERATIVA as [Cooperativa], ACUMPESOS as [Peso Acumulado], Estado " & _
               " FROM MUESTRAS " & CadenaWhere
        CargarGridView(ssql)
        'para títulos Guia
        CType(Master.FindControl("Label1"), Label).Text = CType(Master.FindControl("Label1"), Label).Text & "\" & Me.TblMuestrasMes.Text
        Me.MUESTRAS.Caption = Me.TblMuestrasMes.Text
        Me.NomBoton.Text = "TblMuestrasMes"
    End Sub

    Protected Sub AnalisisLabAno_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim CadenaEntrega As String = ""
        Dim CadenaCooperativa As String = ""
        Dim CadenaMuestra As String = ""
        Dim CadenaFecha As String = ""
        Dim CadenaWhere As String = ""
        
        If Me.EntregaIN.Text <> "" And Me.EntregaFIN.Text <> "" Then
            CadenaEntrega = "(ENTREGA BETWEEN '" & Me.EntregaIN.Text & "' AND '" & Me.EntregaFIN.Text & "')"
        End If
        If Me.CoopIn.Text <> "" And Me.CoopFin.Text <> "" Then
            CadenaCooperativa = "( HISTORICO_MUESTRAS.COOPERATIVA BETWEEN  '" & Me.CoopIn.Text & "' AND '" & Me.CoopFin.Text & "')"
        End If
        If Me.MuestraIn.Text <> "" And Me.MuestraFin.Text <> "" Then
            CadenaMuestra = "(NUMERO BETWEEN  '" & Me.MuestraIn.Text & "' AND '" & Me.MuestraFin.Text & "')"
        End If
        If Me.FechaIn.Text <> "" And Me.FechaFin.Text <> "" Then
            CadenaFecha = "(FECHAMUESTRA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FechaIn.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FechaFin.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        End If
       
        If CadenaEntrega <> "" Then
            CadenaWhere = CadenaEntrega & " AND "
        End If
        If CadenaCooperativa <> "" Then
            CadenaWhere = CadenaWhere & CadenaCooperativa & " AND "
        End If
        If CadenaMuestra <> "" Then
            CadenaWhere = CadenaWhere & CadenaMuestra & " AND "
        End If
        If CadenaFecha <> "" Then
            CadenaWhere = CadenaWhere & CadenaFecha & " AND "
        End If
        If CadenaWhere <> "" Then
            CadenaWhere = " WHERE " & Left(CadenaWhere, Len(CadenaWhere) - 4)
        Else
            CadenaWhere = " WHERE ENTREGA='XXX'"
        End If
        
        ssql = " SELECT NUMERO as [Cód Muestra], ENTREGA as [N°. Entrega], Cooperativa, RIGHT('0' + LEFT(DAY(FECHAMUESTRA), 2), 2) + '/' + RIGHT('0' + LEFT(MONTH(FECHAMUESTRA), 2), 2) + '/' + LEFT(YEAR(FECHAMUESTRA), 4) AS [Fecha Análisis], Analista, Estado" & _
               " FROM HISTORICO_MUESTRAS " & CadenaWhere
        CargarGridView(ssql)
        'para títulos Guia
        CType(Master.FindControl("Label1"), Label).Text = CType(Master.FindControl("Label1"), Label).Text & "\" & Me.AnalisisLabAno.Text
        Me.MUESTRAS.Caption = Me.AnalisisLabAno.Text
        Me.NomBoton.Text = "AnalisisLabAno"
    End Sub
    
    Protected Sub EntrCarbAno_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim CadenaEntrega As String = ""
        Dim CadenaCooperativa As String = ""
        Dim CadenaMuestra As String = ""
        Dim CadenaFecha As String = ""
        Dim CadenaPlaca As String = ""
        Dim CadenaConductor As String = ""
        Dim CadenaWhere As String = ""
        
        If Me.EntregaIN.Text <> "" And Me.EntregaFIN.Text <> "" Then
            CadenaEntrega = "(NUMEROENTRADA BETWEEN '" & Me.EntregaIN.Text & "' AND '" & Me.EntregaFIN.Text & "')"
        End If
        If Me.CoopIn.Text <> "" And Me.CoopFin.Text <> "" Then
            CadenaCooperativa = "( HISTORICO_ENTREGAS.COOPERATIVA BETWEEN  '" & Me.CoopIn.Text & "' AND '" & Me.CoopFin.Text & "')"
        End If
        If Me.MuestraIn.Text <> "" And Me.MuestraFin.Text <> "" Then
            CadenaMuestra = "(MUESTRAGEN BETWEEN  '" & Me.MuestraIn.Text & "' AND '" & Me.MuestraFin.Text & "')"
        End If
        If Me.FechaIn.Text <> "" And Me.FechaFin.Text <> "" Then
            CadenaFecha = "(FECHAENTREGA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FechaIn.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FechaFin.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        End If
        If Me.PlacaIn.Text <> "" And Me.PlacaFin.Text <> "" Then
            CadenaPlaca = " (CAMION BETWEEN '" & Trim(Me.PlacaIn.Text) & "' AND '" & Trim(Me.PlacaFin.Text) & "')"
        End If
        If Me.ConductorIn.Text <> "" And Me.ConductorFin.Text <> "" Then
            CadenaConductor = " CONDUCTOR BETWEEN '" & Me.ConductorIn.Text & "' AND '" & Me.ConductorFin.Text & "'"
        End If
       
        If CadenaEntrega <> "" Then
            CadenaWhere = CadenaEntrega & " AND "
        End If
        If CadenaCooperativa <> "" Then
            CadenaWhere = CadenaWhere & CadenaCooperativa & " AND "
        End If
        If CadenaMuestra <> "" Then
            CadenaWhere = CadenaWhere & CadenaMuestra & " AND "
        End If
        If CadenaFecha <> "" Then
            CadenaWhere = CadenaWhere & CadenaFecha & " AND "
        End If
        If CadenaPlaca <> "" Then
            CadenaWhere = CadenaWhere & CadenaPlaca & " AND "
        End If
        If CadenaConductor <> "" Then
            CadenaWhere = CadenaWhere & CadenaConductor & " AND "
        End If
        
        If CadenaWhere <> "" Then
            CadenaWhere = " WHERE " & Left(CadenaWhere, Len(CadenaWhere) - 4)
        Else
            CadenaWhere = " WHERE NUMEROENTRADA='XXX'"
        End If
                
        ssql = " SELECT RIGHT('0' + LEFT(DAY(FECHAENTREGA), 2), 2) + '/' + RIGHT('0' + LEFT(MONTH(FECHAENTREGA), 2), 2) + '/' + LEFT(YEAR(FECHAENTREGA), 4) AS [Fecha Entrega]," & _
                        " NUMEROENTRADA as [Numero Entrada],  MUESTRAGEN as [Muestra Generada], MUESTRAESP as [Muestra Especial], MINAS.DESCRIPCION as Proveedor, Conductor, " & _
                        " PESONETO as [Peso Neto], camion as [Placa],OPERARIOBASCULA as [Operario Báscula], HISTORICO_ENTREGAS.TOMADORMUESTRA as [Toma Muestras], HISTORICO_ENTREGAS.Estado " & _
               " FROM HISTORICO_ENTREGAS LEFT OUTER JOIN MINAS ON HISTORICO_ENTREGAS.MINA = MINAS.NUMERO" & _
                 CadenaWhere
        
        CargarGridView(ssql)
        'para títulos Guia
        CType(Master.FindControl("Label1"), Label).Text = CType(Master.FindControl("Label1"), Label).Text & "\" & Me.EntrCarbAno.Text
        Me.MUESTRAS.Caption = Me.EntrCarbAno.Text
        Me.NomBoton.Text = "EntrCarbAno"
    End Sub

    Protected Sub TblMuestrasAno_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim CadenaEntrega As String = ""
        Dim CadenaCooperativa As String = ""
        Dim CadenaMuestra As String = ""
        Dim CadenaFecha As String = ""
        Dim CadenaWhere As String = ""
        
        If Me.EntregaIN.Text <> "" And Me.EntregaFIN.Text <> "" Then
            CadenaEntrega = "(ENTREGA BETWEEN '" & Me.EntregaIN.Text & "' AND '" & Me.EntregaFIN.Text & "')"
        End If
        If Me.CoopIn.Text <> "" And Me.CoopFin.Text <> "" Then
            CadenaCooperativa = "( HISTORICO_MUESTRAS.COOPERATIVA BETWEEN  '" & Me.CoopIn.Text & "' AND '" & Me.CoopFin.Text & "')"
        End If
        If Me.MuestraIn.Text <> "" And Me.MuestraFin.Text <> "" Then
            CadenaMuestra = "(NUMERO BETWEEN  '" & Me.MuestraIn.Text & "' AND '" & Me.MuestraFin.Text & "')"
        End If
        If Me.FechaIn.Text <> "" And Me.FechaFin.Text <> "" Then
            CadenaFecha = "(FECHAMUESTRA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FechaIn.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FechaFin.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        End If
       
        If CadenaEntrega <> "" Then
            CadenaWhere = CadenaEntrega & " AND "
        End If
        If CadenaCooperativa <> "" Then
            CadenaWhere = CadenaWhere & CadenaCooperativa & " AND "
        End If
        If CadenaMuestra <> "" Then
            CadenaWhere = CadenaWhere & CadenaMuestra & " AND "
        End If
        If CadenaFecha <> "" Then
            CadenaWhere = CadenaWhere & CadenaFecha & " AND "
        End If
        If CadenaWhere <> "" Then
            CadenaWhere = " WHERE " & Left(CadenaWhere, Len(CadenaWhere) - 4)
        Else
            CadenaWhere = " WHERE ENTREGA='XXX'"
        End If
        
        ssql = " SELECT NUMERO as [Cód Muestra], ENTREGA as [Nro. Entrega], COOPERATIVA as [Cooperativa], ACUMPESOS as [Peso Acumulado], Estado " & _
               " FROM HISTORICO_MUESTRAS" & CadenaWhere
        CargarGridView(ssql)
        'para títulos Guia
        CType(Master.FindControl("Label1"), Label).Text = CType(Master.FindControl("Label1"), Label).Text & "\" & Me.TblMuestrasAno.Text
        Me.MUESTRAS.Caption = Me.TblMuestrasAno.Text
        Me.NomBoton.Text = "TblMuestrasAno"
    End Sub

    Protected Sub Editar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Nombre de Botones = : EntrCarbMes;TblMuestrasMes;AnalisisLabAno;EntrCarbAno;TblMuestrasAno
        Dim Biblioteca As New Biblioteca
        Session("Muestra") = Me.Muestra.Text
        Session("Fecha") = Me.Fecha.Text
        Session("Entrega") = Me.Entrega.Text
        Session("ParamBD") = "Actualizar"
        Select Case Me.NomBoton.Text
            Case "EntrCarbMes"
                Biblioteca.AbreVentana("EntradaCarbonMes.aspx", Page)
            Case "TblMuestrasMes"
                Biblioteca.AbreVentana("MuestrasMes.aspx", Page)
            Case "AnalisisLabAno"
                
            Case "EntrCarbAno"
                Biblioteca.AbreVentana("EntradaCarbonAno.aspx", Page)
            Case "TblMuestrasAno"
                Biblioteca.AbreVentana("MuestrasAno.aspx", Page)
        End Select
    End Sub

    Protected Sub Insertar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Nombre de Botones = : EntrCarbMes;TblMuestrasMes;AnalisisLabAno;EntrCarbAno;TblMuestrasAno
        Dim Biblioteca As New Biblioteca
        Session("Muestra") = Me.Muestra.Text
        Session("Fecha") = Me.Fecha.Text
        Session("Entrega") = Me.Entrega.Text
        Session("ParamBD") = "Insertar"
        Select Case Me.NomBoton.Text
            Case "EntrCarbMes"
                Biblioteca.AbreVentana("EntradaCarbonMes.aspx", Page)
            Case "TblMuestrasMes"
                Biblioteca.AbreVentana("MuestrasMes.aspx", Page)
            Case "AnalisisLabAno"
                
            Case "EntrCarbAno"
                Biblioteca.AbreVentana("EntradaCarbonAno.aspx", Page)
            Case "TblMuestrasAno"
                Biblioteca.AbreVentana("MuestrasAno.aspx", Page)
        End Select
    End Sub

    Protected Sub Eliminar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Nombre de Botones = : EntrCarbMes;TblMuestrasMes;AnalisisLabAno;EntrCarbAno;TblMuestrasAno
        Dim Biblioteca As New Biblioteca
        Session("Muestra") = Me.Muestra.Text
        Session("Fecha") = Me.Fecha.Text
        Session("Entrega") = Me.Entrega.Text
        Session("ParamBD") = "Eliminar"
        Select Case Me.NomBoton.Text
            Case "EntrCarbMes"
                Biblioteca.AbreVentana("EntradaCarbonMes.aspx", Page)
            Case "TblMuestrasMes"
                Biblioteca.AbreVentana("MuestrasMes.aspx", Page)
            Case "AnalisisLabAno"
                
            Case "EntrCarbAno"
                Biblioteca.AbreVentana("EntradaCarbonAno.aspx", Page)
            Case "TblMuestrasAno"
                Biblioteca.AbreVentana("MuestrasAno.aspx", Page)
        End Select
    End Sub

Protected Sub MUESTRAS_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)

End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
    <div>
        <table border="0" id="TABLE1"> 
            <tr>
                <td align="right" colspan="1" style="width: 126px; height: 1px">
                    <asp:Label ID="Label7" runat="server" Font-Bold="True" ForeColor="#336677" Text="EntregaIn"
                        Width="80px"></asp:Label></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:TextBox ID="EntregaIN" runat="server" Width="73px"></asp:TextBox></td>
                <td align="right" colspan="1" style="width: 126px; height: 1px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="CoopIn"
                        Width="62px"></asp:Label></td>
                <td align="left" colspan="1" style="height: 1px">
                    <asp:TextBox ID="CoopIn" runat="server" Width="54px"></asp:TextBox></td>
                <td align="left" colspan="1" style="height: 1px; text-align: right;">
                    <asp:Label ID="Label9" runat="server" Font-Bold="True" ForeColor="#336677" Text="PlacaIn"
                        Width="28px"></asp:Label>
                    </td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:TextBox ID="PlacaIn" runat="server" Width="54px"></asp:TextBox></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                <asp:Label ID="Label11" runat="server" Font-Bold="True" ForeColor="#336677" Text="CondIn"
                        Width="28px"></asp:Label>
                </td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:TextBox ID="ConductorIn" runat="server" Width="93px"></asp:TextBox></td>
                <td align="right" colspan="1" style="height: 1px; width: 126px;">
                    <asp:Label ID="Label3" runat="server" Font-Bold="True" ForeColor="#336677" Text="MuestraIn"
                        Width="77px"></asp:Label></td>
                <td align="left" colspan="1" style="height: 1px">
                    <asp:TextBox ID="MuestraIn" runat="server" Width="70px"></asp:TextBox></td>
                <td align="right" colspan="1" style="height: 1px; width: 126px;">
                    <asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="#336677" Text="FechaIn"
                        Width="21px"></asp:Label></td>
                <td align="left" colspan="4" style="height: 1px">
                    <asp:TextBox ID="FechaIn" runat="server" Width="75px"></asp:TextBox></td>
                <td align="left" colspan="1" style="height: 1px">
                <asp:CompareValidator
                        ID="cvFecha1" runat="server" ControlToValidate="FechaIn" ErrorMessage="*"
                        Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="3px"></asp:CompareValidator></td>
            </tr>
            <tr>
                <td align="right" colspan="1" style="width: 126px; height: 1px">
                    <asp:Label ID="Label8" runat="server" Font-Bold="True" ForeColor="#336677" Text="EntregaFin"
                        Width="84px"></asp:Label></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:TextBox ID="EntregaFIN" runat="server" Width="73px"></asp:TextBox></td>
                <td align="right" colspan="1" style="width: 126px; height: 1px">
                    <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="#336677" Text="CoopFin"
                        Width="62px"></asp:Label></td>
                <td align="left" colspan="1" style="height: 1px">
                    <asp:TextBox ID="CoopFin" runat="server" Width="54px"></asp:TextBox></td>
                <td align="left" colspan="1" style="height: 1px; text-align: right;">
                    <asp:Label ID="Label10" runat="server" Font-Bold="True" ForeColor="#336677" Text="PlacaFin"
                        Width="40px"></asp:Label></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:TextBox ID="PlacaFin" runat="server" Width="54px"></asp:TextBox></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:Label ID="Label12" runat="server" Font-Bold="True" ForeColor="#336677" Text="CondFin"
                        Width="28px"></asp:Label></td>
                <td align="left" colspan="1" style="width: 126px; height: 1px">
                    <asp:TextBox ID="ConductorFin" runat="server" Width="93px"></asp:TextBox></td>
                <td align="right" colspan="1" style="height: 1px; width: 126px;">
                    <asp:Label ID="Label4" runat="server" Font-Bold="True" ForeColor="#336677" Text="MuestraFin"
                        Width="83px"></asp:Label></td>
                <td align="left" colspan="1" style="height: 1px">
                    <asp:TextBox ID="MuestraFin" runat="server" Width="70px"></asp:TextBox></td>
                <td align="right" colspan="1" style="height: 1px; width: 126px;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" ForeColor="#336677" Text="FechaFin"
                        Width="36px"></asp:Label></td>
                <td align="left" colspan="4" style="height: 1px">
                    <asp:TextBox ID="FechaFin" runat="server" Width="75px"></asp:TextBox>
                   
                    </td>
                <td align="left" colspan="1" style="height: 1px">
                 <asp:CompareValidator
                        ID="cvFecha2" runat="server" ControlToValidate="FechaFin" ErrorMessage="*"
                        Operator="DataTypeCheck" SetFocusOnError="True" Type="Date" Width="16px"></asp:CompareValidator>
                </td>
            </tr>
            <tr>
                <td align="left" colspan="16" style="height: 1px">
                    <asp:Button ID="EntrCarbMes" runat="server" ForeColor="#336677" Height="23px"
                        Text="Entradas Carbón Mes" Width="139px" OnClick="EntrCarbMes_Click" />
                    <asp:Button ID="TblMuestrasMes" runat="server" ForeColor="#336677" Height="24px" Text="Tabla Muestras Mes"
                        Width="134px" OnClick="TblMuestrasMes_Click" />
                    <asp:Button ID="AnalisisLabAno" runat="server" ForeColor="#336677" Height="24px" Text="Análisis de Lab. Año"
                        Width="136px" OnClick="AnalisisLabAno_Click" />
                    <asp:Button ID="EntrCarbAno" runat="server" ForeColor="#336677" Height="24px" Text="Entradas Carbón Año"
                        Width="148px" OnClick="EntrCarbAno_Click" />
                    <asp:Button ID="TblMuestrasAno" runat="server" ForeColor="#336677" Height="24px" Text="Tabla Muestras Año"
                        Width="147px" OnClick="TblMuestrasAno_Click" /></td>
            </tr>
            <tr>
                <td align="left" colspan="3">
                    <asp:Button ID="Editar" runat="server" ForeColor="#336677" Text="Editar" OnClick="Editar_Click" />
                    <asp:Button ID="Insertar" runat="server" ForeColor="#336677" Text="Insertar" OnClick="Insertar_Click" />
                    <asp:Button ID="Eliminar" runat="server" ForeColor="#336677" Text="Eliminar" OnClick="Eliminar_Click" /></td>
                <td align="left" colspan="1">
                    <asp:TextBox ID="Muestra" runat="server" Visible="False" Width="38px"></asp:TextBox></td>
                <td align="left" colspan="1">
                </td>
                <td align="left" colspan="1" style="width: 126px">
                </td>
                <td align="left" colspan="1" style="width: 126px">
                </td>
                <td align="left" colspan="1" style="width: 126px">
                </td>
                <td align="left" colspan="1" style="width: 126px">
                    <asp:TextBox ID="Entrega" runat="server" Visible="False" Width="38px"></asp:TextBox></td>
                <td align="left" colspan="1">
                    <asp:TextBox ID="Fecha" runat="server" Visible="False" Width="38px"></asp:TextBox></td>
                <td align="left" colspan="1" style="width: 3px">
                    <asp:TextBox ID="NomBoton" runat="server" Visible="False" Width="38px"></asp:TextBox></td>
                <td align="left" colspan="1" style="width: 3px">
                </td>
                <td align="left" colspan="1" style="width: 3px">
                </td>
                <td align="left" colspan="3">
                </td>
            </tr>
            <tr>
                <td align="left" colspan="16">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" colspan="16" height="1">
                    <asp:GridView ID="MUESTRAS" runat="server" BackColor="White" BorderColor="#CCCCCC"
                        BorderStyle="None" BorderWidth="1px" Caption="Entradas Carbón Mes" CellPadding="3"
                        Font-Overline="False" ForeColor="#336677" Height="41px" OnRowCommand="MUESTRAS_RowCommand"
                        Width="166px">
                        <FooterStyle BackColor="White" Font-Bold="True" ForeColor="#000066" />
                        <Columns>
                            <asp:CommandField ButtonType="Button" SelectText="" ShowSelectButton="True" />
                        </Columns>
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Center" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="False" ForeColor="White" />
                        <AlternatingRowStyle Font-Bold="False" Font-Italic="False" Wrap="False" />
                    </asp:GridView>
                    &nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                </td>
                <td align="left" style="width: 126px">
                
                </td>
                <td style="width: 524px" align="right">
                
                </td>
                <td align="left" height="1" style="width: 53px">
                
                </td>
                <td align="left" height="1" style="height: 1px;" colspan="3">
                
                </td>
            </tr>
        </table>
    </div>    
</asp:Content>