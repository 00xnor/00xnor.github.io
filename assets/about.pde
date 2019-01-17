

//-----------------------------------------------------------
class Lol 
{
  PVector loc, vel, acc;
  
  Lol() 
  {
    loc = new PVector(width/2, height/2);
    vel = new PVector(0, 0);
  }

  void update()
  {
    PVector acc = PVector.sub(new PVector(mouseX, mouseY), loc);
    acc.setMag(0.2);
    vel.add(acc);
    vel.limit(5.0);
    loc.add(vel);
    if (loc.x < 14) { loc.x = 14; }
    if (loc.x > (width - 14)) { loc.x = width - 14; }
    if (loc.y < 14) { loc.y = 14 }
    if (loc.y > (height - 14)) { loc.y = height - 14; }
  }
  
  void show()
  {
    //stroke(30);
    //strokeWeight(1.3);
    fill(#0C0C1C);
    ellipse(loc.x, loc.y, 20, 20);
  }
}


//-----------------------------------------------------------
Lol lol;


//-----------------------------------------------------------
void setup() 
{
  size(718, 400);
  background(#FCFEFB);
  lol = new Lol();
}


//-----------------------------------------------------------
void draw() 
{
  background(#FCFEFB);
  lol.update();
  lol.show();
}
