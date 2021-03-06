WorkSpace workspace;
Camera m_camera;
Map3D map;
Hud hud;
Land land;
Gpx gpx;
Railways railways;
Roads roads;
Buildings buildings;
Poi poi;
boolean ready;

// Initialiser les variables, charger les données cartographiques
void setup() {
  this.ready = false;
  fullScreen(P3D);
  //size(1000,1000,P3D);
  this.map = new Map3D("paris_saclay.data");
  this.poi = new Poi(this.map);
  this.poi.getPoints("heatmap_1.geojson");
  this.poi.getPoints("heatmap_2.geojson");
  thread("prepare");
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
  // m_camera.update();
}

void draw() {
  background(0x40);
  if (!ready) {
    textSize(45);
    textAlign(CENTER, CENTER);
    text("Loading " + String.valueOf(round(millis()/100.0f)/10.0f), width/2, height/2);
  } else {

    m_camera.update();


    this.workspace.update();
    this.railways.update();
    this.roads.update();
    land.update();
    this.poi.update();
    this.buildings.update();
    this.gpx.update(m_camera);
    hud.update(m_camera);
  }
}


//Multithreading   Charger les données cartographiques
void prepare() {
  try { 
    Thread.sleep(1000);
  } 
  catch (InterruptedException e) {
  }
  this.roads = new Roads(this.map, "roads.geojson");
  this.buildings = new Buildings(this.map);
  this.buildings.add("buildings_city.geojson", 0xFFaaaaaa);
  this.buildings.add("buildings_IPP.geojson", 0xFFCB9837);
  this.buildings.add("buildings_EDF_Danone.geojson", 0xFF3030FF);
  this.buildings.add("buildings_CEA_algorithmes.geojson", 0xFF30FF30);
  this.buildings.add("buildings_Thales.geojson", 0xFFFF3030);
  this.buildings.add("buildings_Paris_Saclay.geojson", 0xFFee00dd);
  this.poi.drawShape();
  this.ready = true;
}


//touche de raccourci pour Contrôler l'affichage de la carte et la position de la caméra
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
    case 'A':
    case 'a':
      this.land.toggle();
      break;
    case 'w':
    case 'W':
      // Hide/Show grid & Gizmo
      //this.workspace.toggle();
      this.land.wireFrame.setVisible(!this.land.wireFrame.isVisible());
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
      this.roads.toggle();
      break;
    case 'b':
    case 'B':
      this.buildings.toggle();
      break;


    case 'h':
    case 'H':
      this.poi.toggle();
      break;
    }
  }
}


//Utilisez la molette de la souris pour contrôler la distance de la caméra
void mouseWheel(MouseEvent event) {
  float ec = event.getCount();

  m_camera.adjustRadius(-250. * ec);
}

//Utilisez la souris pour contrôler la position de la caméra
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

//Afficher le point de navigation
void mousePressed() {
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY);
}
