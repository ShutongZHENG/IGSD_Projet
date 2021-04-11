WorkSpace workspace;
Camera m_camera;
Map3D map;
Hud hud;
Land land;
Gpx gpx;
Railways railways;
Roads roads;
void setup() {
  fullScreen(P3D);
  this.map = new Map3D("paris_saclay.data");
  this.land = new Land(this.map, "paris_saclay.png");
  this.hud = new Hud();
  this.gpx = new Gpx(this.map, "trail.geojson" );
  this.railways = new Railways(this.map, "railways.geojson");

  this.roads = new Roads(this.map, "roads.geojson");
  smooth(8);
  frameRate(60);
  background(0x40);

  this.workspace = new WorkSpace(250*100);
  // Make camra move easier
  hint(ENABLE_KEY_REPEAT);

  // 3D camera (X+ right / Z+ top / Y+ Front)
  m_camera = new Camera(2500., -PI/2, 1.1593);
  m_camera.update();
}

void draw() {
  background(0x40);
  this.workspace.update();
  m_camera.update();
  land.update();
  this.gpx.update(m_camera);
  this.railways.update();
  this.roads.update();
  hud.update(m_camera);
}

void keyPressed() {

  if (key == CODED) {
    switch (keyCode) {
    case UP:
      m_camera.adjustColatitude(-PI/180);
      break;
    case DOWN:


      m_camera.adjustColatitude(PI/180);
      break;
    case LEFT:


      m_camera.adjustLongitude(-PI/180);
      break;
    case RIGHT:


      m_camera.adjustLongitude(PI/180);

      break;
    }
  } else {
    switch (key) {
    case '+':

      m_camera.adjustRadius(250.);

      break;
    case '-':

      m_camera.adjustRadius(-250.);

      break;

    case 'w':
    case 'W':
      // Hide/Show grid & Gizmo
      //this.workspace.toggle();
      this.land.toggle();
      break;
    case 'L':
    case 'l':
      this.m_camera.toggle();
      break;

    case 'X':
    case 'x':
      this.gpx.toggle();
      break;

    case 'R':
    case 'r':
      this.railways.toggle();
      break;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float ec = event.getCount();

  m_camera.adjustRadius(-250. * ec);
}

void mouseDragged() {
  if (mouseButton == CENTER) {
    // Camera Horizontal
    float dx = mouseX - pmouseX;

    m_camera.adjustLongitude(dx*PI/180);
    // Camera Vertical
    float dy = mouseY - pmouseY;

    m_camera.adjustColatitude(dy*PI/180);
  }
}

void mousePressed() {
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY);
}
