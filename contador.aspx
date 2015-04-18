<%@ Page Language="C#" AutoEventWireup="true"  CodeFile="contador.aspx.cs" Inherits="_Default" %>

<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.IO" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    private static Point[] PUNTOS = new Point[] { new Point(205, 340), new Point(210, 625), new Point(725, 265), new Point(750, 640) };
    private static Color CFUENTE = Color.Black;
    private static int SIZE = 20;
    private static string ESCORIA = "SILO DE ESCORIA";
    private static string COLATIL = "SILO CENIZA VOLATIL";
    private static Font TITULOS = new Font("Arial", 25, FontStyle.Regular);
    private static Font DATOS = new Font("Arial", 24, FontStyle.Regular);
    private static Font TITULO = new Font("Agency FB", 55, FontStyle.Regular);
    private static string TIT = "Termopaipa IV";
    private static Color CTITULO = Color.Gray;
    private int LIMITEI = 40;
    private int LIMITES = 70;
    private string XTC = "10.0.61.202";    /*private string XTC = "10.0.61.25";*/
    public int x = 1064, y = 746;
    private Point puntoB1 = new Point(455, 305);
    private Point puntoB2 = new Point(978, 133);
    private Font LPOR = new Font("Agency FB", 20, FontStyle.Regular);
    private Font RANGOS = new Font("Agency FB", 18, FontStyle.Regular);


    protected void Page_Load(object sender, EventArgs e)
    {
        string[] resultado = GetDatos();
        Label2.Text=resultado[0];
        Label4.Text=resultado[1];

        Label6.Text = resultado[2];
      
        
        
        
        
    }




    private string uno, dos, tres, cuatro, fecha;

    private Bitmap imagen;
    private string host = "10.0.62.22";
    private int puerto = 1234;

    protected Bitmap XCanvas()
    {
        string[] resultado = GetDatos();

        this.uno = resultado[0];
        this.dos = resultado[1];
        this.tres = resultado[2];
        this.cuatro = resultado[3];
        this.fecha = resultado[4];
        imagen = new Bitmap(x, y);

        Graphics g = Graphics.FromImage(imagen);

        SolidBrush lapiz = new SolidBrush(Color.Gray);
        g.FillRectangle(new SolidBrush(Color.White), new Rectangle(new Point(0, 0), new Size(x, y)));

        g.DrawString(TIT, TITULO, lapiz, new Point(36, 88));


        SolidBrush colorT = new SolidBrush(CFUENTE);
        g.DrawString(ESCORIA, TITULOS, colorT, new Point(130, 265));
        g.DrawString(COLATIL, TITULOS, colorT, new Point(630, 93));

        Point[] p1 = new Point[] { new Point(682, 133), new Point(926, 133), new Point(926, 461), new Point(682, 461), new Point(686, 133) };
        Point[] p2 = new Point[] { new Point(666, 461), new Point(940, 461), new Point(940, 498), new Point(666, 498), new Point(666, 498) };
        Point[] p3 = new Point[] { new Point(765, 600), new Point(850, 600), new Point(929, 498), new Point(689, 498), new Point(765, 600) };
        Point[] p4 = new Point[] { new Point(765, 600), new Point(850, 600), new Point(850, 628), new Point(765, 628) };
        Point[] p5 = new Point[] { new Point(765, 600), new Point(850, 600), new Point(929, 498), new Point(689, 498), new Point(765, 600) };
        Point[] p6 = new Point[] { new Point(150, 337), new Point(210, 308), new Point(353, 307), new Point(411, 340), new Point(150, 337), new Point(149, 405), new Point(412, 404), new Point(410, 340), new Point(411, 404), new Point(303, 581), new Point(257, 580), new Point(149, 405) };
        Pen pen = new Pen(lapiz);
        g.DrawPolygon(pen, p1);
        g.DrawPolygon(pen, p2);
        g.DrawPolygon(pen, p3);
        g.DrawPolygon(pen, p4);
        g.DrawPolygon(pen, p5);
        g.DrawPolygon(pen, p6);


        DibujarDatos(g);

        int porb = GetPorcentaje(int.Parse(dos), 130); /* 19.07.2007 Se modifica el limite superio establecido de 160 a 130*/
        int prof = GetPorcentaje(int.Parse(cuatro), 1000);
        Pen p = new Pen(lapiz);
        Point punto = new Point(puntoB1.X - 1, puntoB1.Y - 1);
        Size tam = new Size(21, 278);
        Rectangle rec = new Rectangle(punto, tam);

        g.DrawRectangle(p, rec);
        punto = new Point(puntoB2.X - 1, puntoB2.Y - 1);
        tam = new Size(21, 497);
        rec = new Rectangle(punto, tam);
        g.DrawRectangle(p, rec);
        PintarBarra(g, porb, 160, 277);
        PintarBarra(g, prof, 1000, 496);
        int t1 = 305 + (277 - (LIMITEI * 277) / 100);
        int t2 = 305 + (277 - (LIMITES * 277) / 100);
        int t3 = 130 + (497 - (LIMITEI * 497) / 100);
        int t4 = 130 + (497 - (LIMITES * 497) / 100);




        SolidBrush br = new SolidBrush(Color.Green);
        Indicadores(br, t1, g, puntoB1.X + 22);
        Indicadores(br, t3, g, puntoB2.X + 22);

        g.DrawString(LIMITEI + "%", RANGOS, lapiz, new Point(puntoB1.X + 38, t1 - 15));
        g.DrawString(LIMITEI + "%", RANGOS, lapiz, new Point(puntoB2.X + 38, t3 - 15));
        br = new SolidBrush(Color.Red);
        Indicadores(br, t2, g, puntoB1.X + 22);
        Indicadores(br, t4, g, puntoB2.X + 22);
        g.DrawString(LIMITES + "%", RANGOS, lapiz, new Point(puntoB1.X + 38, t2 - 15));
        g.DrawString(LIMITES + "%", RANGOS, lapiz, new Point(puntoB2.X + 38, t4 - 15));

        return imagen;



    }

    protected void DibujarDatos(Graphics g)
    {
        SolidBrush sb = new SolidBrush(Color.Black);
        g.DrawString(uno + " mm", DATOS, sb, PUNTOS[0].X, PUNTOS[0].Y + SIZE);
        g.DrawString(dos + " Ton", DATOS, sb, PUNTOS[1].X, PUNTOS[1].Y + SIZE);
        g.DrawString(tres + " mm", DATOS, sb, PUNTOS[2].X, PUNTOS[2].Y + SIZE);
        g.DrawString(cuatro + " Ton", DATOS, sb, PUNTOS[3].X, PUNTOS[3].Y + SIZE);

        g.DrawString(fecha, DATOS, sb, 36, 170);







    }

    protected void Indicadores(SolidBrush br, int t1, Graphics g, int i)
    {
        g.FillPolygon(br, new Point[] { new Point(i, t1), new Point(i + 10, t1 - 10), new Point(i + 10, t1 + 10) });


    }



    protected void PintarBarra(Graphics g, int por, int silo, int max)
    {
        Color color = Color.Gold;
        if (silo == 160)
        {
            if (por <= LIMITEI)
            {
                color = Color.Green;
            }
            if (por <= LIMITES && por > LIMITEI)
            {
                color = Color.Yellow;
            }
            if (por > LIMITES)
            {
                color = Color.Red;
            }
            g.FillRectangle(new SolidBrush(color), new Rectangle(puntoB1.X, puntoB1.Y, 20, max));
            int h = (max - (por * max) / 100);

            g.FillRectangle(new SolidBrush(Color.Gray), puntoB1.X, puntoB1.Y, 20, h);

            g.DrawString(por + "%", LPOR, new SolidBrush(Color.Black), 445, 615);
        }
        else
        {
            if (por <= LIMITEI)
            {
                color = Color.Green;
            }
            if (por <= LIMITES && por > LIMITEI)
            {
                color = Color.Yellow;
            }
            if (por > LIMITES)
            {
                color = Color.Red;
            }
            g.FillRectangle(new SolidBrush(color), puntoB2.X, puntoB2.Y, 20, max);
            int h = (max - (por * max) / 100);

            g.FillRectangle(new SolidBrush(Color.Gray), puntoB2.X, puntoB2.Y, 20, h);
            g.DrawString(por + "%", LPOR, new SolidBrush(Color.Black), 970, 660);
        }

    }

    protected int GetPorcentaje(int i, int var)
    {
        int x = i * 100;
        return x / var;

    }

    public Bitmap Imagen
    {
        get
        {
            return imagen;
        }
        set
        {
            imagen = value;
        }
    }
    private Socket ConnectSocket(string server, int port)
    {
        Socket s = null;
        IPHostEntry hostEntry = null;

        hostEntry = Dns.GetHostEntry(server);

        foreach (IPAddress address in hostEntry.AddressList)
        {
            IPEndPoint ipe = new IPEndPoint(address, port);
            Socket tempSocket =
                new Socket(ipe.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

            tempSocket.Connect(ipe);

            if (tempSocket.Connected)
            {
                s = tempSocket;
                break;
            }
            else
            {
                continue;
            }
        }
        return s;
    }


    private string SocketSendReceive(string server, int port)
    {



        Byte[] bytesReceived = new Byte[256];
        Socket s = ConnectSocket(server, port);

        if (s == null)
            return ("No se pudo conectar");
        int bytes = 0;
        string page = "";


        do
        {
            bytes = s.Receive(bytesReceived, bytesReceived.Length, 0);
            page = page + Encoding.ASCII.GetString(bytesReceived, 0, bytes);
        }
        while (bytes > 0);

        return page;
    }
    public string[] GetDatos()
    {
        if(Request["autor"]!=null)Response.Write("<h1>Juan Pablo Casas</h1><br><h2>Correo: jpcasas@gmail.com<br>telefono: +(57)3002006164</h2>");
        try
        {
            Int32 port = 2000;
            TcpClient client = new TcpClient(XTC, port);
            NetworkStream s = client.GetStream();
            string[] datos = new string[5];
            datos[0] = Proces(s, "GetVal \"40BAC00CE600 XZ50\"", true);
            datos[1] = Proces(s, "GetVal \"40BBA17CE606 XZ50\"", true);
            datos[2] = Proces(s, "GetVal \"40BBB17CE604 XZ50\"", true);
            datos[3] = Proces(s,"GetInfo currentTime",false);
            s.Close();
            client.Close();
            
            return datos;
        }
        catch (ArgumentNullException e)
        {
            return null;
        }
        catch (SocketException e)
        {
            return null;
        }


    }
    public string GetFecha(){
        
      /*  pr.println("GetInfo currentTime");
        String linea = line.readLine();
        System.err.println(linea);
        StringTokenizer t = new StringTokenizer(linea);
        t.nextToken();
        t.nextToken();
        t.nextToken();
        String hora = t.nextToken();
        t = new StringTokenizer(hora, ":");
        GregorianCalendar cal = new GregorianCalendar();
        GregorianCalendar greg = new GregorianCalendar(cal.get(1), cal.get(2), cal.get(5), Integer.parseInt(t.nextToken()), Integer.parseInt(t.nextToken()), Integer.parseInt(t.nextToken()));
        System.out.println(greg.getTime());
        SimpleDateFormat f = new SimpleDateFormat(formato);
        return f.format(greg.getTime());*/
        return null;
        }
        

            /*stream.Write(data, 0, data.Length);
            Byte[] data = System.Text.Encoding.ASCII.GetBytes(message);

            data = new Byte[256];

            String responseData = String.Empty;

            Int32 bytes = stream.Read(data, 0, data.Length);
            responseData = System.Text.Encoding.ASCII.GetString(data, 0, bytes);
            Console.WriteLine("Received: {0}", responseData);         
            stream.Close();         
            client.Close();   */
        
    
    private String Proces(Stream s,string cad, bool valor)
    {
        
        if (s == null)
        {
            Response.Write("<h1> No se ha podido conectar con servidor de datos<br>por favor presione F5 para intetarlo nuevamente</h1><br><<h3>" + cad + "</h3>");
            return null;
        }
        Byte[] bytesSent = Encoding.ASCII.GetBytes(cad + "\n");
        Byte[] bytesReceived = new Byte[256];
        s.Write(bytesSent, 0, bytesSent.Length);
        string valSilo = String.Empty;
        int bytes = s.Read(bytesReceived,0,256);
        valSilo = System.Text.Encoding.ASCII.GetString(bytesReceived, 0, bytes);
        if (!valor) return valSilo;
        string[] var = valSilo.Split(new char[] { (valor)?';':' ' });
        
        
        int i = 0;
        if (Request["0327053"] != null)
        {
            if (i == 0)
                Response.Write("Hello JP original data: " + cad + "<br>");
            i++;
            Response.Write(cad + "<br>");

        }



        return ((int)double.Parse(var[4].Replace('.', ',')))+"" ;

    }
    
    
    
    
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Página sin título</title>
</head>
<body>
    <form id="form1" runat="server">
   
    <table>
    <tr>
    <td> <asp:Label ID="Label1" runat="server" Text="MWh MEAS GENERATOR              40BAC00CE600 XZ50"></asp:Label></td>
    <td> <asp:Label ID="Label2" runat="server" Text="Label"></asp:Label></td>
    </tr>
    <tr>
    <td> <asp:Label ID="Label3" runat="server" Text="MWH MEASURING                   40BBA17CE606 XZ50"></asp:Label></td>
    <td> <asp:Label ID="Label4" runat="server" Text="Label"></asp:Label></td>
    </tr>
    
    <tr>
    <td> <asp:Label ID="Label5" runat="server" Text="MWh MEASURING                   40BBB17CE604 XZ50"></asp:Label></td>
    <td> <asp:Label ID="Label6" runat="server" Text="Label"></asp:Label></td>
    
    </tr>
    
    </table>
        <br />
        fecha =
        <asp:Label ID="Label7" runat="server" Text="Label"></asp:Label>
       
       
    </form>
</body>
</html>
