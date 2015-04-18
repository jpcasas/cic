Imports System.Windows.Forms
Imports System.Web
Imports System.Web.UI
Imports System.Drawing
Imports System.Data
Imports System.Data.SqlClient
Partial Class newlogin
    Inherits System.Web.UI.Page

    Protected Sub ACEPTAR_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BIBLIOTECA As New Biblioteca
        Dim Seguridad As New Seguridad
        Dim conn As SqlConnection
        Dim dTReader As SqlDataReader
        Dim Mensaje As String
        Dim usr As String
        Dim pass As String
        Mensaje = ""
        conn = BIBLIOTECA.Conectar(Mensaje)
        Me.txtnombre.Text = UCase(Me.txtnombre.Text)
        usr = UCase(Me.txtnombre.Text)
        pass = Seguridad.Encriptar(Me.txtcontrasena.Text)
        dTReader = BIBLIOTECA.CargarDataReader(Mensaje, "SELECT CODIGO,GRUPO FROM USUARIOS WHERE CLAVE='" + pass + "' AND CODIGO='" + usr + "'", conn)

        Page.FindControl("txtnombre1")
        If Not dTReader.Read() Then
            'MsgBox("Verifique nombre y contraseña", MsgBoxStyle.Information, "C.E.S.")
            Me.mensaje.ForeColor = Color.Red
            Me.mensaje.Text = "Verifique nombre y contraseña"
            If Me.txtnombre.Text <> "" And Me.txtcontrasena.Text <> "" Then
                Seguridad.RegistroAuditoria(Me.txtnombre.Text, "Inicio Sesion", "Clave y Contraseña", "Error de Clave y Contraseña", "")
            End If
        Else
            Session("Usuario") = Me.txtnombre.Text
            Session("GRUPOUS") = dTReader(1)
            Session("Contrasena") = Seguridad.Encriptar(Me.txtcontrasena.Text)
            Seguridad.RegistroAuditoria(Me.txtnombre.Text, "Inicio Sesion", "Clave y Contraseña", "Ingreso Exitoso", dTReader(1))
            Response.Redirect("Principal.aspx")
        End If
        dTReader.Close()
        BIBLIOTECA.DesConectar(conn)
        

    End Sub

    Public Sub limpiar()
       
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Session("Usuario") = ""
        Session("GRUPOUS") = ""
       
    End Sub

End Class
