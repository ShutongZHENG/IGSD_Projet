import java.util.*;
public class Railways {
  private Map3D map;
  private String fileName;
  private PShape railways;

  private ArrayList<ArrayList<PVector>> list_path = new ArrayList<ArrayList<PVector>>();
  Railways(Map3D m, String s) {
    this.map = m;
    this.fileName = s;
    this.railways = createShape(GROUP);
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
      ArrayList<PVector> path = new ArrayList<PVector>();


      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {
      case "LineString":

        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null)
          for (int p=0; p < coordinates.size(); p++) {
            JSONArray point = coordinates.getJSONArray(p);
            Map3D.GeoPoint gp = this.map.new GeoPoint(point.getDouble(0), point.getDouble(1));
            if (gp.inside()) {
              gp.elevation += 7.5d;
              Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
              path.add(op.toVector());
            }
          }
        list_path.add(path);
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometrytype not handled.");
        break;
      }
    }


    for (int i =0; i<list_path.size(); i++) {
      if (list_path.get(i).get(0).x > list_path.get(i).get(1).x) {
        Collections.reverse(list_path.get(i));
      }
    }
    //list_path.sort( new Comparator<ArrayList<PVector>>() {
    //  public int compare(ArrayList<PVector> o1, ArrayList<PVector> o2) {
    //    int i = (o1.get(0).x > o2.get(0).x )? 1: -1;
    //    return i;
    //  }
    //}
    //);
    
    float laneWidth = 4.0f;
    for (int i =0; i<list_path.size(); i++) {

      PShape lane = createShape();
      lane.beginShape(QUAD_STRIP);
      lane.noStroke();
      lane.fill(255,255,255);
      boolean isgetBefore = false;
      for (int j=1; j <list_path.get(i).size(); j++) {
        if (j ==1 ) {
          PVector A = list_path.get(i).get(j-1);      
          PVector B = list_path.get(i).get(j);       
          for (int n=0; n<list_path.size(); n++) {
            if (n == i)
              continue;
            if (list_path.get(n).get(0).x == A.x && list_path.get(n).get(0).y == A.y) {
              A = list_path.get(n).get(1);  
              B = list_path.get(i).get(j-1);
              isgetBefore = true;
              break;
            } else if (list_path.get(n).get(list_path.get(n).size()-1).x == A.x && list_path.get(n).get(list_path.get(n).size()-1).y == A.y) {
              A = list_path.get(n).get(list_path.get(n).size()-2);  
              B = list_path.get(i).get(j-1);
              isgetBefore = true;
              break;
            }
          }
          if (isgetBefore  ) {
            PVector Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
            Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
            lane.normal(0.0f, 0.0f, 1.0f);
            lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
            lane.normal(0.0f, 0.0f, 1.0f);
            lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
          }
        }

        PVector A = list_path.get(i).get(j-1);      
        PVector B = list_path.get(i).get(j);
        PVector Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
      }
      lane.endShape();
      this.railways.addChild(lane);
    }
  }

  void update() {
    if (this.railways.isVisible())
      shape(this.railways);
  }

  void toggle() {
    this.railways.setVisible(!this.railways.isVisible());
  }
}
