public class Gpx {  //<>// //<>//
  private Map3D map;
  private String fileName;
  private PShape track; // beginshape lines
  private PShape posts; // beginshape lines
  private PShape thumbtacks; // beginshape  points
  private PVector hit;
  private int s; // une punaise d'indice
  private boolean isclic;

  private class pTrack {
    double x ;
    double y ;

    pTrack(double x, double y) {
      this.x = x ;
      this.y = y;
    }
  }
  private class pWaypoint extends pTrack {
    String pointname;
    pWaypoint(double x, double y, String name) {
      super(x, y);
      this.pointname = name;
    }
  }

  private ArrayList<pTrack> list_pTrack = new ArrayList<pTrack>();
  private ArrayList<pWaypoint> list_pWaypoint = new ArrayList<pWaypoint>();
  Gpx(Map3D m, String s ) {
    
    this.isclic = false;
    this.map = m;
    this.fileName = s;

    //check filegpx
    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + fileName + " not found.");
      return;
    }


    JSONObject geojson = loadJSONObject(fileName);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      return;
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain features collection.");
      return;
    }
    // Parse features
    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      return;
    }
    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {
      case "LineString":
        // GPX Track
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null)
          for (int p=0; p < coordinates.size(); p++) {
            JSONArray point = coordinates.getJSONArray(p);
           
            list_pTrack.add(new pTrack(point.getDouble(0), point.getDouble(1)));
          }
        break;
      case "Point":
        // GPX WayPoint
        if (geometry.hasKey("coordinates")) {
          JSONArray point = geometry.getJSONArray("coordinates");
          String description = "Pas d'information.";
          if (feature.hasKey("properties")) {
            description = feature.getJSONObject("properties").getString("desc", description);
          }
         
          list_pWaypoint.add(new pWaypoint(point.getDouble(0), point.getDouble(1), description));
        }
        break;
      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometrytype not handled.");
        break;
      }
    }




    this.track = createShape();
    this.track.beginShape(LINES);
    this.track.stroke(0xAAFF99FF);
    this.track.strokeWeight(3.0f);

    for (int i = 1; i < list_pTrack.size(); i++) {
      Map3D.GeoPoint gp = this.map.new GeoPoint(list_pTrack.get(i-1).x, list_pTrack.get(i-1).y);
      Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
      this.track.vertex(op.x, op.y, op.z+5);
      gp = this.map.new GeoPoint(list_pTrack.get(i).x, list_pTrack.get(i).y);
      op = this.map.new ObjectPoint(gp);
      this.track.vertex(op.x, op.y, op.z+5);
    }
    this.track.endShape();

    this.posts = createShape();
    this.posts.beginShape(LINES);
    this.posts.stroke(0xAA3FFF7F);
    this.posts.strokeWeight(1.5f);
    for (pWaypoint pwp : list_pWaypoint) {
      Map3D.GeoPoint gp = this.map.new GeoPoint(pwp.x, pwp.y);
      Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
      this.posts.vertex(op.x, op.y, op.z);
      this.posts.vertex(op.x, op.y, op.z+100.);
    }
    this.posts.endShape();




    this.thumbtacks = createShape();
    this.thumbtacks.beginShape(LINES);
    this.thumbtacks.stroke(0xFFFF3F3F);
    this.thumbtacks.strokeWeight(10.f);
    for (pWaypoint pwp : list_pWaypoint) {
      Map3D.GeoPoint gp = this.map.new GeoPoint(pwp.x, pwp.y);
      Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
      this.thumbtacks.vertex(op.x, op.y, op.z+100.);
      this.thumbtacks.vertex(op.x, op.y, op.z+100.);
    }
    this.thumbtacks.endShape();
  }






  public void update(Camera c) {
    if (this.track.isVisible()) {
      shape(this.track);
      shape(this.posts);
      shape(this.thumbtacks);

      //displayPointName(c, hit , s);
      if (this.isclic)
        this.displayPointName(c, this.hit, s);
    }
  }

  public void toggle() {
    this.track.setVisible(!this.track.isVisible());
    this.posts.setVisible(!this.posts.isVisible());
    this.thumbtacks.setVisible(!this.thumbtacks.isVisible());
  }

  public void clic(int x, int y) {
    int p;
    this.isclic = false;
    for (int v =0; v<this.thumbtacks.getVertexCount(); v++) {

      hit = this.thumbtacks.getVertex(v);
      float theX = screenX(hit.x, hit.y, hit.z);
      float theY = screenY(hit.x, hit.y, hit.z);

      if (dist(x, y, theX, theY) <= 13.f) {
        this.s = v;
        this.isclic = true;
        this.thumbtacks.setStroke(s, 0xFF3FFF7F);
      } else {
        p = v;
        this.thumbtacks.setStroke(p, 0xFFFF3F3F);
      }
    }
    this.hit = this.thumbtacks.getVertex(this.s);
  }

  private void displayPointName(Camera camera, PVector hit, int s) {

    pushMatrix();
    lights();
    fill(0xFFFFFFFF);
    translate(hit.x + 15.f, hit.y, hit.z + 10.0f);
    rotateZ(-camera.longitude-HALF_PI);
    rotateX(-camera.colatitude);
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    textMode(SHAPE);
    textSize(35);
    textAlign(LEFT, CENTER);
    text(list_pWaypoint.get(s).pointname, 0, 0);
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    popMatrix();
  }
}
