<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Reporte para Auditoría de Usuarios" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        
        Dim ssql As String
        Me.mensaje.Text = ""
        
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        
        
        If Not Page.IsPostBack Then
            Me.FECHAFIN.Text = Today
            Me.FECHAIN.Text = Today
            Dim Mensaje As String = ""
            
            Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            Mensaje = ""
            
            conn = BIBLIOTECA.Conectar(Mensaje)
            DtSet = New DataSet
            'Cargar Usuario
            ssql = " SELECT DISTINCT USUARIO" & _
                   " FROM AUDITORIA" & _
                   " UNION " & _
                   " SELECT 'Todos' AS USUARIO " & _
                   " FROM AUDITORIA AS AUDITORIA_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "AUDITORIA")
            'Combo1 Usuarios
            Me.Codigos.DataSource = DtSet.Tables("AUDITORIA").DefaultView
            Me.Codigos.DataTextField = "USUARIO"
            ' Asigna el valor del value en el DropDownList
            Me.Codigos.DataValueField = "USUARIO"
            Me.Codigos.DataBind()
            
            'Cargar Procesos 
            ssql = " SELECT DISTINCT PROCESO" & _
                   " FROM AUDITORIA  " & _
                   " UNION " & _
                   " SELECT 'Todos' AS PROCESO1" & _
                   " FROM AUDITORIA AS AUDITORIA_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "AUDITORIA1")
            'Combo1 Usuarios
            Me.Proceso.DataSource = DtSet.Tables("AUDITORIA1").DefaultView
            Me.Proceso.DataTextField = "PROCESO"
            ' Asigna el valor del value en el DropDownList
            Me.Proceso.DataValueField = "PROCESO"
            Me.Proceso.DataBind()
            '
        End If
    End Sub

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Seguridad As New Seguridad
        Dim Mensaje As String = ""
        Dim CadenaWhere As String = ""
        
        ''Imprimir        
        If Me.Proceso.Text = "Todos" And Me.SubProceso.Text = "Todos" Then
            CadenaWhere = " WHERE (FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102))"
        ElseIf Me.Proceso.Text <> "Todos" And Me.SubProceso.Text = "Todos" Then
            CadenaWhere = " WHERE (FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)) AND PROCESO = '" & Me.Proceso.Text & "'"
        ElseIf Me.Proceso.Text = "Todos" And Me.SubProceso.Text <> "Todos" Then
            CadenaWhere = " WHERE (FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)) AND SUBPROCESO = '" & Me.SubProceso.Text & "'"
        ElseIf Me.Proceso.Text <> "Todos" And Me.SubProceso.Text <> "Todos" Then
            CadenaWhere = " WHERE (FECHA BETWEEN CONVERT(DATETIME, '" & Format(CDate(Me.FECHAIN.Text), "yyyy-MM-dd 00:00:00") & "', 102) AND CONVERT(DATETIME, '" & Format(CDate(Me.FECHAFIN.Text), "yyyy-MM-dd 00:00:00") & "', 102)) AND SUBPROCESO = '" & Me.SubProceso.Text & "' AND PROCESO = '" & Me.Proceso.Text & "'"
        End If
        
        If Me.Codigos.Text <> "Todos" Then
            CadenaWhere = CadenaWhere & " AND USUARIO='" & Me.Codigos.Text & "'"
        End If
        
        ssql = " SELECT USUARIO, GRUPO, FECHA, HORA, PROCESO, SUBPROCESO, DESCRIPCION" & _
               " FROM AUDITORIA" & _
               CadenaWhere
                
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("Parametro") = Today
        Session("NombreDataTable") = "Auditoria"
        Session("NombreReporte") = "AUDITORIA.rpt"
                
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Auditoria", "FechaIn:" & Me.FECHAIN.Text, Session("GRUPOUS"))
        'Fin Imprimir

    End Sub

    Protected Sub Proceso_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As New DataSet
        Dim SSQL As String
        Dim Mensaje As String = ""
        
        conn = BIBLIOTECA.Conectar(mensaje)
        'cargar subproceso
        SSQL = "SELECT DISTINCT SUBPROCESO" & _
               " FROM AUDITORIA " & _
               " WHERE PROCESO = '" & Me.Proceso.Text & "'" & _
               " UNION " & _
               " SELECT 'Todos' AS SUBPROCESO1 " & _
               " FROM AUDITORIA AS AUDITORIA_1"
            
        DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "AUDITORIA2")
        'Combo1 Usuarios
        Me.SubProceso.DataSource = DtSet.Tables("AUDITORIA2").DefaultView
        Me.SubProceso.DataTextField = "SUBPROCESO"
        ' Asigna el valor del value en el DropDownList
        Me.SubProceso.DataValueField = "SUBPROCESO"
        Me.SubProceso.DataBind()
        Biblioteca.DesConectar(conn)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
        <br />
        <br />
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
                <td align="right" style="width: 167px; height: 6px">
                </td>
                <td style="width: 167px; height: 6px">
                </td>
                <td height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 6px">
                    <asp:Label ID="Label4" runat="server" Font-Bold="True" ForeColor="#336677" Text="Usuario a Imprimir"></asp:Label></td>
                <td colspan="2" height="1">
                    <asp:DropDownList ID="Codigos" runat="server" AutoPostBack="True" Width="235px">
                    </asp:DropDownList></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 6px">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" ForeColor="#336677" Text="Proceso"></asp:Label></td>
                <td colspan="2" height="1">
                    <asp:DropDownList ID="Proceso" runat="server" AutoPostBack="True" Width="235px" OnSelectedIndexChanged="Proceso_SelectedIndexChanged">
                    </asp:DropDownList></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 6px">
                    <asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="#336677" Text="Sub Proceso"></asp:Label></td>
                <td colspan="2" style="height: 6px">
                    <asp:DropDownList ID="SubProceso" runat="server" AutoPostBack="True" Width="235px">
                    </asp:DropDownList></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    </td>
                <td align="left" colspan="2" height="1">
                    &nbsp;<asp:Button ID="Imprimir" runat="server" Font-Bold="True" ForeColor="#336677"
                         Text="Imprimir" ToolTip="Imprimir Entrega "
                        Width="114px" OnClick="Imprimir_Click" /></td>
            </tr>
            <tr>
                <td align="right" style="text-align: left;" colspan="3">
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
            </tr>
        </table>
    </div>    
</asp:Content>