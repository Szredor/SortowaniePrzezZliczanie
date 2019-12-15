//spacja - pauza sumowania
//strzalka w lewo - cofniecie o 1 sumowania
//strzalka w prawo - przesunie do przodu sumowania o 1

//czas opoznienia (ms/jedno wykonanie kroku)
final int czas = 300;//zmienic na 300

//podstawowe wartosci dla kazdego obiektu
class BasicObj
{
  public PVector position;
  public color border;
  public color background;
  public color txtColor;
  public PVector size;
  protected color tempBackground;

  public BasicObj(float posx, float posy, float sizex, float sizey)
  {
     position = new PVector(posx, posy);
     size = new PVector (sizex, sizey);
     border = color(0);
     background = color(255);
     tempBackground = background;
     txtColor = color(0);
  }
  
  public BasicObj(float posx, float posy, float sizex, float sizey, color _background)
  {
     position = new PVector(posx, posy);
     size = new PVector (sizex, sizey);
     border = color(0);
     background = _background;
     tempBackground = background;
     txtColor = color(0);
  }
};

//wszytskie klasy uzywajace tego interface'u beda wyswietlane przy uzyciu funkcji refresh()
public interface I_refreshable
{
   public void display(); 
   
   //dodawanie obiektu do listy odswiezania
   abstract void addToRefresh();
};

class Cell 
  extends BasicObj 
  implements I_refreshable
{
  public int value;
  private Integer index;
    
    public Cell(int _value, int _index, float posx, float posy, float sizex)
    {
       super(posx, posy, sizex, sizex);
       value = _value;
       index = new Integer(_index);
       addToRefresh();
    }
    
    public Cell(int _value, float posx, float posy, float sizex)
    {
       super(posx, posy, sizex, sizex);
       value = _value;
       index = null;
       addToRefresh();
    }
    
    void addToRefresh()
    {
        instances.add(this);
    }
    
    //zmiana koloru na jedno odswiezenie
    public void changeColor (color change)
    {
        tempBackground = background;
        background = change;
        //display();
    }
    
    //wyswietlenie komorki
    public void display()
    {   
       fill(background);
       background = tempBackground;
       stroke(border);
       strokeWeight(4);
       rect(position.x, position.y, size.x, size.y);
       
       textSize(size.y/2);
       fill(txtColor);
       noStroke();
       
       text(str(value), position.x+size.x/4, position.y+(size.y/4)*3);
       if (index != null)text(str(index), position.x+size.x/4, position.y-size.y/4);
    } 
}

class Arrow 
  extends BasicObj
  implements I_refreshable
{
    public PVector endPos;
    private String txt;
  
    public Arrow(float _endSizex, float _endSizey, color _bg)
    {
        super(0.0, 0.0, _endSizex, _endSizey, _bg);
        endPos = new PVector(0,0);
        txt = "";
        addToRefresh();
    }
    
    void addToRefresh()
    {
       instances.add(this); 
    }
    
    public void display()
    {
        //wyswietlenie linii
        strokeWeight(2);
        stroke(background);
        fill(background);
        line(position.x, position.y, endPos.x, endPos.y);
        
        //wyswietlenie strzalki
        pushMatrix();
            translate(endPos.x, endPos.y);
            rotate(atan2((position.y - endPos.y), (position.x - endPos.x)));
            triangle(0,0, size.y, size.x/2, size.y, -size.x/2);
        popMatrix();
        
        //tekst przy strzalce
        fill(txtColor);
        textSize(40);
        text(txt, abs(endPos.x + position.x)/2 + 30, abs(endPos.y + position.y)/2);
    }
    
    public void setBegin(float x, float y)
    {
      position = new PVector(x, y);
    }
    
    public void setEnd(float x, float y)
    {
        endPos = new PVector(x, y);
    }
    
    public void setText(String _txt)
    {
       txt = _txt; 
    }
};

//poczatek
Cell[] sumy, ciag;
ArrayList<I_refreshable> instances;
Arrow pointer;

PVector arrayPos, tabSortPos;

float size = 50;
int zasieg = 40, i=-1, j=0, iter=0, temp; 

color showColor;
boolean wyswietlic = false, end = false, sumowa = true, pause = false;

void setup()
{
   size (800, 600);
   
   //ustawienie coloru
   showColor = color(#db441a);
   
   //tablica wszystkich objektow uzywajacych tego interfejsu
   instances = new ArrayList<I_refreshable>();
   
   //inicjacja tablic 
   sumy = new Cell[11];
   ciag = new Cell[zasieg];
   
   //pozycje tablic i cyfry
   tabSortPos = new PVector(0, 520);
   arrayPos = new PVector(50, 50); 
   
   //przygotowanie tablicy sum
   for (int i = 0 ; i<=10; i++)
   {
       sumy[i] = new Cell(0, i, arrayPos.x + size*i, arrayPos.y, size);
   }
   
   //przygotowanie tablicy z ciagiem
   for (int i = 0; i<zasieg; i++)
   {
       ciag[i] = new Cell((int)random(11), i*40%width, tabSortPos.y+((i*40)/width*40), 40);
   }
   
   pointer = new Arrow(20, 40, showColor);
}

void draw()
{  
    //wywolanie sumowania
   if (i<zasieg-1 && sumowa == true)
   {
     i++;
     sumowanie();
   }
   else if (i >= zasieg-1)
   {
     refresh();
     
     //przygotowanie wyswietlenia
     wyswietlic = true;
     sumowa = false;
     pause = false;
     pointer.setText("");
   }
   
   //wywolanie wyswietlania posortowanych wartosci
   if (wyswietlic && j<=10)
   {
      if (sumy[j].value>0) wyswietlanie();
      else 
      {
         j++;
         refresh();
         delay(czas);
      }
   }
   
   //zakonczenie
   if (iter == zasieg) 
   {
     refresh();
     noLoop();
   }
}

//zsumowanie ilosci wystapien danej wartosci - jeden obrot petli
void sumowanie()
{
      int index = ciag[i].value;
      
      //ustawienie strzalki
      pointer.setText("+1");
      pointer.setEnd(sumy[index].position.x+sumy[index].size.x/2, sumy[index].position.y + sumy[index].size.y);
      pointer.setBegin(ciag[i].position.x + ciag[i].size.x/2, ciag[i].position.y);
      
      //zmiany tla
      ciag[i].changeColor(showColor);
      sumy[index].changeColor(showColor);
      
      //dodanie wartosci
      sumy[index].value++;
      
      refresh();
      
      delay(czas);
}

//odwrotnosc sumowania, umozliwia cofanie strzalkami
void fakeSumowanie(int temp)
{
    int index = ciag[temp].value;
  
    //usuwa jedno w przod aby bylo widac inkrementacje wystapienia
    sumy[ciag[temp+1].value].value--;
    
    //ustawienie strzalki
      pointer.setText("+1");
      pointer.setEnd(sumy[index].position.x+sumy[index].size.x/2, sumy[index].position.y + sumy[index].size.y);
      pointer.setBegin(ciag[i].position.x + ciag[i].size.x/2, ciag[i].position.y);
      
      //zmiany tla
      ciag[i].changeColor(showColor);
      sumy[index].changeColor(showColor);
      
      refresh();
}

//podmiania wartowsci na posortowane w tablicy wejsciowej - jeden obrot petli
void wyswietlanie()
{    
      //zmiany wartosci w tablicach
      sumy[j].value--;
      ciag[iter].value = j;
      
      //linia wskazujaca
      pointer.setBegin(sumy[j].position.x+sumy[j].size.x/2, sumy[j].position.y + sumy[j].size.y);
      pointer.setEnd(ciag[iter].position.x + ciag[iter].size.x/2, ciag[iter].position.y);
      
      sumy[j].changeColor(showColor);
      ciag[iter].changeColor(showColor);
      
      refresh();
      
      delay(czas);
      iter++;
}

void refresh()
{
    background(155);
    
    //ponowane wyswietlenie elementow na ekranie
    for (I_refreshable i : instances) i.display();
        
    fill(0);
    textSize(sumy[0].size.x/2);
    text(" ilość wystąpień", arrayPos.x+11*size, arrayPos.y + sumy[0].size.y/4*3);
    text("tablica wejściowa", tabSortPos.x + 20, tabSortPos.y - 20);
    
    //wyswietlanie tekstu pauzy
    if (pause)
    {
      fill(showColor);
      text("Pauza", width-100, tabSortPos.y - 20);
    }
}

void keyPressed()
{
    //pauzowanie sumowania
   if (key == 32) 
     {
        if (pause) sumowa = true;
        else sumowa = false;
        pause = !pause;
        
        fill(showColor);
        text("Pauza", width-100, tabSortPos.y - 20);
     }
     
     //cofanie sumowania o 1
   if (keyCode == LEFT && wyswietlic == false)
   {
      if (i>0)
      {
        i--;
        fakeSumowanie(i);
      }
   }
   
   //1 obrot sumowania dalej
   if (keyCode == RIGHT && wyswietlic == false)
   {
      if (i < zasieg-1);
      {
        i++;
        sumowanie();
      }
   }
}