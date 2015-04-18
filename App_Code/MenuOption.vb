Imports Microsoft.VisualBasic

Public Class MenuOption

    Private _codigo As String
    Private _descripcion As String
    Private _url As String
    Private _items As ArrayList

    


    Public Sub New()
        _items = New ArrayList()


    End Sub

    Public Property Codigo() As String
        Get
            Return _codigo
        End Get
        Set(ByVal value As String)
            _codigo = value
        End Set
    End Property

    Public Property Descripcion() As String
        Get
            Return _descripcion
        End Get
        Set(ByVal value As String)
            _descripcion = value
        End Set
    End Property
    Public Property Url() As String
        Get
            Return _url
        End Get
        Set(ByVal value As String)
            _url = value
        End Set
    End Property
    Public Property Items() As ArrayList
        Get
            Return _items
        End Get
        Set(ByVal value As ArrayList)
            _items = value
        End Set
    End Property




End Class
