﻿    <%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Entrada de Camiones" %>

<%@ Register Assembly="ClsControlesWeb" Namespace="HAAS.Web.Controles" TagPrefix="cc1" %>
<%@ Register
    Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="ajaxToolkit" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ import Namespace="System.IO.Ports" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Drawing" %>

<script runat="server">
    'Private WithEvents RS232 As New System.IO.Ports.SerialPort("COM1", 2400, IO.Ports.Parity.Even, 7, IO.Ports.StopBits.One)
    'Delegate Sub WriteDataDelegate(ByVal str As String)
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim Mensaje As String
        Dim ssql As String
        
        Mensaje = ""
        
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        Me.mensaje.Text = ""
        Me.FECHAENTREGA.Text = Format(Date.Now, "dd/MM/yyyy")
        If Not Page.IsPostBack Then
            Mensaje = BIBLIOTECA.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            
            Mensaje = ""
            conn = BIBLIOTECA.Conectar(Mensaje)
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Mensaje
            
            ssql = "SELECT NUMERO,NOMBRE FROM MUNICIPIOS"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "MUNICIPIOS")
            'Combo1 Usuarios
            Me.MUNICIPIO.DataSource = DtSet.Tables("MUNICIPIOS").DefaultView
            Me.MUNICIPIO.DataTextField = "NOMBRE"
            ' Asigna el valor del value en el DropDownList
            Me.MUNICIPIO.DataValueField = "NUMERO"
            Me.MUNICIPIO.DataBind()
            'CARGAR PROVEEDORES
            ssql = " SELECT CAST(LEFT(MINAS.NUMERO, CHARINDEX('/', MINAS.NUMERO+ '/') -1) AS INT) AS ORDEN, MINAS.NUMERO" & _
                   " FROM Minas " & _
                   " WHERE ESTADO = 'AC'" & _
                   " UNION " & _
                   " SELECT '', '..' AS NUMERO1 " & _
                   " FROM COOPERATIVAS AS COOPERATIVAS_1"
            DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
            DtAdapter.Fill(DtSet, "MINAS")
            Me.PROVEEDOR.DataSource = DtSet.Tables("MINAS").DefaultView
            Me.PROVEEDOR.DataTextField = "NUMERO"
            Me.PROVEEDOR.DataValueField = "NUMERO"
            Me.PROVEEDOR.DataBind()
            BIBLIOTECA.DesConectar(conn)
            
        End If
        Me.txtCodBarras.Focus()
        
        
    End Sub
    
    Protected Sub PROVEEDOR_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim ValorMensaje As Double = 0 'Valor para controlar mensaje de aviso para control de ingreso
        Dim ssQl As String
        Dim Mensaje As String = ""
        Dim MensajeMuestraCreada As String = ""
        Dim AcumMuestra As Double = 0 'Acumulado en kg por muestra
        Dim CupoMuestra As Double = 0 'Cupo Limite pra completar cuarteo
        
        Try
            conn = BIBLIOTECA.Conectar(Mensaje)
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Mensaje
            
            ValorMensaje = Val(BIBLIOTECA.ValorParametro("FALTANTEPE"))
            CupoMuestra = Val(BIBLIOTECA.ValorParametro("PESOXMUEST"))
                        
            ssQl = " SELECT COOPERATIVAS.DESCRIPCION, MINAS.CUPOLIMITE, COOPERATIVAS.ENTREGAS, MINAS.KGS_ACUM, MINAS.DESCRIPCION AS PROVEEDOR, MINAS.MUNICIPIO, MINAS.NUMERO" & _
                   " FROM COOPERATIVAS CROSS JOIN MINAS " & _
                   " WHERE MINAS.NUMERO='" & Trim(Me.PROVEEDOR.Text) & "' AND COOPERATIVAS.NUMERO = '" & BIBLIOTECA.ContrCoopMina(Trim(Me.PROVEEDOR.Text), 2) & "'"
            
            
            dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)
            'Page.FindControl("TextBox")
            If dTReader.Read() Then
                If dTReader("KGS_ACUM") >= dTReader("CUPOLIMITE") * 1000 Then
                    Me.mensaje.ForeColor = Color.Red
                    Me.mensaje.Text = "EL PROVEEDOR " & Trim(dTReader("PROVEEDOR")) & " HA COMPLETADO SU CUPO MENSUAL, " & vbCrLf & " NO SE PERMITEN MAS REGISTROS DE ENTREGA"
                    BIBLIOTECA.MostrarMensaje(Page, "EL PROVEEDOR " & Trim(dTReader("PROVEEDOR")) & " HA COMPLETADO SU CUPO MENSUAL, " & " NO SE PERMITEN MAS REGISTROS DE ENTREGA", 2)
                    Me.PROVEEDOR.Text = ".."
                    Exit Sub
                End If
                If ValorMensaje >= ((dTReader("CUPOLIMITE") * 1000) - dTReader("KGS_ACUM")) Then
                    Me.mensaje.ForeColor = Color.Red
                    Me.mensaje.Text = "AL PROVEEDOR " & Trim(dTReader("PROVEEDOR")) & " LE FALTAN " & vbCrLf & (dTReader("CUPOLIMITE") * 1000 - dTReader("KGS_ACUM")) & " Kg PARA ALCANZAR SU CUPO MENSUAL"
                    BIBLIOTECA.MostrarMensaje(Page, "AL PROVEEDOR " & Trim(dTReader("PROVEEDOR")) & " LE FALTAN " & (dTReader("CUPOLIMITE") * 1000 - dTReader("KGS_ACUM")) & " Kg PARA ALCANZAR SU CUPO MENSUAL", 2)
                End If
                
                Me.PROVEEDOR1.Text = dTReader("PROVEEDOR")
                Me.COOPERATIVA.Text = dTReader("DESCRIPCION")
                Me.MUNICIPIO.Text = dTReader("MUNICIPIO")
                Me.NOMMUNICIPIO.Text = Trim(Me.MUNICIPIO.SelectedItem.Text)
                Me.NUMEROENTREGA.Text = dTReader("ENTREGAS")
                Me.HORAENTREGA.Text = Format(Date.Now, "hh:mm:ss tt")
                Me.PesoT.Text = 0
                Me.VEHICULO.Text = ""
                'Me.CONDUCTOR.Text = ""
                
                Me.NUMEROMUESTRA.Text = BIBLIOTECA.CalcularNumeroMuestra(MensajeMuestraCreada, Me.FECHAENTREGA.Text, BIBLIOTECA.ContrCoopMina(Trim(Me.PROVEEDOR.Text), 2))
                Me.AcumMuestra.Text = BIBLIOTECA.KgAcumMuestra(Me.NUMEROMUESTRA.Text)
                If CupoMuestra - Me.AcumMuestra.Text <= ValorMensaje Then
                    Me.mensaje.ForeColor = Color.Red
                    Me.mensaje.Text = Me.mensaje.Text & ";A LA COOPERATIVA " & Trim(dTReader("DESCRIPCION")) & " LE FALTAN " & vbCrLf & CupoMuestra - Me.AcumMuestra.Text & " Kg PARA ALCANZAR CUARTEO PROMEDIO"
                    BIBLIOTECA.MostrarMensaje(Page, "A LA COOPERATIVA " & Trim(dTReader("DESCRIPCION")) & " LE FALTAN " & CupoMuestra - Me.AcumMuestra.Text & " Kg PARA ALCANZAR CUARTEO PROMEDIO", 2)
                End If
                
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = Me.mensaje.Text & IIf(MensajeMuestraCreada <> "", "; LA COOPERATIVA " & Trim(dTReader("DESCRIPCION")) & " HA INICIADO UN NUEVO CUARTEO PROMEDIO", "")
                Me.AcumCoop.Text = dTReader("KGS_ACUM")
                If MensajeMuestraCreada <> "" Then
                    BIBLIOTECA.MostrarMensaje(Page, "LA COOPERATIVA " & Trim(dTReader("DESCRIPCION")) & " HA INICIADO UN NUEVO CUARTEO PROMEDIO", 2)
                End If
                'sacar consecutivo y aplicarlo a la interfaz
                lblConsecutivo.Text = BIBLIOTECA.GetContador(BIBLIOTECA.ContrCoopMina(Trim(Me.PROVEEDOR.Text), 2), "1")
                
                
                
                
                
                
                
                
                
            Else
                'MsgBox("Proveedor Inexistente. " & vbCrLf & "Por favor, verificar.", MsgBoxStyle.Information, "C.E.S.")
                Me.mensaje.ForeColor = Color.Red
                Me.mensaje.Text = "Proveedor Inexistente. " & vbCrLf & "Por favor, verificar."
                BIBLIOTECA.MostrarMensaje(Page, "Proveedor Inexistente. " & "Por favor, verificar.", 2)
                Me.PROVEEDOR1.Text = ""
                Me.COOPERATIVA.Text = ""
                Me.MUNICIPIO.Text = "002"
                Me.NOMMUNICIPIO.Text = Trim(Me.MUNICIPIO.SelectedItem.Text)
                Me.HORAENTREGA.Text = ""
                Me.NUMEROENTREGA.Text = ""
                Me.NUMEROMUESTRA.Text = ""
                Me.AcumCoop.Text = 0
                Me.AcumMuestra.Text = 0
                Me.PesoT.Text = 0
            End If
            Me.VEHICULO.Focus()
            dTReader.Close()
            BIBLIOTECA.DesConectar(conn)
        Catch ex As Exception
            'MsgBox("Error" & ex.Message)
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = ex.Message
        End Try
    End Sub

    Protected Sub VEHICULO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim ssQl As String
        Dim Mensaje As String
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssQl = " SELECT *  FROM CONDUCTORESVEHICULOS WHERE PLACAS ='" & Trim(Me.VEHICULO.Text) & "'"
        dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)
        If not dTReader.HasRows Then
            'MsgBox("El vehículo " & Me.VEHICULO.Text & " está Restringido." & vbCrLf & "NO PUEDE INGRESAR A LA PLANTA", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El vehículo " & Me.VEHICULO.Text & " no se encuentra en la BD" & vbCrLf & "NO PUEDE INGRESAR A LA PLANTA"
            BIBLIOTECA.MostrarMensaje(Page, "El vehículo " & Me.VEHICULO.Text & " no se encuentra en la BD" & " NO PUEDE INGRESAR A LA PLANTA", 2)
            Me.VEHICULO.Text = ""
            dTReader.Close()
            Me.VEHICULO.Focus()
           
        End If
         BIBLIOTECA.DesConectar(conn) 
         conn = BIBLIOTECA.Conectar(Mensaje)
        If Len(Me.VEHICULO.Text) > 6 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "La placa del vehículo (" & Me.VEHICULO.Text & ") no puede ser superior a 6 caracteres"
            BIBLIOTECA.MostrarMensaje(Page, "La placa del vehículo (" & Me.VEHICULO.Text & ") no puede ser superior a 6 caracteres", 2)
            Me.VEHICULO.Text = ""
            Me.VEHICULO.Focus()
            Exit Sub
        End If
        ssQl = " SELECT CAMIONESREST.MATRICULA" & _
               " FROM CAMIONESREST " & _
               " WHERE CAMIONESREST.MATRICULA='" & Trim(Me.VEHICULO.Text) & "'"
        dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)
        If dTReader.Read() Then
            'MsgBox("El vehículo " & Me.VEHICULO.Text & " está Restringido." & vbCrLf & "NO PUEDE INGRESAR A LA PLANTA", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El vehículo " & Me.VEHICULO.Text & " está Restringido." & vbCrLf & "NO PUEDE INGRESAR A LA PLANTA"
            BIBLIOTECA.MostrarMensaje(Page, "El vehículo " & Me.VEHICULO.Text & " está Restringido." & " NO PUEDE INGRESAR A LA PLANTA", 2)
            Me.VEHICULO.Text = ""
            dTReader.Close()
            Me.VEHICULO.Focus()
        End If
        Me.VEHICULO.Text = UCase(Me.VEHICULO.Text)
        'Me.CONDUCTOR.Focus()
        dTReader.Close()
        BIBLIOTECA.DesConectar(conn)
    End Sub

   
   
    Protected Sub Peso_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ''SYSTEMBE.SYS = ARCHIVO PLANO PARA PESOS DE ENTRADA
        Dim PlanosBasc As New ArchivosPlanos
        Me.PesoT.Text = PlanosBasc.LeerArchivoBascula("C:\temp\SYSTEMBE.SYS")
        PlanosBasc.GeneraArchivoBascula("C:\temp", "SYSTEMBE.SYS", 0)
    End Sub
    
    Private Function RecortarCadena(ByVal CadenaRec As String) As String
        Try
            If InStr(1, CadenaRec, "Kg") > 0 Then
                RecortarCadena = Right(Left(CadenaRec, InStr(1, CadenaRec, "Kg") - 1), 6)
            Else
                Return 0
            End If
        Catch ex As Exception
            Return 0
        End Try
    End Function

    Protected Sub Guardar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim conn As SqlConnection
        Dim ssql As String
        Dim Mensaje As String
        Dim Seguridad As New Seguridad
        
        Mensaje = ""
        ssql = ""
        Me.VEHICULO.Text = UCase(Me.VEHICULO.Text)
        If Me.PROVEEDOR.Text = "" Then
            'MsgBox("Debe digitar el código del proveedor", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Debe digitar el código del proveedor"
            Biblioteca.MostrarMensaje(Page, "Debe digitar el código del proveedor", 2)
            Exit Sub
        End If
        If Me.VEHICULO.Text = "" Then
            'MsgBox("Debe digitar la placa del vehículo", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Debe digitar la placa del vehículo"
            Biblioteca.MostrarMensaje(Page, "Debe digitar la placa del vehículo", 2)
            Exit Sub
        End If
        
        
        If Me.PesoT.Text <= 0 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El peso de entrada no puede ser cero 0 "
            Biblioteca.MostrarMensaje(Page, "El peso de entrada no puede ser cero 0 ", 2)
            Exit Sub
        End If
                
        ssql = " INSERT INTO ENTREGAS ( FECHAENTREGA, HORAENTREGA,  NUMEROENTRADA, MUESTRAGEN, COOPERATIVA, CONDUCTOR, CAMION, MUNICIPIO, MINA, PESOENTRADA, OPERARIOBASCULA, TOMADORMUESTRA, OBSERVACION_ETR, ESTADO, IMPRESIONESENT)" & _
               " VALUES (CONVERT(DATETIME,'" & Format(CDate(Me.FECHAENTREGA.Text), "yyyy-MM-dd 00:00:00") & "',102), '" & Replace(Format(CDate(Me.HORAENTREGA.Text), "hh:mm:ss tt"), ".", "") & "' , '" & Trim(Me.PROVEEDOR.Text) & "/" & Trim(Me.NUMEROENTREGA.Text) & "' , '" & Me.NUMEROMUESTRA.Text & "' , '" & Biblioteca.ContrCoopMina(Trim(Me.PROVEEDOR.Text), 2) & "', '" & Me.CONDUCTOR.SelectedValue & "', '" & Me.VEHICULO.Text & "', '" & Me.MUNICIPIO.Text & "', '" & Trim(Me.PROVEEDOR.Text) & "', '" & Me.PesoT.Text & "', '" & Session("USUARIO") & "', '" & Session("TomaMuestras") & "', '" & Me.OBSERVACIONES.Text & "','AC',0)"
                
        conn = Biblioteca.Conectar(Mensaje)
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            Biblioteca.GetContador(Me.PROVEEDOR.Text, "0")
            Seguridad.RegistroAuditoria(Session("Usuario"), "Insertar", "EntregasBascula", "Numero:" & Me.PROVEEDOR.Text & "/" & Trim(Me.NUMEROENTREGA.Text) & ";Peso:" & Me.PesoT.Text & ";Muestra:" & Me.NUMEROMUESTRA.Text & ";AcumCoop:" & Me.AcumCoop.Text & ";AcumMuestra:" & Me.AcumMuestra.Text, Session("GRUPOUS"))
            
            ssql = " UPDATE MINAS SET MINAS.ENTREGAS = [minas].[entregas]+1 " & _
                   " WHERE MINAS.NUMERO='" & Trim(Me.PROVEEDOR.Text) & "'"
            Biblioteca.EjecutarSql(Mensaje, ssql)
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Mensaje
            
            ssql = " UPDATE COOPERATIVAS SET COOPERATIVAS.ENTREGAS = [cooperativas].[entregas]+1 " & _
                  " WHERE COOPERATIVAS.NUMERO='" & Biblioteca.ContrCoopMina(Trim(Me.PROVEEDOR.Text), 2) & "'"
            Biblioteca.EjecutarSql(Mensaje, ssql)
            
            ''Imprimir
            ssql = "SELECT ENTREGAS.NUMEROENTRADA, ENTREGAS.PESOENTRADA, ENTREGAS.FECHAENTREGA, ENTREGAS.OPERARIOBASCULA, " & _
                          " ENTREGAS.OBSERVACION_ETR, MUNICIPIOS.NOMBRE AS MUNICIPIO, MINAS.DESCRIPCION AS MINA, " & _
                          " COOPERATIVAS.DESCRIPCION AS COOPERATIVA, ENTREGAS.CONDUCTOR, ENTREGAS.CAMION, ENTREGAS.MUESTRAGEN, ENTREGAS.HORAENTREGA, ENTREGAS.HORASALIDA" & _
                   " FROM   ENTREGAS LEFT OUTER JOIN MUNICIPIOS ON ENTREGAS.MUNICIPIO = MUNICIPIOS.NUMERO LEFT OUTER JOIN " & _
                          " MINAS ON ENTREGAS.MINA = MINAS.NUMERO LEFT OUTER JOIN COOPERATIVAS ON ENTREGAS.COOPERATIVA = COOPERATIVAS.NUMERO" & _
                   " WHERE ENTREGAS.NUMEROENTRADA = '" & Trim(Me.PROVEEDOR.Text) & "/" & Trim(Me.NUMEROENTREGA.Text) & "'"
            
            
            Session("SqlReporte") = ssql
            Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE ENTRADA")
            Session("Parametro") = Me.FECHAENTREGA.Text
            Session("NombreDataTable") = "Entregas"
            Limpiar()
            Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
            'Fin Imprimir         
            
            'Response.Redirect("EntradaCarbon.aspx")
        Else
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Mensaje
        End If
        Biblioteca.DesConectar(conn)
    End Sub
    
    Private Sub Limpiar()
        Me.PROVEEDOR1.Text = ""
        Me.COOPERATIVA.Text = ""
        Me.MUNICIPIO.Text = "002"
        Me.NOMMUNICIPIO.Text = Trim(Me.MUNICIPIO.SelectedItem.Text)
        Me.HORAENTREGA.Text = ""
        Me.NUMEROENTREGA.Text = ""
        Me.NUMEROMUESTRA.Text = ""
        Me.AcumCoop.Text = 0
        Me.AcumMuestra.Text = 0
        Me.OBSERVACIONES.Text = ""
        Me.PROVEEDOR.Text = ".."
        Me.mensaje.Text = ""
        Me.FECHAENTREGA.Text = ""
        Me.HORAENTREGA.Text = ""
        Me.lblConsecutivo.Text = ""
        Me.VEHICULO.Text = ""
        Me.PesoT.Text = 0
    End Sub

    
    Protected Sub MUNICIPIO_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub txtCodBarras_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim v_proveedor As String
        Dim sqlSlect = "SELECT Proveedor FROM CODIGO_BARRAS WHERE [Codigo_Barras]='" + txtCodBarras.Text + "'"
      
        
        Dim Mensaje As String
        
        
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        dTReader = Biblioteca.CargarDataReader(Mensaje, sqlSlect, conn)
        If dTReader.Read() Then
            Try
                v_proveedor = dTReader("Proveedor")
                PROVEEDOR.Text = v_proveedor
            
                dTReader.Close()
                conn.Close()
            
                PROVEEDOR_SelectedIndexChanged(sender, e)
            Catch ex As Exception
                
            End Try
            
            
        End If
        
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    
<script language="JavaScript" type="text/javascript" > 

function AbrirPuertoCliente_onclick() 
{
try 
    {
       //document.getElementById('ctl00_ContentPlaceHolder1_ConPuerto').MostraMensaje;    
    document.getElementById('ConPuerto').MostraMensaje;    
    document.getElementById('ConPuerto').AbrirPuerto;      
    }
catch(mierror)
    {
        alert("Error detectado: " + mierror.description)
    }  
}

function LeerPeso_onclick() {
//   celda = document.getElementById("celda" + document.fcolor.celda.value) 
 //  celda.style.backgroundColor=document.fcolor.micolor.value 

    document.getElementById('ctl00_ContentPlaceHolder1_PesoT').value= document.getElementById('ctl00_ContentPlaceHolder1_ConPuerto').leerPuerto;
}

function CerrarPuerto_onclick() {
    document.getElementById('ctl00_ContentPlaceHolder1_ConPuerto').CerrarPuerto;
}

function Button1_onclick() {

}

</script>
    <div>
    <table border="1" bordercolor="#CCCCCC"> <!-- TABLA USADA COMO MARCO DEL FORMULARIO-->
    <tr>
    <td>
    
    <table border="0">
            <tr>
                <td align="center" colspan="5" style="border-right: #cccccc thin solid; border-top: #cccccc thin solid; border-left: #cccccc thin solid; border-bottom: #cccccc thin solid; height: 25px;">
                    <asp:Label ID="Label11" runat="server" Font-Bold="True" ForeColor="#336677" Text="Entrada de Carbón" Width="278px"></asp:Label></td>
            </tr>
            <tr>
                <td align="center" colspan="5" style="height: 13px">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        
        </asp:ScriptManager>
             
                    <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" DeleteMethod="Delete"
                        InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData"
                        TypeName="DataSet1TableAdapters.CONDUCTORESVEHICULOS2TableAdapter" UpdateMethod="Update">
                        <DeleteParameters>
                            <asp:Parameter Name="Original_conductor" Type="String" />
                            <asp:Parameter Name="Original_placas" Type="String" />
                            <asp:Parameter Name="Original_cedula" Type="String" />
                        </DeleteParameters>
                        <UpdateParameters>
                            <asp:Parameter Name="Original_conductor" Type="String" />
                            <asp:Parameter Name="Original_placas" Type="String" />
                            <asp:Parameter Name="Original_cedula" Type="String" />
                        </UpdateParameters>
                        <SelectParameters>
                            <asp:ControlParameter ControlID="VEHICULO" DefaultValue=" " Name="PLACA" PropertyName="Text"
                                Type="String" />
                        </SelectParameters>
                        <InsertParameters>
                            <asp:Parameter Name="conductor" Type="String" />
                            <asp:Parameter Name="placas" Type="String" />
                            <asp:Parameter Name="cedula" Type="String" />
                        </InsertParameters>
                    </asp:ObjectDataSource>
                </td>
            </tr>
            <tr>
                <td style="width: 106px; height: 37px;" align="left">
                    <asp:Label ID="Label1" runat="server" Text="Fecha de Entrega" Width="112px" ForeColor="#336677"></asp:Label></td>
                <td style="width: 193px; height: 37px;">
                    <asp:TextBox ID="FECHAENTREGA" runat="server" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 82px; height: 37px;">
                </td>
                <td style="width: 98px; height: 37px;">
                    <asp:Label ID="Label15" runat="server" ForeColor="#336677" Text="Grupo de fichas "
                        Width="148px"></asp:Label></td>
                <td style="width: 100px; height: 37px;">
				<asp:Label ID="lblConsecutivo" runat="server" ForeColor="Green" Width="148px" Font-Bold="True" Font-Size="Large"></asp:Label>
                    </td>
            </tr>
            <tr>
                <td style="width: 106px; height: 26px;" align="left">
                    <asp:Label ID="Label2" runat="server" Text="Hora Entrega" Width="112px" ForeColor="#336677"></asp:Label></td>
                <td style="width: 193px; height: 26px;">
                    <asp:TextBox ID="HORAENTREGA" runat="server" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 82px; height: 26px">
                </td>
                <td style="width: 98px; height: 26px">
				<asp:Label ID="Label3" runat="server" Text="Número de Entrega" Width="130px" ForeColor="#336677"></asp:Label>
                    </td>
                <td style="width: 100px; height: 26px;">
                    <asp:TextBox ID="NUMEROENTREGA" runat="server" ReadOnly="True"></asp:TextBox></td>
            </tr>
            <tr>
                <td style="width: 106px; height: 3px;" align="left">
                    <asp:Label ID="Label16" runat="server" ForeColor="#336677" Text="Código de barras"
                        Width="112px"></asp:Label></td>
                <td style="height: 3px; width: 193px;">
                    <asp:TextBox ID="txtCodBarras" runat="server" OnTextChanged="txtCodBarras_TextChanged"></asp:TextBox></td>
                <td style="height: 3px" width="2">
                </td>
                <td style="height: 3px" width="2">
                </td>
                <td style="height: 3px;" width="2">
                </td>
            </tr>
            <tr>
                <td style="width: 106px; height: 29px;" align="left">
                    <asp:Label ID="Label4" runat="server" Text="Proveedor" ForeColor="#336677"></asp:Label></td>
                <td style="width: 193px; height: 29px;">
                    <asp:DropDownList ID="PROVEEDOR" runat="server" OnSelectedIndexChanged="PROVEEDOR_SelectedIndexChanged"
                        Width="150px" AutoPostBack="True">
                    </asp:DropDownList></td>
                <td colspan="2" style="height: 29px">
                    <asp:TextBox ID="PROVEEDOR1" runat="server" Width="202px" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 100px; height: 29px;">
                </td>
            </tr>
            <tr>
                <td style="width: 106px; height: 26px;" align="left">
                    <asp:Label ID="Label5" runat="server" Text="Cooperativa" ForeColor="#336677"></asp:Label></td>
                <td colspan="3" style="height: 26px">
                    <asp:TextBox ID="COOPERATIVA" runat="server" Width="361px" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 100px; height: 26px;">
                </td>
            </tr>
            <tr>
                <td style="width: 106px" align="left">
                    <asp:Label ID="Label6" runat="server" Text="Municipio" ForeColor="#336677"></asp:Label></td>
                <td style="width: 193px">
                    <asp:TextBox ID="NOMMUNICIPIO" runat="server" AutoPostBack="True" OnTextChanged="VEHICULO_TextChanged" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 82px">
                    <asp:DropDownList ID="MUNICIPIO" runat="server" Width="80px" Enabled="False" OnSelectedIndexChanged="MUNICIPIO_SelectedIndexChanged" Visible="false">
                    </asp:DropDownList></td>
                <td style="width: 98px">
                </td>
                <td style="width: 100px">
                </td>
            </tr>
            <tr>
                <td style="width: 106px; height: 26px;" align="left">
                    <asp:Label ID="Label7" runat="server" Text="Vehículo" ForeColor="#336677"></asp:Label></td>
                <td style="width: 193px; height: 26px;">
                    <asp:TextBox ID="VEHICULO" runat="server" OnTextChanged="VEHICULO_TextChanged" AutoPostBack="True"></asp:TextBox></td>
                <td colspan="2" style="height: 26px">
                    &nbsp;<asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server"
                        ControlToValidate="VEHICULO" ErrorMessage="Placa no válida" ValidationExpression="\w\w\w\w\w\w" Width="158px" Visible="False"></asp:RegularExpressionValidator>Presione
                    Enter para consultar conductores</td>
                <td style="width: 100px; height: 26px;">
                </td>
            </tr>
            <tr>
                <td style="width: 106px; height: 26px;" align="left">
                    <asp:Label ID="Label8" runat="server" Text="Conductor" ForeColor="#336677"></asp:Label></td>
                <td style="width: 193px; height: 26px;">
                    <asp:ListBox ID="CONDUCTOR" runat="server" DataSourceID="ObjectDataSource1" DataTextField="CONDUCTOR" DataValueField="CONDUCTOR" Rows="3" Width="265px"></asp:ListBox></td>
                <td style="width: 82px; height: 26px">
                </td>
                <td style="height: 26px" align="right">
                    &nbsp;
                    &nbsp;<asp:Button ID="Btn_NoQuitar" runat="server" Text="R" Height="0px" Width="0px" />
                    &nbsp;
                     <!--<OBJECT classid="clsid:65AD5FCC-C2F4-4B9B-B8B8-C084B148B3EC"> -->
                </td>
                <td style="height: 26px">
                    &nbsp;</td>                    
            </tr>
            
            <tr>
                <td colspan="2" style="height: 21px">
                    <asp:Label ID="Label9" runat="server" Font-Bold="True" Text="# Muestra" Width="211px" ForeColor="#336677" Visible="False"></asp:Label></td>
                <td style="height: 21px" align="center" colspan="3">
                    <asp:Label ID="Label10" runat="server" Font-Bold="True" Text="Información de Carga de Ingreso"
                        Width="293px" ForeColor="#336677"></asp:Label></td>
            </tr>
            <tr>
                <td style="width: 106px; height: 26px;" align="left">
                    <asp:TextBox ID="NUMEROMUESTRA" runat="server" Height="21px" Width="109px" Enabled="False" Visible="False"></asp:TextBox></td>
                <td style="width: 193px; height: 26px;">
                </td>
                <td style="width: 82px; height: 26px;">
                </td>
                <td style="width: 98px; height: 26px;" align="right">
                    &nbsp;<asp:Button ID="Peso" runat="server" Text="Peso " Font-Bold="True" OnClick="Peso_Click" Width="87px" ForeColor="#336677" /></td>
                <td style="width: 100px; height: 26px;">
                    <asp:TextBox ID="PesoT" runat="server"></asp:TextBox></td>
            </tr>
            <tr>
                <td style="width: 106px" align="left">
                    <asp:Label ID="Label12" runat="server" Text="Observaciones" ForeColor="#336677"></asp:Label></td>
                <td colspan="4" rowspan="2">
                    <asp:TextBox ID="OBSERVACIONES" runat="server" Width="538px" Height="22px" Rows="3" TextMode="MultiLine" Wrap="False"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="left" style="width: 106px; height: 2px;">
                </td>
            </tr>
            <tr>
                <td align="left" style="width: 106px; height: 4px;">
                </td>
                <td colspan="4" style="height: 4px">
                    <asp:Label ID="mensaje" runat="server" Height="28px" Width="544px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" style="width: 106px;">
                    <asp:Label ID="Label13" runat="server" Font-Bold="True" ForeColor="#336677" Text="Kg Coop."
                        Width="94px"></asp:Label></td>
                <td align="left" colspan="1" style="width: 193px;">
                    <asp:Label ID="AcumCoop" runat="server" Font-Bold="True" ForeColor="Blue" Width="110px"></asp:Label></td>
                    <td>
                <asp:Label ID="Label14" runat="server" Font-Bold="True" ForeColor="#336677" Text="Kg Muestra"
                    Width="85px"></asp:Label></td>
                    <td>
                        <asp:Label ID="AcumMuestra" runat="server" Font-Bold="True" ForeColor="Blue" Width="111px"></asp:Label></td>
                    <td>
                    <asp:Button
                        ID="Guardar" runat="server" Font-Bold="True" Text="Guardar" OnClick="Guardar_Click" ForeColor="#336677" /></td>
            </tr>
        <tr>
            <td align="left" style="width: 106px;">
                </td>
                    <td style="width: 193px">
                        </td>
                    <td>
                    </td>
                    <td>
                    </td>
            <td align="center" colspan="1">
            </td>
        </tr>
        </table>
    
    </td>
    </tr>
    </table>
    
        
    </div>    
</asp:Content>