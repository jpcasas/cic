<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Control de Cooperativas" %>

<%@ Register
    Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="ajaxToolkit" %>
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
            Actualizar()
        End If
    End Sub
    
    Private Sub Actualizar()
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim ssql As String
        Dim Mensaje As String = ""
        
        Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
        If Mensaje = "" Then
            Response.Redirect("Principal.aspx")
        Else
            CType(Master.FindControl("Label1"), Label).Text = Mensaje
        End If
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT  CAST(LEFT(NUMERO, CHARINDEX('/', NUMERO+ '/') -1) AS INT) AS ORDEN, NUMERO + '_' + DESCRIPCION AS COOPERATIVA " & _
               " FROM COOPERATIVAS " & _
               " UNION " & _
               " SELECT  '', '' AS COOPERATICVA1" & _
               " FROM COOPERATIVAS AS COOPERATIVAS_1 "
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "COOPERATIVAS")
        'Combo1 Usuarios
        Me.CODIGOS.DataSource = DtSet.Tables("COOPERATIVAS").DefaultView
        Me.CODIGOS.DataTextField = "COOPERATIVA"
        ' Asigna el valor del value en el DropDownList
        Me.CODIGOS.DataValueField = "COOPERATIVA"
        Me.CODIGOS.DataBind()
        BIBLIOTECA.DesConectar(conn)
    End Sub

    Protected Sub CODIGOS_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim ssql As String
        Dim MyDataRow As DataRow
        Dim MyDataColumn As DataColumn
        Dim Numero1 As String
        Dim Descripcion1 As String
        Dim Mensaje As String
        
        Try
            If TypeOf sender Is TextBox Then
            
                Me.CODIGOS.SelectedValue = Me.myTextBox.Text
            End If
            If TypeOf sender Is DropDownList Then
                Me.myTextBox.Text = Me.CODIGOS.SelectedValue
            End If
        Catch hi As Exception
        End Try
        Try
            'se indica que el boton actualizar no creara un nuevo registro si no que 
            'solo actualizara los datos modificados
            Session("Nuevoreg") = "NO"
            Numero1 = Trim(Left(Me.CODIGOS.SelectedValue, InStr(Me.CODIGOS.SelectedValue, "_", CompareMethod.Text) - 1))
            Descripcion1 = ""
            Mensaje = ""
            conn = BIBLIOTECA.Conectar(Mensaje)
            ssql = "SELECT * FROM COOPERATIVAS WHERE NUMERO='" & Numero1 & "'"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            BIBLIOTECA.DesConectar(conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "COOPERATIVAS")
            'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
            For Each MyDataRow In DtSet.Tables("COOPERATIVAS").Rows
                For Each MyDataColumn In DtSet.Tables("COOPERATIVAS").Columns
                    Select Case MyDataColumn.ColumnName
                        Case "NUMERO"
                            NUMERO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                            Me.NUMERO.Enabled = False
                        Case "DESCRIPCION"
                            DESCRIPCION.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Case "CUPOLIMITE"
                            CUPOLIMITE.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Case "ENTREGAS"
                            ENTREGAS.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Case "KGS_ACUM"
                            KGS_ACUM.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Case "ESTADO"
                            ESTADO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    End Select
                Next MyDataColumn
            Next MyDataRow
        Catch ex As Exception
        End Try
        
    End Sub
    
    Protected Sub Text_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim ssql As String
        Dim MyDataRow As DataRow
        Dim MyDataColumn As DataColumn
        Dim Numero1 As String
        Dim Descripcion1 As String
        Dim Mensaje As String
        'se indica que el boton actualizar no creara un nuevo registro si no que 
        'solo actualizara los datos modificados
        Session("Nuevoreg") = "NO"
        Numero1 = Trim(Left(Me.myTextBox.Text, InStr(Me.myTextBox.Text, "_", CompareMethod.Text) ))
        Descripcion1 = ""
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT * FROM COOPERATIVAS WHERE NUMERO='" & Numero1 & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "COOPERATIVAS")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("COOPERATIVAS").Rows
            For Each MyDataColumn In DtSet.Tables("COOPERATIVAS").Columns
                Select Case MyDataColumn.ColumnName
                    Case "NUMERO"
                        NUMERO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.NUMERO.Enabled = False
                    Case "DESCRIPCION"
                        DESCRIPCION.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "CUPOLIMITE"
                        CUPOLIMITE.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "ENTREGAS"
                        ENTREGAS.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "KGS_ACUM"
                        KGS_ACUM.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "ESTADO"
                        ESTADO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                End Select
            Next MyDataColumn
        Next MyDataRow
    End Sub
    
    Protected Sub BtnNuevo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.NUMERO.Enabled = True
        Session("Nuevoreg") = "SI"
        Me.NUMERO.Text = ""
        Me.DESCRIPCION.Text = ""
        Me.CUPOLIMITE.Text = ""
        Me.ENTREGAS.Text = ""
        Me.KGS_ACUM.Text = ""
        Me.ESTADO.Text = ""
    End Sub

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim ssql As String
        Dim Mensaje As String
        ssql = ""
        If Me.NUMERO.Text = "" Then
            'MsgBox("No se puede insertar un número nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un número nulo"
            Exit Sub
        End If
        If Session("NuevoReg") = "SI" Then
            ssql = "INSERT INTO COOPERATIVAS ( NUMERO, DESCRIPCION, CUPOLIMITE, ENTREGAS, KGS_ACUM, ESTADO )" & _
                   " VALUES ('" & Me.NUMERO.Text & "', '" & Me.DESCRIPCION.Text & "', " & Me.CUPOLIMITE.Text & "," & Me.ENTREGAS.Text & "," & Me.KGS_ACUM.Text & ", '" & Me.ESTADO.Text & "')"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "Cooperativas", "Numero:" & Me.NUMERO.Text & ";Cupo Limite:" & Me.CUPOLIMITE.Text & ";Entregas:" & Me.ENTREGAS.Text & ";kg Acumulados:" & Me.KGS_ACUM.Text & ";Estado:" & Me.ESTADO.Text, Session("GRUPOUS"))
        ElseIf Session("NuevoReg") = "NO" Then
            ssql = "UPDATE COOPERATIVAS " & _
                   " SET COOPERATIVAS.DESCRIPCION ='" & Me.DESCRIPCION.Text & "', COOPERATIVAS.CUPOLIMITE =" & Me.CUPOLIMITE.Text & ", COOPERATIVAS.ENTREGAS =" & Me.ENTREGAS.Text & ", COOPERATIVAS.KGS_ACUM =" & Me.KGS_ACUM.Text & ", COOPERATIVAS.ESTADO='" & Me.ESTADO.Text & "'" & _
                   " WHERE COOPERATIVAS.NUMERO ='" & Me.NUMERO.Text & "'"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Cooperativas", "Numero:" & Me.NUMERO.Text & ";Cupo Limite:" & Me.CUPOLIMITE.Text & ";Entregas:" & Me.ENTREGAS.Text & ";kg Acumulados:" & Me.KGS_ACUM.Text & ";Estado:" & Me.ESTADO.Text, Session("GRUPOUS"))
        End If
        Mensaje = ""
        Biblioteca.EjecutarSql(Mensaje, ssql)
        Actualizar()
    End Sub

    Protected Sub CODIGO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.NUMERO.Text = UCase(Me.NUMERO.Text)
    End Sub

    Protected Sub Eliminar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String = ""
        Dim conn As SqlConnection
        Dim DtReader As SqlDataReader
        Dim Mensaje As String = ""
        Dim Seguridad As New Seguridad
        
        conn = Biblioteca.Conectar(Mensaje)
        ssql = "SELECT     NUMERO" & _
               " FROM MINAS " & _
               " WHERE NUMERO LIKE '" & Trim(Me.NUMERO.Text) & "%'"
        DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
        If DtReader.Read Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "La cooperativa tiene un proveedor relacionado " & vbCrLf & "No se puede Eliminar"
        Else
            DtReader.Close()
            ssql = "DELETE FROM COOPERATIVAS" & _
                   " WHERE NUMERO = '" & Me.NUMERO.Text & "'"
            If Biblioteca.EjecutarSql(Mensaje, ssql) Then
                Seguridad.RegistroAuditoria(Session("Usuario"), "Eliminar", "Cooperativas", "Numero:" & Me.NUMERO.Text & ";Cupo Limite:" & Me.CUPOLIMITE.Text & ";Entregas:" & Me.ENTREGAS.Text & ";kg Acumulados:" & Me.KGS_ACUM.Text & ";Estado:" & Me.ESTADO.Text, Session("GRUPOUS"))
                Me.mensaje.ForeColor = Color.Blue
                Me.mensaje.Text = "El Registro se ha eliminado"
            Else
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "No se ha Eliminado el Registro"
            End If
        End If
        Biblioteca.DesConectar(conn)
    End Sub

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        
        ssql = "SELECT CAST(LEFT(NUMERO, CHARINDEX('/', NUMERO+ '/') -1) AS INT) AS ORDEN, " & _
        "* FROM COOPERATIVAS WHERE ESTADO='AC' ORDER BY ORDEN"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "Cooperativas.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "Cooperativas"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Cooperativas", "Cooperativas:Todas", Session("GRUPOUS"))
    End Sub

    Protected Sub ImportarExcel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Biblioteca.AbreVentana("ImportarCooperativas.aspx", Page)
    End Sub
    
    </script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    





    <div>
        &nbsp;&nbsp;
                    
                  

<asp:ScriptManager ID="ScriptManager1" runat="server">
        <Services>
        <asp:ServiceReference Path="AutoComplete.asmx" />
        </Services>
        </asp:ScriptManager>
            <ajaxToolkit:AutoCompleteExtender
                runat="server" 
                ID="autoComplete12" 
                TargetControlID="myTextBox"
                BehaviorID="AutoCompleteEx"
                ServicePath="AutoComplete.asmx" 
                ServiceMethod="GetCompletionList"
                MinimumPrefixLength="1" 
                CompletionInterval="1000"
                EnableCaching="true">
                
                </ajaxToolkit:AutoCompleteExtender>                    
     
        <table>
            <tr>
                <td align="right" style="width: 167px; height: 6px;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Número" ForeColor="#336677"></asp:Label></td>
                <td colspan="2" style="height: 6px">
                    <asp:TextBox runat="server" ID="myTextBox" Width="300" autocomplete="off"  AutoPostBack="true" OnTextChanged="CODIGOS_SelectedIndexChanged"/></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 11px;">
                    <asp:Label ID="Label8" runat="server" Font-Bold="True" ForeColor="#336677" Text="Selección"></asp:Label></td>

                <td style="width: 123px; height: 11px;">
                    &nbsp;<asp:DropDownList ID="CODIGOS" runat="server" OnSelectedIndexChanged="CODIGOS_SelectedIndexChanged"
                        Width="286px" AutoPostBack="True">
                    </asp:DropDownList>
                    &nbsp;
                    
                    
                    
                    </td>
                <td style="width: 79px; height: 11px;">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label1" runat="server" Text="Número" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 123px" align="left">
                    <asp:TextBox ID="NUMERO" runat="server" OnTextChanged="CODIGO_TextChanged"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                    </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label3" runat="server" Text="Descripción" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="DESCRIPCION" runat="server" EnableTheming="True" Width="279px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label4" runat="server" Text="Cupo Limite" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 123px" align="left">
                    <asp:TextBox ID="CUPOLIMITE" runat="server"></asp:TextBox></td>
                                        
                <td align="left" height="1" style="width: 79px">
                    </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px; height: 24px;">
                    <asp:Label ID="Label2" runat="server" Text="Entregas" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 123px; height: 24px;" align="left">
                    <asp:TextBox ID="ENTREGAS" runat="server"></asp:TextBox></td>
                <td align="left" style="width: 79px; height: 24px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label7" runat="server" Font-Bold="True" ForeColor="#336677" Text="Kgrs Acumulados"></asp:Label></td>
                <td style="width: 123px" align="left">
                    <asp:TextBox ID="KGS_ACUM" runat="server"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label5" runat="server" Text="Estado" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 123px" align="left">
                    <asp:TextBox ID="ESTADO" runat="server"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="center" colspan="2" style="height: 26px; text-align: right;">                    
                    <asp:Button ID="ImportarExcel" runat="server" Font-Bold="True" ForeColor="#336677"
                        OnClick="ImportarExcel_Click" Text="Importar" ToolTip="Importar Datos desde Archivo Csv"
                        Width="114px" />
                    <asp:Button ID="BtnNuevo" runat="server" OnClick="BtnNuevo_Click" Text="Nuevo" ForeColor="#336677" Font-Bold="True" />
                    <asp:Button ID="BtnActualizar" runat="server" Text="Acualizar" OnClick="BtnActualizar_Click" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" />&nbsp;
                    <asp:Button ID="Eliminar" runat="server" Text="Eliminar" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Eliminar_Click" /></td>
                <td align="center" colspan="1" height="1" style="width: 79px; text-align: left;">
                <asp:Button ID="Imprimir" runat="server" Text="Imprimir" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Imprimir_Click" /></td>
            </tr>
            <tr>
                <td align="center" colspan="3" style="text-align: left; height: 1px;">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>    
</asp:Content>