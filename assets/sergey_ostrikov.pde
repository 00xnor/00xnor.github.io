//--------------------------------------------------------------------------------
/* @pjs
crisp=true;
font=/assets/HelveticaNeue.ttf;
*/
//--------------------------------------------------------------------------------
// welcome to the sausige factory :)
//--------------------------------------------------------------------------------
PGraphics g;
int s = 173;
float r = 130-29;
float a = 115-29;
float r2 = 110-21;
float a2 = 115-21;
float t = 0.0;
float ts = 2*PI/s;
float x1 = 0.0;
float x2 = 0.0;
float x3 = 0.0;
float y1 = 0.0;
float y2 = 0.0;
float y3 = 0.0;
float ba = 0.5;
float bs = 0.0029;
float []cp_x = new float[s];
float []cp_y = new float[s];
float []ip_x = new float[s];
float []ip_y = new float[s];
float []bp_x = new float[s];
float []bp_y = new float[s];
float []cp2_x = new float[s];
float []cp2_y = new float[s];
float []ip2_x = new float[s];
float []ip2_y = new float[s];
float []bp2_x = new float[s];
float []bp2_y = new float[s];
String xnor = "Sergey  Ostrikov  00xnor";
int c = 0;
int pdl = (int)(0.94*s);
int idx = 0;
int idx2 = 0;
int pidx = 0;
int pidx2 = 0;
int scs = 200;
float startu;
float dstartu = 0.00001;
int prevt;
int fg_color = #222222;
int bg_color = #FCFEFB;
int stroke_color = #000000;
int fill_color = #444444;
float font_size = 15.39;
float pa = 0.0;
float twt;
float twa;
PFont myFont;


//--------------------------------------------------------------------------------
void setup()
{
  size(718, 250, P2D);
  g = createGraphics(718, 250, P2D);
  g.translate(width/2, height/2);

  randomSeed(second());
  ba = random(0.0, 1.0);

  // noSmooth();
  // noStroke();
  background(#FCFEFB);
  
  myFont = createFont("/assets/HelveticaNeue.ttf", font_size);
  g.textFont(myFont, font_size);

  for (int i = 0; i < s; i++)
  {    
    cp_x[i] = r*cos(t);
    cp_y[i] = r*sin(t);
    
    ip_x[i] = (a*sqrt(6)*cos(t))/(sq(sin(t))+2.5);
    ip_y[i] = (a*sqrt(2)*cos(t)*sin(t))/(sq(sin(t))+1);
    
    bp_x[i] = lerp(cp_x[i], ip_x[i], ba);
    bp_y[i] = lerp(cp_y[i], ip_y[i], ba);        
    
    cp2_x[i] = r2*cos(t);
    cp2_y[i] = r2*sin(t);
    
    ip2_x[i] = (a2*sqrt(6)*cos(t))/(sq(sin(t))+2.5);
    ip2_y[i] = (a2*sqrt(2)*cos(t)*sin(t))/(sq(sin(t))+1);
    
    bp2_x[i] = lerp(cp2_x[i], ip2_x[i], ba);
    bp2_y[i] = lerp(cp2_y[i], ip2_y[i], ba);        
    
    t += ts;
  }

  prevt = millis();
}


//--------------------------------------------------------------------------------
void draw()
{
  g.background(#FCFEFB);
  int dt = millis() - prevt;
  prevt = millis();
  startu += dstartu * dt;  
  twa = 0;
  twt = textWidth(xnor);

  for (int i = 0; i < xnor.length(); i++) 
  {
    char ca = xnor.charAt(i);
    
    twa += 0.5 * textWidth(ca);
    float u = (startu + map(twa, 0, twt, 0, 1)) % 1.0;
    twa += 0.5 * textWidth(ca);
    int char_pidx = (int)(u*s);
    
    int angle_idx = (int)(((u + 0.0000001) % 1.0)*s);
    float atan_y = bp2_y[angle_idx] - bp2_y[char_pidx];
    float atan_x = bp2_x[angle_idx] - bp2_x[char_pidx];
    if (atan_x == 0.0) { atan_x = 0.0000001; }
    float angleOfRotation = lerp(pa, atan2(atan_y, atan_x), 0.5);
    pa = angleOfRotation;

    g.pushMatrix();
    g.translate(bp2_x[char_pidx], bp2_y[char_pidx]);
    g.fill(fg_color);
    g.textAlign(CENTER, CENTER);
    g.text(ca, 0, 0);
    g.rotate(angleOfRotation);
    g.popMatrix();
  }

  idx = (c + int(32)) % s;
  idx2 = c % s; 

  g.beginShape();
  g.stroke(100);
  g.strokeWeight(0.7);
  g.noFill();
  g.strokeCap(ROUND);

  for (int i = 0; i < pdl; i++)
  {
    pidx = (idx + i) % s;
    pidx2 = (idx2 + i) % s;
    
    bp_x[pidx] = lerp(cp_x[pidx], ip_x[pidx2], ba);
    bp_y[pidx] = lerp(cp_y[pidx], ip_y[pidx2], ba); 

    bp2_x[pidx] = lerp(cp2_x[pidx], ip2_x[pidx2], ba);
    bp2_y[pidx] = lerp(cp2_y[pidx], ip2_y[pidx2], ba); 
    
    g.curveVertex(bp_x[pidx], bp_y[pidx]);
  }

  g.endShape();
  image(g, 0, 0);

  if (ba >= 1.0 || ba <= 0.0)
  {
    if (scs-- > 0)
    {
      
    }
    else
    {
      if (ba <= 0.01)
      {
        scs = 600;
      }
      else
      {
        scs = 200;
      }
      
      bs *= -1;
    }
  }
  
  if (scs == 200)
  {
    ba += bs;
  }

  pushMatrix();
  translate(width/2, height/2);
  stroke(fg_color);
  strokeWeight(5.4);
  point(bp_x[idx], bp_y[idx]);
  popMatrix();

  c++; 
}


