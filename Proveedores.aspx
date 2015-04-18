<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Control de Proveedores" %>
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
        Me.mensaje.Text=""
        If Not Page.IsPostBack Then
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
            conn = BIBLIOTECA.Conectar(Mensaje)
            ssql = "SELECT CAST(LEFT(NUMERO, CHARINDEX('/', NUMERO+ '/') -1) AS INT) AS ORDEN, NUMERO + '_' + DESCRIPCION AS NMINA " & _
                   " FROM MINAS UNION SELECT '', '' FROM MINAS ORDER BY ORDEN"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "MINAS")
            'Combo1 Usuarios
            Me.CODIGOS.DataSource = DtSet.Tables("MINAS").DefaultView
            Me.CODIGOS.DataTextField = "NMINA"
            ' Asigna el valor del value en el DropDownList
            Me.CODIGOS.DataValueField = "NMINA"
            Me.CODIGOS.DataBind()
            
            'Combo2 Grupos
            ssql = "SELECT NUMERO,NOMBRE FROM MUNICIPIOS"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DtSet, "MUNICIPIOS")
            Me.MUNICIPIO.DataSource = DtSet.Tables("MUNICIPIOS").DefaultView
            Me.MUNICIPIO.DataTextField = "NOMBRE"
            ' Asigna el valor del value en el DropDownList
            Me.MUNICIPIO.DataValueField = "NUMERO"
            Me.MUNICIPIO.DataBind()
            'Cerrar Conexion
            BIBLIOTECA.DesConectar(conn)
        End If
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
               
        
        If TypeOf sender Is TextBox Then
            Try
            Me.CODIGOS.SelectedValue = Me.myTextBox.Text
            Catch ex As Exception
            End Try

        End If
        If TypeOf sender Is DropDownList Then
        Try
            Me.myTextBox.Text = Me.CODIGOS.SelectedValue
            Catch ex As Exception
            End Try

        End If
        'se indica que el boton actualizar no creara un nuevo registro si no que 
        'solo actualizara los datos modificados
        Session("Nuevoreg") = "NO"
        Try
        Numero1 = Trim(Left(Me.CODIGOS.SelectedValue, InStr(Me.CODIGOS.SelectedValue, "_", CompareMethod.Text) - 1))
        Descripcion1 = ""
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT * FROM MINAS WHERE NUMERO='" & Numero1 & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "MINAS")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("MINAS").Rows
            For Each MyDataColumn In DtSet.Tables("MINAS").Columns
                Select Case MyDataColumn.ColumnName
                    Case "NUMERO"
                        NUMERO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.NUMERO.Enabled = False
                    Case "DESCRIPCION"
                        DESCRIPCION.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "UNIDAD"
                        UNIDAD.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.NUMERO.Enabled = False
                    Case "MUNICIPIO"
                        MUNICIPIO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "OBSERVACIONES"
                        OBSERVACIONES.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
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
        Numero1 = Trim(Left(Me.myTextBox.Text, InStr(Me.myTextBox.Text, "_", CompareMethod.Text)))
        Descripcion1 = ""
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssql = "SELECT * FROM MINAS WHERE NUMERO='" & Numero1 & "'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        BIBLIOTECA.DesConectar(conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "MINAS")
        'Ciclos for each para ubicar el nombre del campo y asi ubicar valor
        For Each MyDataRow In DtSet.Tables("MINAS").Rows
            For Each MyDataColumn In DtSet.Tables("MINAS").Columns
                Select Case MyDataColumn.ColumnName
                    Case "NUMERO"
                        NUMERO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.NUMERO.Enabled = False
                    Case "DESCRIPCION"
                        DESCRIPCION.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "UNIDAD"
                        UNIDAD.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                        Me.NUMERO.Enabled = False
                    Case "MUNICIPIO"
                        MUNICIPIO.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
                    Case "OBSERVACIONES"
                        OBSERVACIONES.Text = MyDataRow(MyDataColumn.ColumnName).ToString()
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
        Me.UNIDAD.Text = ""
        Me.MUNICIPIO.Text = "002"
        Me.OBSERVACIONES.Text = ""
        ME.ESTADO.Text=""
    End Sub

    Protected Sub BtnActualizar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Mensaje As String
        Dim Seguridad As New Seguridad
        
        ssql = ""
        If Me.NUMERO.Text = "" Then
            'MsgBox("No se puede insertar un número nulo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "No se puede insertar un número nulo"
            Exit Sub
        End If
        If Session("NuevoReg") = "SI" Then
            ssql = "INSERT INTO MINAS ( NUMERO, DESCRIPCION, MUNICIPIO, OBSERVACIONES, UNIDAD,ESTADO )" & _
                   "VALUES ('" & Me.NUMERO.Text & "', '" & Me.DESCRIPCION.Text & "', '" & Me.MUNICIPIO.Text & "', '" & Me.OBSERVACIONES.Text & "', '" & Me.UNIDAD.Text & "', '"& ME.ESTADO.Text &"')"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "Proveedores", "Código:" & Me.NUMERO.Text & ";Descripción:" & Me.DESCRIPCION.Text & ";Municipio:" & Me.MUNICIPIO.Text & ";Unidad:" & Me.UNIDAD.Text & ";Estado:" & me.ESTADO.Text, Session("GRUPOUS"))
            
        ElseIf Session("NuevoReg") = "NO" Then
            ssql = " UPDATE MINAS " & _
                   " SET MINAS.DESCRIPCION ='" & Me.DESCRIPCION.Text & "', MINAS.MUNICIPIO ='" & Me.MUNICIPIO.Text & "', MINAS.OBSERVACIONES ='" & Me.OBSERVACIONES.Text & "', MINAS.UNIDAD ='" & Me.UNIDAD.Text & "', ESTADO='"& ME.ESTADO.Text &"'" & _
                   " WHERE MINAS.NUMERO='" & Me.NUMERO.Text & "'"
            Seguridad.RegistroAuditoria(Session("Usuario"), "Actualizar", "Proveedores", "Código:" & Me.NUMERO.Text & ";Descripción:" & Me.DESCRIPCION.Text & ";Municipio:" & Me.MUNICIPIO.Text & ";Unidad:" & Me.UNIDAD.Text & ";Estado:" & me.ESTADO.Text, Session("GRUPOUS"))
        End If
        Mensaje = ""
        Biblioteca.EjecutarSql(Mensaje,  ssql)
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
        ssql = " SELECT NUMEROENTRADA " & _
               " FROM HISTORICO_ENTREGAS " & _
               " WHERE NUMEROENTRADA LIKE '"& me.NUMERO.Text &"%'"
        DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
        If DtReader.Read Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El Proveedor tiene Historico de Entregas  " & vbCrLf & "No se puede Eliminar"
        Else        
            DtReader.Close()
            ssql = " SELECT NUMEROENTRADA " & _
               " FROM ENTREGAS " & _
               " WHERE NUMEROENTRADA LIKE '"& me.NUMERO.Text &"%'"
            DtReader = Biblioteca.CargarDataReader(Mensaje, ssql, conn)
            If DtReader.Read Then
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "El Proveedor tiene Entregas  " & vbCrLf & "No se puede Eliminar"
            Else     
                DtReader.Close()                            
                ssql = "DELETE FROM MINAS" & _
                       " WHERE NUMERO = '" & Me.NUMERO.Text & "'"
                If Biblioteca.EjecutarSql(Mensaje, ssql) Then                
                    Seguridad.RegistroAuditoria(Session("Usuario"), "Eliminar", "Proveedores", "Código:" & Me.NUMERO.Text & ";Descripción:" & Me.DESCRIPCION.Text & ";Municipio:" & Me.MUNICIPIO.Text & ";Unidad:" & Me.UNIDAD.Text & ";Estado:" & me.ESTADO.Text, Session("GRUPOUS"))
                    Me.mensaje.ForeColor = Color.Blue
                    Me.mensaje.Text = "El Registro se ha eliminado"
                Else
                    Me.mensaje.ForeColor = Color.Red
                    Me.mensaje.Text = "No se ha Eliminado el Registro"
                End If
            End if
        End If
        Biblioteca.DesConectar(conn)
    End Sub

    Protected Sub Imprimir_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ssql As String
        Dim Biblioteca As New Biblioteca
        Dim Seguridad As New Seguridad
        
        ssql = "SELECT CAST(LEFT(MINAS.NUMERO, CHARINDEX('/', MINAS.NUMERO+ '/') -1) AS INT) AS ORDEN, MINAS.NUMERO, MINAS.DESCRIPCION, MINAS.MUNICIPIO + '  ' + MUNICIPIOS.NOMBRE AS MUNICIPIO, MINAS.OBSERVACIONES, MINAS.UNIDAD, MINAS.ESTADO " & _
                " FROM         MINAS LEFT OUTER JOIN MUNICIPIOS ON MINAS.MUNICIPIO = MUNICIPIOS.NUMERO" & _
                " WHERE ESTADO='AC' ORDER BY ORDEN"
        Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
        Session("SqlReporte") = ssql
        Session("NombreReporte") = "Proveedores.rpt"
        Session("Parametro") = "Fecha de Impresión " & Format(Today, "dd/MMM/yyyy")
        Session("NombreDataTable") = "MINAS"
        Seguridad.RegistroAuditoria(Session("Usuario"), "Reportes", "Proveedores", "Proveedores:Todos", Session("GRUPOUS"))
    End Sub

    Protected Sub ImportarExcel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Biblioteca.AbreVentana("ImportarProveedores.aspx", Page)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

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
                ServiceMethod="GetProveedoresList"
                MinimumPrefixLength="1" 
                CompletionInterval="1000"
                EnableCaching="true">
                <Animations>
                    <OnShow>
                        <Sequence>
                            <%-- Make the completion list transparent and then show it --%>
                            <OpacityAction Opacity="0" />
                            <HideAction Visible="true" />
                            
                            <%--Cache the original size of the completion list the first time
                                the animation is played and then set it to zero --%>
                            <ScriptAction Script="
                                // Cache the size and setup the initial size
                                var behavior = $find('AutoCompleteEx');
                                if (!behavior._height) {
                                    var target = behavior.get_completionList();
                                    behavior._height = target.offsetHeight - 2;
                                    target.style.height = '0px';
                                }" />
                            
                            <%-- Expand from 0px to the appropriate size while fading in --%>
                            <Parallel Duration=".4">
                                <FadeIn />
                                <Length PropertyKey="height" StartValue="0" EndValueScript="$find('AutoCompleteEx')._height" />
                            </Parallel>
                        </Sequence>
                    </OnShow>
                    <OnHide>
                        <%-- Collapse down to 0px and fade out --%>
                        <Parallel Duration=".4">
                            <FadeOut />
                            <Length PropertyKey="height" StartValueScript="$find('AutoCompleteEx')._height" EndValue="0" />
                        </Parallel>
                    </OnHide>
                </Animations>
                </ajaxToolkit:AutoCompleteExtender>              
    <div>
        &nbsp;&nbsp;<table>
            <tr>
                <td align="right" style="width: 52px">
                </td>
                <td align="right" style="width: 167px;">
                    <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Buscar Número" ForeColor="#336677"></asp:Label></td>
                <td colspan="3">
                
                <asp:TextBox runat="server" ID="myTextBox" Width="300" autocomplete="off"  AutoPostBack="true" OnTextChanged="CODIGOS_SelectedIndexChanged"/></td>
                
                    
            </tr>
            <tr>
                <td align="right" style="width: 52px">
                </td>
                <td align="right" style="width: 167px; height: 13px;">
                    <asp:Label ID="Label8" runat="server" Font-Bold="True" ForeColor="#336677" Text="Selección"></asp:Label></td>
                <td style="width: 167px; height: 13px;">
                    <asp:DropDownList ID="CODIGOS" runat="server" OnSelectedIndexChanged="CODIGOS_SelectedIndexChanged"
                        Width="320px" AutoPostBack="True" DataTextField=" " DataValueField=" ">
                    </asp:DropDownList></td>
                <td style="width: 79px; height: 13px;">
                </td>
                <td style="width: 79px; height: 13px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 52px">
                </td>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label1" runat="server" Text="Número" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 167px" align="left">
                    <asp:TextBox ID="NUMERO" runat="server" OnTextChanged="CODIGO_TextChanged"></asp:TextBox></td>
                <td align="left" height="1" style="width: 79px">
                </td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 52px">
                </td>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label3" runat="server" Text="Descripción" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="3" height="1">
                    <asp:TextBox ID="DESCRIPCION" runat="server" EnableTheming="True" Width="314px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 52px">
                </td>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label4" runat="server" Text="Unidad (3/4)" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 167px" align="left">
                    <asp:TextBox ID="UNIDAD" runat="server" Width="35px"></asp:TextBox></td>
                                        
                <td align="left" height="1" style="width: 79px">
                    </td>
                <td align="left" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 52px">
                </td>
                <td align="right" style="width: 167px; height: 24px;">
                    <asp:Label ID="Label2" runat="server" Text="Municipio" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td style="width: 167px; height: 24px;" align="left">
                    <asp:DropDownList ID="MUNICIPIO" runat="server" Width="160px">
                    </asp:DropDownList></td>
                <td align="left" style="width: 79px; height: 24px">
                </td>
                <td align="left" style="width: 79px; height: 24px">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 52px">
                </td>
                <td align="right" style="width: 167px">
                    <asp:Label ID="Label7" runat="server" Text="Observaciones" Font-Bold="True" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" height="1">
                    <asp:TextBox ID="OBSERVACIONES" runat="server" Width="238px"></asp:TextBox></td>
                <td align="left" colspan="1" height="1">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 52px; height: 26px;">
                </td>
                <td align="right" style="width: 167px; height: 26px;">
                    <asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="#336677" Text="Estado"></asp:Label></td>
                <td align="left" colspan="2" style="height: 26px">
                    <asp:TextBox ID="ESTADO" runat="server"></asp:TextBox></td>
                <td align="left" colspan="1" style="height: 26px">
                </td>
            </tr>
            <tr>
                <td align="center" colspan="1" style="width: 52px; height: 26px">
                </td>
                <td align="center" colspan="2" style="height: 26px">
                    <asp:Button ID="ImportarExcel" runat="server"
                        Font-Bold="True" ForeColor="#336677" OnClick="ImportarExcel_Click" Text="Importar"
                        ToolTip="Importar Datos desde Archivo Csv" Width="114px" />
                    <asp:Button ID="BtnNuevo" runat="server" OnClick="BtnNuevo_Click" Text="Nuevo" ForeColor="#336677" Font-Bold="True" />
                    <asp:Button ID="BtnActualizar" runat="server" Text="Acualizar" OnClick="BtnActualizar_Click" Font-Bold="True" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" />
                    <asp:Button ID="Eliminar" runat="server" Font-Bold="True" Font-Italic="False" Font-Overline="False"
                        Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Eliminar_Click"
                        Text="Eliminar" /></td>
                <td align="center" colspan="1" height="1" style="width: 79px">
                    <asp:Button ID="Imprimir" runat="server" Font-Bold="True" Font-Italic="False" Font-Overline="False"
                        Font-Strikeout="False" Font-Underline="False" ForeColor="#336677" OnClick="Imprimir_Click"
                        Text="Imprimir" /></td>
                <td align="center" colspan="1" height="1" style="width: 79px">
                </td>
            </tr>
            <tr>
                <td align="center" colspan="5" style="height: 26px; text-align: left">
                    <asp:Label ID="mensaje" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>    
</asp:Content>