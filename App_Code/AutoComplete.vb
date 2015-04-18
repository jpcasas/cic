Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Collections.Generic
Imports System.Data
Imports System.Data.SqlClient
<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
<System.Web.Script.Services.ScriptService()> _
Public Class AutoComplete
    Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function GetCompletionList(ByVal prefixText As String, ByVal count As Integer) As String()

        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim ssql As String



        conn = BIBLIOTECA.Conectar("")
        ssql = "SELECT  NUMERO + '_' + DESCRIPCION AS COOPERATIVA " & _
               " FROM COOPERATIVAS WHERE NUMERO + '_' + DESCRIPCION like '" & prefixText & "%'"
        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "COOPERATIVAS")

        Dim arData() As String

        ' Fill your dataset in your own way here

        ReDim arData(DtSet.Tables(0).Rows.Count - 1)

        For intCounter As Integer = 0 To DtSet.Tables(0).Rows.Count - 1
            arData(intCounter) = DtSet.Tables(0).Rows(intCounter).Item(0).ToString
        Next
        Return arData
        BIBLIOTECA.DesConectar(conn)
    End Function

    <WebMethod()> _
   Public Function GetProveedoresList(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim DtAdapter As SqlDataAdapter
        Dim DtSet As DataSet
        Dim ssql As String
        conn = BIBLIOTECA.Conectar("")
        ssql = "SELECT NUMERO + '_' + DESCRIPCION AS NMINA " & _
                  " FROM MINAS WHERE NUMERO + '_' + DESCRIPCION like '" & prefixText & "%'"

        DtAdapter = BIBLIOTECA.CargarDataAdapter(ssql, conn)
        DtSet = New DataSet
        ' Define el tipo de ejecución como procedimiento almacenado            
        DtAdapter.Fill(DtSet, "MINAS")

        Dim arData() As String

        ' Fill your dataset in your own way here

        ReDim arData(DtSet.Tables(0).Rows.Count - 1)

        For intCounter As Integer = 0 To DtSet.Tables(0).Rows.Count - 1
            arData(intCounter) = DtSet.Tables(0).Rows(intCounter).Item(0).ToString
        Next
        Return arData
        BIBLIOTECA.DesConectar(conn)
    End Function


    <WebMethod()> _
  Public Function GetPlacasList(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim BIBLIOTECA As New Biblioteca
        Dim conn As SqlConnection
        Dim myCommand As SqlCommand
        Dim dr As SqlDataReader
        Dim array As New List(Of String)
        Dim ssql As String
        conn = BIBLIOTECA.Conectar("")
        ssql = "SELECT DISTINCT PLACAS FROM CONDUCTORESVEHICULOS WHERE PLACAS LIKE '" & prefixText & "%'"
        myCommand = New SqlCommand(ssql, conn)
        dr = myCommand.ExecuteReader()
        While dr.Read()
            array.Add(dr("PLACAS").ToString())
        End While
        dr.Close()
        BIBLIOTECA.DesConectar(conn)

        Return array.ToArray()


    End Function


End Class
