    <%@ Page Language="VB" MasterPageFile="~/MasterPage.master" Title="Salida de Camiones" %>

<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Data.SqlClient" %>
<%@ import Namespace="System.IO.Ports" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Drawing" %>

<script runat="server">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("Usuario") = "" Then
            Response.Redirect("Login.aspx")
        End If
        If Not Page.IsPostBack Then
            Inicio()
        End If
    End Sub
    
    Private Sub Inicio()
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        
        Dim ssql As String
        Me.mensaje.Text = ""        
            Dim Mensaje As String = ""
            
            Mensaje = Biblioteca.ComprobarAcceso(Session("GRUPOUS"), Replace(Replace(Form.Page.ToString, "_", "."), "ASP.", ""))
            If Mensaje = "" Then
                Response.Redirect("Principal.aspx")
            Else
                CType(Master.FindControl("Label1"), Label).Text = Mensaje
            End If
            Mensaje = ""
            
            conn = Biblioteca.Conectar(Mensaje)
        ssql = " SELECT NUMEROENTRADA" & _
               " FROM ENTREGAS" & _
               " WHERE ESTADO = 'AC'" & _
               " UNION " & _
               " SELECT '..' AS NUMEROENTRADA1" & _
               " FROM ENTREGAS AS ENTREGAS_1"
            DtAdapter = Biblioteca.CargarDataAdapter(ssql, conn)
            DtSet = New DataSet
            ' Define el tipo de ejecución como procedimiento almacenado            
            DtAdapter.Fill(DtSet, "ENTREGAS")
            'Combo1 Usuarios
            Me.NENTRADA.DataSource = DtSet.Tables("ENTREGAS").DefaultView
            Me.NENTRADA.DataTextField = "NUMEROENTRADA"
            ' Asigna el valor del value en el DropDownList
            Me.NENTRADA.DataValueField = "NUMEROENTRADA"
            Me.NENTRADA.DataBind()
            'CARGAR PROVEEDORES            
            Biblioteca.DesConectar(conn)        
    End Sub
        
    Protected Sub NENTRADA_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim ssQl As String
        Dim Mensaje As String
        Mensaje = ""
        Try
            conn = BIBLIOTECA.Conectar(Mensaje)
        
            ssQl = " SELECT ENTREGAS.FECHAENTREGA, ENTREGAS.NUMEROENTRADA, ENTREGAS.MUESTRAGEN, ENTREGAS.HORAENTREGA, ENTREGAS.PESOENTRADA, ENTREGAS.PESOSALIDA, ENTREGAS.CONDUCTOR, ENTREGAS.CAMION, ENTREGAS.MUESTRAESP, COOPERATIVAS.DESCRIPCION AS COOPERATIVA, MINAS.KGS_ACUM, MINAS.CUPOLIMITE, MUNICIPIOS.NOMBRE AS MUNICIPIO, MINAS.DESCRIPCION AS MINA" & _
                   " FROM ((ENTREGAS LEFT JOIN COOPERATIVAS ON ENTREGAS.COOPERATIVA = COOPERATIVAS.NUMERO) LEFT JOIN MINAS ON ENTREGAS.MINA = MINAS.NUMERO) LEFT JOIN MUNICIPIOS ON ENTREGAS.MUNICIPIO = MUNICIPIOS.NUMERO" & _
                   " WHERE ENTREGAS.NUMEROENTRADA='" & Me.NENTRADA.Text & "'"
            dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)
        
            If dTReader.Read() Then
                Me.PROVEEDOR.Text = dTReader("MINA")
                Me.COOPERATIVA.Text = dTReader("COOPERATIVA")
                Me.MUNICIPIO.Text = dTReader("MUNICIPIO")
                Me.HINGRESO.Text = Format(dTReader("HORAENTREGA"), "hh:mm:ss tt")
                Me.CONDUCTOR.Text = dTReader("CONDUCTOR")
                Me.HSALIDA.Text = Format(Date.Now, "hh:mm:ss tt")
                Me.VEHICULO.Text = dTReader("CAMION")
                Me.PESOENTRADA.Text = dTReader("PESOENTRADA")
                Me.MUESTRAGENERADA.Text = dTReader("MUESTRAGEN")
                'If (dTReader("MUESTRAESP").ToString <> DBNull.Value) Then
                '    
                '            End If
                Me.NumMuestraEsp.Text = dTReader("MUESTRAESP").ToString
                Me.KgCoop.Text = dTReader("KGS_ACUM")
                Me.KgMuestra.Text = BIBLIOTECA.KgAcumMuestra(Me.MUESTRAGENERADA.Text)
                Me.CupoLimite.Text = dTReader("CupoLimite")
            Else
                'MsgBox("No existe registro de entrada con este número", MsgBoxStyle.Information, "C.E.S.")
                Me.mensaje.Text = "No existe registro de entrada con este número"
                Me.PROVEEDOR.Text = ""
                Me.COOPERATIVA.Text = ""
                Me.MUNICIPIO.Text = ""
                Me.HINGRESO.Text = ""
                Me.CONDUCTOR.Text = ""
                Me.HSALIDA.Text = ""
                Me.VEHICULO.Text = ""
                Me.PESOENTRADA.Text = 0
                Me.MUESTRAGENERADA.Text = ""
            End If
            dTReader.Close()
            'CERRAR LA CONEXION
            BIBLIOTECA.DesConectar(conn)
        Catch ex As Exception
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = ex.Message
            'MsgBox(ex.Message)
        End Try
    End Sub
         
    Protected Sub PESOENTR_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'SYSTEMBS.SYS ARCHIVO PLANO DE BASCULA PESO DE SALIDA        
        Dim PlanosBasc As New ArchivosPlanos
        Dim Biblioteca As New Biblioteca
        Dim KgLimitePorMuestra As Integer
        Dim ValorMensaje As Integer
        Dim VarKgMuestra As Integer
        Dim VarPesoNeto As Double
        Dim VarKgCoop As Integer
        
        
        If Me.NENTRADA.Text = "" Then
            Exit Sub
        End If
        
        ValorMensaje = 0
        ValorMensaje = Val(Biblioteca.ValorParametro("FALTANTEPE"))
        VarKgMuestra = Val(Me.KgMuestra.Text)
        
        
        KgLimitePorMuestra = Biblioteca.ValorParametro("PESOXMUEST")
        
        Me.mensaje.Text = ""
        Me.PESOSALIDA.Text = PlanosBasc.LeerArchivoBascula("C:\temp\SYSTEMBE.SYS")
        Me.PESONETO.Text = Me.PESOENTRADA.Text - Me.PESOSALIDA.Text
        VarPesoNeto = Me.PESONETO.Text
        VarKgCoop = Val(Me.KgCoop.Text)
        
        PlanosBasc.GeneraArchivoBascula("C:\temp", "SYSTEMBE.SYS", 0)
                
        If VarKgMuestra + VarPesoNeto >= KgLimitePorMuestra Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "EL PROVEEDOR " & Me.COOPERATIVA.Text & " HA COMPLETADO CUARTEO PROMEDIO " & vbCrLf & " EN LA PROXIMA ENTREGA SE GENERARA UNA NUEVA MUESTRA"
            Biblioteca.MostrarMensaje(Page, "EL PROVEEDOR " & Me.COOPERATIVA.Text & " HA COMPLETADO CUARTEO PROMEDIO " & " EN LA PROXIMA ENTREGA SE GENERARA UNA NUEVA MUESTRA", 2)
            Me.MuestraOk.Checked = True
        ElseIf KgLimitePorMuestra - (VarKgMuestra + VarPesoNeto) <= ValorMensaje Then
            Me.MuestraOk.Checked = False
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "FALTAN " & vbCrLf & KgLimitePorMuestra - (VarKgMuestra + VarPesoNeto) & " Kg PARA ALCANZAR CUARTEO PROMEDIO"
            Biblioteca.MostrarMensaje(Page, "FALTAN " & KgLimitePorMuestra - (VarKgMuestra + VarPesoNeto) & " Kg PARA ALCANZAR CUARTEO PROMEDIO", 2)
        End If
        
        If (Me.CupoLimite.Text * 1000) <= VarKgCoop + VarPesoNeto Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Me.mensaje.Text & "EL PROVEEDOR " & Me.COOPERATIVA.Text & " HA COMPLETADO SU CUPO MENSUAL, " & vbCrLf & " NO SE PERMITEN MAS REGISTROS DE ENTREGA"
            Biblioteca.MostrarMensaje(Page, "EL PROVEEDOR " & Me.COOPERATIVA.Text & " HA COMPLETADO SU CUPO MENSUAL, " & " NO SE PERMITEN MAS REGISTROS DE ENTREGA", 2)
        ElseIf ((Me.CupoLimite.Text * 1000) - VarKgCoop + VarPesoNeto) <= ValorMensaje Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Me.mensaje.Text & vbCrLf & "AL PROVEEDOR " & Me.COOPERATIVA.Text & " LE FALTAN " & (Me.CupoLimite.Text * 1000) - (VarKgCoop + VarPesoNeto) & " Kg PARA ALCANZAR EL CUPO LÍMITE MENSUAL"
            Biblioteca.MostrarMensaje(Page, "AL PROVEEDOR " & Me.COOPERATIVA.Text & " LE FALTAN " & (Me.CupoLimite.Text * 1000) - (VarKgCoop + VarPesoNeto) & " Kg PARA ALCANZAR EL CUPO LÍMITE MENSUAL", 2)
        End If
    End Sub
    
    Public Function ExisteMuestra(ByVal NumMuestra As String) As Boolean
        Dim BIBLIOTECA As New Biblioteca
        Dim dTReader As SqlDataReader
        Dim ssQl As String
        Dim resp As Boolean
        Dim conn As SqlConnection
        Dim Mensaje As String = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        ssQl = "SELECT MUESTRAS.NUMERO" & _
               " FROM MUESTRAS " & _
               " WHERE MUESTRAS.NUMERO='" & NumMuestra & "'" ' se quito por crear duplicados de muestras AND ESTADO = 'A'"
        dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)
        If dTReader.Read() Then
            resp = True
        Else
            resp = False
        End If
        dTReader.Close()
        'CERRAR LA CONEXION        
        Return resp
    End Function
    
    Protected Sub Guardar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim ssql As String
        Dim Mensaje As String
        Dim Seguridad As New Seguridad
                
        ssql = " UPDATE ENTREGAS " & _
               " SET ENTREGAS.HORASALIDA = '" & Replace(Format(CDate(Me.HSALIDA.Text), "hh:mm:ss tt"), ".", "") & "', ENTREGAS.PESOSALIDA = " & Me.PESOSALIDA.Text & ", ENTREGAS.PESONETO = " & Me.PESONETO.Text & ", ENTREGAS.OBSERVACION_SAL = '" & Me.OBSERVACIONES.Text & "', ENTREGAS.ESTADO='RC', ENTREGAS.IMPRESIONESSAL=0 " & _
               " WHERE ENTREGAS.NUMEROENTRADA='" & Me.NENTRADA.Text & "' AND ENTREGAS.FECHAENTREGA= CONVERT(DATETIME, '" & Format(Date.Now, "yyyy-MM-dd 00:00:00") & "', 102) AND ENTREGAS.ESTADO = 'AC'"
        Mensaje = ""
        
        If Me.PESOSALIDA.Text <= 0 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El peso de la salida no puede ser cero"
            Biblioteca.MostrarMensaje(Page, "El peso de la salida no puede ser cero", 2)
            Exit Sub
        End If
        
        If Me.PESONETO.Text < 0 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El peso de neto no puede inferior a cero"
            Biblioteca.MostrarMensaje(Page, "El peso neto no puede ser inferior a cero", 2)
            Exit Sub
        End If
        
        'If Me.PESONETO.Text = 0 Then   ' Se deben permitir salidas con PESO NETO = Cero
        ' Me.mensaje.ForeColor = Color.Red
        ' Me.mensaje.Text = "El peso neto no puede ser cero"
        ' Exit Sub
        ' End If
        
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            Seguridad.RegistroAuditoria(Session("Usuario"), "SalidaVeh", "EntregaCompleta", "Entrada:" & Me.NENTRADA.Text & ";MuestraEsp:" & Me.NumMuestraEsp.Text & ";kgAcumCoop:" & Me.KgCoop.Text & ";kgAcumMuestra:" & Me.KgMuestra.Text & ";PesoEntrada:" & Me.PESOENTRADA.Text & ";PesoSalida:" & Me.PESOSALIDA.Text & ";PesoNeto:" & Me.PESONETO.Text, Session("GRUPOUS"))
            If Me.NumMuestraEsp.Text = "" Then ' Si la Entrega Actual NO genero Muestra Especial, se hace el registro Normalmente
                If ExisteMuestra(Me.MUESTRAGENERADA.Text) Then
                    If Me.MuestraOk.Checked Then
                        ssql = " UPDATE MUESTRAS " & _
                               " SET MUESTRAS.ENTREGA = '" & Me.NENTRADA.Text & "', MUESTRAS.FECHAMUESTRA = CONVERT(DATETIME,'" & Format(Date.Now, "yyyy-MM-dd 00:00:00") & "',102), MUESTRAS.ACUMPESOS = [MUESTRAS].[ACUMPESOS]+" & Me.PESONETO.Text & ", ESTADO='C'" & _
                               " WHERE MUESTRAS.NUMERO='" & Me.MUESTRAGENERADA.Text & "'"
                        Seguridad.RegistroAuditoria(Session("Usuario"), "SalidaVeh", "MuestraCompleta", "Entrada:" & Me.NENTRADA.Text & ";MuestraEsp:" & Me.NumMuestraEsp.Text & ";kgAcumCoop:" & Me.KgCoop.Text & ";kgAcumMuestra:" & Me.KgMuestra.Text & ";PesoNeto:" & Me.PESONETO.Text, Session("GRUPOUS"))
                    Else
                        ssql = " UPDATE MUESTRAS " & _
                               " SET MUESTRAS.ENTREGA = '" & Me.NENTRADA.Text & "', MUESTRAS.FECHAMUESTRA = CONVERT(DATETIME,'" & Format(Date.Now, "yyyy-MM-dd 00:00:00") & "',102), MUESTRAS.ACUMPESOS = [MUESTRAS].[ACUMPESOS]+" & Me.PESONETO.Text & "" & _
                               " WHERE MUESTRAS.NUMERO='" & Me.MUESTRAGENERADA.Text & "'"
                    End If
                Else
                    ssql = " INSERT INTO MUESTRAS ( NUMERO, ENTREGA, COOPERATIVA, FECHAMUESTRA, ACUMPESOS, HUMEDADSUP, HUMEDADRES, HUMEDADTOT, MATVOLATIL, AZUFRE, CENIZAS, CARBONO, FACTORB, HIDROGENO, PESOCORREGIDO, PODERCALORLHV, PODERCALORHHV, PODERCALORTOT,ESTADO)" & _
                           " VALUES ('" & Me.MUESTRAGENERADA.Text & "', '" & Me.NENTRADA.Text & "', '" & Biblioteca.ContrCoopMina(Trim(Me.NENTRADA.Text), 2) & "', CONVERT(DATETIME,'" & Format(Date.Now, "yyyy-MM-dd 00:00:00") & "', 102), '" & Me.PESONETO.Text & "', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,'A')"
                    Seguridad.RegistroAuditoria(Session("Usuario"), "SalidaVeh", "Crear Muestra", "Entrada:" & Me.NENTRADA.Text & ";MuestraEsp:" & Me.NumMuestraEsp.Text & ";kgAcumCoop:" & Me.KgCoop.Text & ";kgAcumMuestra:" & Me.KgMuestra.Text & ";PesoNeto:" & Me.PESONETO.Text, Session("GRUPOUS"))
                End If
            End If
            If Biblioteca.EjecutarSql(Mensaje, ssql) Then
                ssql = " UPDATE MINAS " & _
                       " SET MINAS.KGS_ACUM = [MINAS].[KGS_ACUM]+" & Me.PESONETO.Text & "" & _
                       " WHERE MINAS.NUMERO='" & Biblioteca.ContrCoopMina(Trim(Me.NENTRADA.Text), 3) & "'"
                If Biblioteca.EjecutarSql(Mensaje, ssql) Then
                    'Actualizar cooperativas
                    ssql = " UPDATE COOPERATIVAS " & _
                      " SET COOPERATIVAS.KGS_ACUM = [COOPERATIVAS].[KGS_ACUM]+" & Me.PESONETO.Text & "" & _
                      " WHERE COOPERATIVAS.NUMERO='" & Biblioteca.ContrCoopMina(Trim(Me.NENTRADA.Text), 2) & "'"
                    Biblioteca.EjecutarSql(Mensaje, ssql)
                    
                    ''Imprimir
                    ssql = " SELECT PESOSALIDA, PESONETO, OBSERVACION_SAL, HORAENTREGA, HORASALIDA, COALESCE(MUESTRAESP,'') AS MUESTRAESP " & _
                           " FROM ENTREGAS" & _
                           " WHERE ENTREGAS.NUMEROENTRADA = '" & Trim(Me.NENTRADA.Text) & "'"
                    Call Inicio()
                    Biblioteca.AbreVentana("ReportesCrystal.aspx", Page)
                    Session("SqlReporte") = ssql
                    Session("NombreReporte") = Biblioteca.ValorParametro("REPORTE SALIDA")
                    Session("Parametro") = ""
                    Session("NombreDataTable") = "Entregas"
                    'Fin Imprimir      
                                                                 
                    Call Limpiar()
                    'Response.Redirect("SalidaVehiculos.aspx")
                End If
            End If
        End If
    End Sub
    
    Private Sub Limpiar()
        Inicio()
        Me.mensaje.Text = ""
        Me.PROVEEDOR.Text = ""
        Me.COOPERATIVA.Text = ""
        Me.MUNICIPIO.Text = ""
        Me.HINGRESO.Text = ""
        Me.CONDUCTOR.Text = ""
        Me.HSALIDA.Text = ""
        Me.VEHICULO.Text = ""
        Me.PESOENTRADA.Text = 0
        Me.MUESTRAGENERADA.Text = ""
        Me.KgCoop.Text = 0
        Me.KgMuestra.Text = 0
        Me.OBSERVACIONES.Text = ""
        Me.PESONETO.Text = 0
        Me.PESOSALIDA.Text = 0
        Me.NENTRADA.Text = ".."
        Me.MuestraOk.Checked = False
        Me.NumMuestraEsp.Text = ""
        Me.CupoLimite.Text = 0
    End Sub
    
    Protected Sub MuestraEsp_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Biblioteca As New Biblioteca
        Dim conn As SqlConnection
        Dim ssql As String
        Dim Mensaje As String
        Dim Numero As Integer
        Dim Seguridad As New Seguridad
        
        Mensaje = ""
        If Me.PESOSALIDA.Text <= 0 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El peso de la salida no puede ser cero"
            Biblioteca.MostrarMensaje(Page, "El peso de la salida no puede ser cero", 2)
            Exit Sub
        End If
        
        If Me.PESONETO.Text <= 0 Then
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "El peso de neto no puede inferior a cero"
            Biblioteca.MostrarMensaje(Page, "El peso neto no puede ser inferior a cero", 2)
            Exit Sub
        End If
        
        conn = Biblioteca.Conectar(Mensaje)
        Numero = ConsecutivoMuestraEsp(Me.MUESTRAGENERADA.Text, conn)
        ssql = "INSERT INTO MUESTRAS ( NUMERO, ENTREGA, COOPERATIVA, FECHAMUESTRA, ACUMPESOS, HUMEDADSUP, HUMEDADRES, HUMEDADTOT, MATVOLATIL, AZUFRE, CENIZAS, CARBONO, FACTORB, HIDROGENO, PESOCORREGIDO, PODERCALORLHV, PODERCALORHHV, PODERCALORTOT,ESTADO)" & _
               " VALUES ('" & Me.MUESTRAGENERADA.Text & "E" & Numero & "', '" & Me.NENTRADA.Text & "', '" & Biblioteca.ContrCoopMina(Trim(Me.NENTRADA.Text), 2) & "', CONVERT(DATETIME,'" & Format(Date.Now, "yyyy-MM-dd 00:00:00") & "', 102), '" & Me.PESONETO.Text & "', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'AE')"
           
        If Biblioteca.EjecutarSql(Mensaje, ssql) Then
            Me.MuestraOk.Checked = False
            
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "MUESTRA ESPECIAL GENERADA " '& Me.MUESTRAGENERADA.Text & "E" & Numero
            Biblioteca.MostrarMensaje(Page, "MUESTRA ESPECIAL GENERADA ", 2)
            ssql = "UPDATE ENTREGAS SET ENTREGAS.MUESTRAESP = '" & Me.MUESTRAGENERADA.Text & "E" & Numero & "'" & _
                   " WHERE ENTREGAS.NUMEROENTRADA='" & Me.NENTRADA.Text & "' AND ENTREGAS.MUESTRAGEN='" & Me.MUESTRAGENERADA.Text & "'"
            Me.NumMuestraEsp.Text = Me.MUESTRAGENERADA.Text & "E" & Numero
            Biblioteca.EjecutarSql(Mensaje, ssql)
            Seguridad.RegistroAuditoria(Session("Usuario"), "SalidaVeh", "MuestraEsp", "Entrada:" & Me.NENTRADA.Text & ";MuestraEsp:" & Me.NumMuestraEsp.Text & ";kgAcumCoop:" & Me.KgCoop.Text & ";kgAcumMuestra:" & Me.KgMuestra.Text & ";PesoNeto:" & Me.PESONETO.Text, Session("GRUPOUS"))
        Else
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = Mensaje
        End If
        Biblioteca.DesConectar(conn)
    End Sub
    
    Public Function ConsecutivoMuestraEsp(ByVal NumMuestra As String, ByVal conn As SqlConnection) As Integer
        Dim BIBLIOTECA As New Biblioteca
        Dim dTReader As SqlDataReader
        Dim ssQl As String
        Dim resp As Integer=0
        Dim NumeroMayor as Integer=0
        Dim Mensaje As String = ""
         
        ssQl = "SELECT MUESTRAS.NUMERO" & _
               " FROM MUESTRAS " & _
               " WHERE NUMERO LIKE '" & NumMuestra & "E%'" & _
               " ORDER BY NUMERO DESC"
        dTReader = BIBLIOTECA.CargarDataReader(Mensaje, ssQl, conn)        
        while dtreader.Read
            if numeromayor>  resp then
                resp=NumeroMayor         
            end if        
            NumeroMayor=Val(Replace(dTReader("NUMERO"), NumMuestra & "E", ""))                       
        end while
        if numeromayor>  resp then
            resp = NumeroMayor
        end if   
        If resp=0 Then            
            resp = 1
        Else
            resp = resp + 1
        End If
        dTReader.Close()
        BIBLIOTECA.DesConectar(conn)
        'CERRAR LA CONEXION        
        Return resp
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">    

    <div>
    <table border="1" bordercolor="#cccccc"> <!-- TABLA USADA COMO MARCO DEL FORMULARIO-->
    <tr>
    <td style="height: 357px">
<table>
            <tr>
                <td align="center" colspan="4" style="border-right: #cccccc thin solid; border-top: #cccccc thin solid; border-left: #cccccc thin solid; border-bottom: #cccccc thin solid; height: 6px">
                    <asp:Label ID="Label2" runat="server" Font-Bold="True" ForeColor="#336677" Text="Salida de Vehículos"
                        Width="175px" Height="18px"></asp:Label></td>
            </tr>
            <tr>
                <td align="right" style="width: 205px; height: 4px">
                </td>
                <td align="left" style="width: 172px; height: 4px">
                </td>
                <td align="left" style="width: 89px; height: 4px">
                </td>
                <td style="width: 97px; height: 4px;">
                </td>
            </tr>
            <tr>
                <td align="right" style="width: 205px; height: 4px">
                    <asp:Label ID="Label3" runat="server" Text="N° Entrada" ForeColor="#336677"></asp:Label></td>
                <td align="left" style="width: 172px; height: 4px">
                    <asp:DropDownList ID="NENTRADA" runat="server" Width="162px" OnSelectedIndexChanged="NENTRADA_SelectedIndexChanged" AutoPostBack="True">
                    </asp:DropDownList></td>
                <td style="width: 89px; height: 4px;" align="left">
                    </td>
                <td style="width: 97px; height: 4px;">
                    </td>
            </tr>
            <tr>
                <td align="right" style="width: 205px; height: 1px">
                    <asp:Label ID="Label10" runat="server" Text="Hora de Ingreso" ForeColor="#336677"></asp:Label></td>
                <td align="left" style="width: 172px; height: 1px">
                    <asp:TextBox ID="HINGRESO" runat="server" Width="59px" ReadOnly="True"></asp:TextBox></td>
                <td style="height: 1px;" align="left" colspan="2">
                    <asp:TextBox ID="PROVEEDOR" runat="server" Width="203px" ReadOnly="True"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 205px;">
                    <asp:Label ID="Label11" runat="server" Text="Hora de Salida" ForeColor="#336677"></asp:Label></td>
                <td align="left" style="width: 172px;">
                    <asp:TextBox ID="HSALIDA" runat="server" Width="59px" ReadOnly="True"></asp:TextBox></td>
                <td colspan="2">
                    <asp:TextBox ID="CONDUCTOR" runat="server" Width="203px" ReadOnly="True"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right" style="width: 205px; height: 2px">
                    <asp:Label ID="Label1" runat="server" Text="Muestra Generada" ForeColor="#336677" Visible="False"></asp:Label></td>
                <td align="left" style="width: 172px; height: 2px">
                    <asp:TextBox ID="MUESTRAGENERADA" runat="server" Enabled="False" Visible="False"></asp:TextBox></td>
                <td colspan="2" style="height: 2px">
                    <asp:TextBox ID="COOPERATIVA" runat="server" Width="203px" ReadOnly="True"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="left" colspan="2" style="height: 18px">
                    <asp:Label ID="Label13" runat="server" Text="Información Final de Pesaje" Font-Bold="True" Width="315px" ForeColor="#336677"></asp:Label></td>
                <td style="width: 89px; height: 18px;" align="left">
                    <asp:TextBox ID="MUNICIPIO" runat="server" ReadOnly="True"></asp:TextBox></td>
                <td colspan="1" style="width: 97px; height: 18px;">
                    </td>
            </tr>
            <tr>
                <td align="left" style="width: 205px; height: 5px;">
                    <asp:Label ID="Label14" runat="server" Text="Peso Entrada" ForeColor="#336677"></asp:Label></td>
                <td align="left" style="width: 172px; height: 5px;">
                    <asp:TextBox ID="PESOENTRADA" runat="server" Width="107px"></asp:TextBox></td>
                <td style="width: 89px; height: 5px;" align="left">
                    <asp:TextBox ID="VEHICULO" runat="server" ReadOnly="True"></asp:TextBox></td>
                <td style="width: 97px; height: 5px;">
                    </td>
            </tr>
            <tr>
                <td align="left" style="width: 205px;">
                    <asp:Label ID="Label15" runat="server" Text="Peso Salida" ForeColor="#336677"></asp:Label></td>
                <td align="left" style="width: 172px;">
                    <asp:TextBox ID="PESOSALIDA" runat="server" Width="107px"></asp:TextBox>
                    <asp:Button ID="PESOENTR" runat="server" Text="PESO" OnClick="PESOENTR_Click" ForeColor="#336677" Font-Bold="True" /></td>
                <td style="width: 89px;" align="left">
                    </td>
                <td style="width: 97px;">
                    <asp:TextBox ID="CupoLimite" runat="server" Visible="False" Width="34px"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="left" style="width: 205px;">
                    <asp:Label ID="Label16" runat="server" Text="PESO NETO" ForeColor="#336677"></asp:Label></td>
                <td align="left" style="width: 172px;">
                    <asp:TextBox ID="PESONETO" runat="server" Width="107px"></asp:TextBox></td>
                <td style="width: 89px;" align="left">
                    </td>
                <td id="lola" style="width: 97px;">
                    </td>
            </tr>
            
            <tr>
                <td align="left" style="width: 205px; height: 21px">
                </td>
                <td colspan="3">
                    &nbsp; &nbsp;
                    <asp:Label ID="Label4" runat="server" Font-Bold="True" ForeColor="#336677" Text="Kg Coop"
                        Width="63px"></asp:Label><asp:Label ID="KgCoop" runat="server" Font-Bold="True" ForeColor="ActiveCaption"
                            Width="84px"></asp:Label>
                    &nbsp; &nbsp; &nbsp;&nbsp;
                    <asp:Label ID="Label5" runat="server" Font-Bold="True" ForeColor="#336677" Text="Kg Muestra"
                        Width="128px"></asp:Label><asp:Label ID="KgMuestra" runat="server" Font-Bold="True"
                            ForeColor="ActiveCaption" Width="1px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" style="width: 205px; height: 15px">
                    <asp:Label ID="Label12" runat="server" Text="Observaciones" ForeColor="#336677"></asp:Label></td>
                <td align="left" colspan="2" style="height: 15px">
                    <asp:TextBox ID="OBSERVACIONES" runat="server" Height="52px" Width="360px"></asp:TextBox></td>
                <td style="width: 97px; height: 15px;">
                    <asp:CheckBox ID="MuestraOk" runat="server" Visible="False" /></td>
            </tr>
            <tr>
                <td colspan="4" style="height: 3px">
                    <asp:Label ID="mensaje" runat="server" Height="26px" Width="665px"></asp:Label></td>
            </tr>
            <tr>
                <td align="left" style="width: 205px; height: 26px;">
                    <asp:TextBox ID="NumMuestraEsp" runat="server" Visible="False"></asp:TextBox></td>
                <td align="right" style="width: 172px; height: 26px;">
                    <asp:Button ID="MuestraEsp" runat="server" OnClick="MuestraEsp_Click" Text="Muestra Esp." ForeColor="#336677" Font-Bold="True" /></td>
                <td align="center" style="width: 89px; height: 26px;">
                    <asp:Button ID="Guardar" runat="server" OnClick="Guardar_Click" Text="Guardar" ForeColor="#336677" Font-Bold="True" /></td>
                <td colspan="1" style="width: 97px; height: 26px;">
                </td>
            </tr>
        </table>
    </td>
    </tr>
</table>
    
        
    </div>    
</asp:Content>