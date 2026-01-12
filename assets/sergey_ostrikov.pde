//--------------------------------------------------------------------------------
/* @pjs
crisp=true;
font=/assets/HelveticaNeue.ttf;
*/
//--------------------------------------------------------------------------------
// welcome to the sausige factory :)
//--------------------------------------------------------------------------------
PGraphics g;
int samples = 1000;
int path_samples = (int)(0.94*samples);
float radius = 93*0.98;
float radius2 = 80.5*0.98;
float a = 119*0.88;
float a2 = 125.5*0.88;
float time = 0.0;
float time_step = 2*PI/samples;
//--------------------------------------------------------------------------------
float []c1_x = new float[samples];
float []c1_y = new float[samples];
float []c2_x = new float[samples];
float []c2_y = new float[samples];
float []i1_x = new float[samples];
float []i1_y = new float[samples];
float []i2_x = new float[samples];
float []i2_y = new float[samples];
float []p1_x = new float[samples];
float []p1_y = new float[samples];
float []p2_x = new float[samples];
float []p2_y = new float[samples];
float blend_amount;
float blend_step = 0.0029;
//--------------------------------------------------------------------------------
String xnor = "Sergey    Ostrikov    00xnor ";
float total_text_width = textWidth(xnor);
int text_length = xnor.length();
float pos_step = 0.0000135;
char single_char;
int period_start;
float start_pos;
float pos;
float total_width_acc;
int char_idx;
int angle_idx;
float rotation_angle;
//--------------------------------------------------------------------------------
int c = 0;
int idx = 0;
int idx2 = 0;
int pidx = 0;
int pidx2 = 0;
int skip_cycles = 400;
float alpha = 0.0;
float alpha_target = 255.0;
float alpha_inc = 0.01;
float line_stroke_weight = 0.6;
float point_stroke_weight = 5.4;
int line_color = #222222;
int point_color = #222222;
int fg_color = #222222;
int bg_color = #FCFEFB;


//--------------------------------------------------------------------------------
void setup()
{
  size(250, 250, P2D);
  background(bg_color);

  g = createGraphics(250, 250, P2D);
  g.translate(width/2, height/2);
  g.textFont(createFont("/assets/HelveticaNeue.ttf"), 15);

  blend_amount = random(0.0, 1.0);

  for (int i = 0; i < samples; i++)
  {    
    c1_x[i] = radius*cos(time);
    c1_y[i] = radius*sin(time);

    i1_x[i] = (a*sqrt(6)*cos(time))/(sq(sin(time))+2.77);
    i1_y[i] = (a*sqrt(2)*cos(time)*sin(time))/(sq(sin(time))+1);

    c2_x[i] = radius2*cos(time);
    c2_y[i] = radius2*sin(time);

    i2_x[i] = (a2*sqrt(6)*cos(time))/(sq(sin(time))+2.77);
    i2_y[i] = (a2*sqrt(2)*cos(time)*sin(time))/(sq(sin(time))+1);

    time += time_step;
  }

  period_start = millis();  
}



//--------------------------------------------------------------------------------
void draw()
{
  g.background(bg_color);
  g.fill(fg_color, alpha);
  g.textAlign(CENTER, CENTER);

  if ((!((c < 30) || (alpha > 254))) && (c % 10 == 0))
  {
    alpha = lerp(alpha, alpha_target, alpha_inc+=0.003);
  }

  idx = (c + int(893)) % samples;
  idx2 = c % samples; 

  g.beginShape();
  g.stroke(line_color, alpha);
  g.strokeWeight(line_stroke_weight);
  g.noFill();
  g.strokeCap(ROUND);

  for (int i = 0; i < path_samples; i++)
  {
    pidx = (idx + i) % samples;
    pidx2 = (idx2 + i) % samples;

    p1_x[pidx] = lerp(c1_x[pidx], i1_x[pidx2], blend_amount);
    p1_y[pidx] = lerp(c1_y[pidx], i1_y[pidx2], blend_amount);

    p2_x[pidx] = lerp(c2_x[pidx], i2_x[pidx2], blend_amount);
    p2_y[pidx] = lerp(c2_y[pidx], i2_y[pidx2], blend_amount);

    g.curveVertex(p1_x[pidx], p1_y[pidx]);
  }

  g.endShape();

  start_pos += pos_step*(millis()-period_start);  
  period_start = millis();
  total_width_acc = 0;

  for (int i = 0; i < text_length; i++) 
  {
    single_char = xnor.charAt(i);

    total_width_acc += 0.5*textWidth(single_char);
    pos = (start_pos + map(total_width_acc, 0, total_text_width, 0, 1)) % 1.0;
    total_width_acc += 0.5 * textWidth(single_char);
    char_idx = (int)(pos*samples);    
    angle_idx = (int)(((pos + 0.01) % 1.0)*samples);
    rotation_angle = atan2(p2_y[angle_idx] - p2_y[char_idx], p2_x[angle_idx] - p2_x[char_idx]);

    g.pushMatrix();
    g.translate(p2_x[angle_idx], p2_y[angle_idx]);
    g.rotate(rotation_angle);
    g.text(single_char, 0, 0);
    g.popMatrix();
  }

  image(g, 0, 0);

  pushMatrix();
  translate(width/2, height/2);
  stroke(point_color, alpha);
  strokeWeight(point_stroke_weight, alpha);
  point(p1_x[idx], p1_y[idx]);
  popMatrix();

  if ((blend_amount >= 1.0 || blend_amount <= 0.0) && (!(skip_cycles-- > 0)))
  {
    skip_cycles = (blend_amount <= 0.01) ? 900 : 400; 
    blend_step *= -1;
  }
  
  if (skip_cycles == 400)
  {
    blend_amount += blend_step;
  }

  c += 6;
}


