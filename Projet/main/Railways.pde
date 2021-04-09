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


    for (int i =list_path.size()-1; i>=0; i--) {
      if (list_path.get(i).size() < 3) {
        ArrayList<PVector> del =list_path.get(i);
        this.list_path.remove(del);
      }
    }



    list_path.sort( new Comparator<ArrayList<PVector>>() {
      public int compare(ArrayList<PVector> o1, ArrayList<PVector> o2) {
        int i = (o1.get(0).x > o2.get(0).x )? 1: -1;
        return i;
      }
    }
    );


    ArrayList<ArrayList<PVector>> list_pathVersParis = new ArrayList<ArrayList<PVector>>();
    ArrayList<ArrayList<PVector>> list_pathVersSRC = new ArrayList<ArrayList<PVector>>();
    for (int i = 1; i<=list_path.size(); i+=2 ) {

      //Map3D.GeoPoint gA = this.map.new GeoPoint(list_path.get(i-1).get(0).x, list_path.get(i-1).get(0).y);
      //Map3D.GeoPoint gB = this.map.new GeoPoint(list_path.get(i).get(0).x, list_path.get(i).get(0).y);
      PVector A = list_path.get(i-1).get(0);
      PVector B = list_path.get(i).get(0);
      if (i==9) {
        list_pathVersSRC.add(list_path.get(i-1));
        list_pathVersSRC.add(list_path.get(i));
      } else if ( A.y<B.y || A.x * A.x + A.y * A.y < B.x * B.x + B.y * B.y  ) {
        list_pathVersParis.add(list_path.get(i-1));
        list_pathVersSRC.add(list_path.get(i));
      } else {
        list_pathVersSRC.add(list_path.get(i-1));
        list_pathVersParis.add(list_path.get(i));
      }
    }




    float laneWidth = 2.0f;
    for (int i =0; i<list_pathVersParis.size(); i++) {
      PShape lane = createShape();
      lane.beginShape(QUAD_STRIP);
      lane.stroke(0xAAFFFFFF);
      lane.fill(0xAAFFFFFF);
      lane.strokeWeight(1.0f);
      for (int j=1; j <list_pathVersParis.get(i).size(); j++) {



        PVector A = list_pathVersParis.get(i).get(j-1);
        PVector B = list_pathVersParis.get(i).get(j);


        PVector Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x + Va.x, A.y + Va.y, A.z);

        if (i!=(list_pathVersParis.size()-1) && j == (list_pathVersParis.get(i).size()-1) ) {

          PVector C = list_pathVersParis.get(i+1).get(0);
          PVector D = list_pathVersParis.get(i+1).get(1);
          if (C.x == B.x) {
            C = list_pathVersParis.get(i+1).get(1);
            D = list_pathVersParis.get(i+1).get(2);
          }

          PVector Vb = new PVector(B.y - C.y, C.x - B.x).normalize().mult(laneWidth/2.0f);
          lane.normal(0.0f, 0.0f, 1.0f);
          lane.vertex(B.x - Vb.x, B.y - Vb.y, B.z);
          lane.normal(0.0f, 0.0f, 1.0f);
          lane.vertex(B.x + Vb.x, B.y + Vb.y, B.z);

          PVector Vc = new PVector(C.y - D.y, D.x - C.x).normalize().mult(laneWidth/2.0f);
          lane.normal(0.0f, 0.0f, 1.0f);
          lane.vertex(C.x - Vc.x, C.y - Vc.y, C.z);
          lane.normal(0.0f, 0.0f, 1.0f);
          lane.vertex(C.x + Vc.x, C.y + Vc.y, C.z);
        }
      }
      lane.endShape();
      this.railways.addChild(lane);
    }



    for (int i =0; i<list_pathVersSRC.size(); i++) {
      PShape lane = createShape();
      lane.beginShape(QUAD_STRIP);
      lane.stroke(0xAAFFFFFF);
      lane.fill(0xAAFFFFFF);
      lane.strokeWeight(1.0f);
      for (int j=1; j <list_pathVersSRC.get(i).size(); j++) {

        //Map3D.GeoPoint gA = this.map.new GeoPoint(list_pathVersSRC.get(i).get(j-1).x, list_pathVersSRC.get(i).get(j-1).y);
        //Map3D.GeoPoint gB = this.map.new GeoPoint(list_pathVersSRC.get(i).get(j).x, list_pathVersSRC.get(i).get(j).y);
        PVector A = list_pathVersSRC.get(i).get(j-1);
        PVector B = list_pathVersSRC.get(i).get(j);
        PVector Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x + Va.x, A.y + Va.y, A.z);

        if (i!=(list_pathVersSRC.size()-1)  && j == (list_pathVersSRC.get(i).size()-1) ) {
          if (i ==3 || i == 5)
            break;


          PVector C = list_pathVersSRC.get(i+1).get(0);
          PVector D = list_pathVersSRC.get(i+1).get(1);
          PVector E = list_pathVersSRC.get(i+1).get(2);

          if (i == 2) {
            C = list_pathVersSRC.get(4).get(1);
            D = list_pathVersSRC.get(4).get(2);
          } else if (i == 4) {
            C = list_pathVersSRC.get(6).get(1);
            D = list_pathVersSRC.get(6).get(2);
          }

          if (C.x == B.x) {
            C = list_pathVersSRC.get(i+1).get(1);
            D = list_pathVersSRC.get(i+1).get(2);
          }
          PVector Vb = new PVector(B.y - C.y, C.x - B.x).normalize().mult(laneWidth/2.0f);
          lane.normal(0.0f, 0.0f, 1.0f);
          lane.vertex(B.x - Vb.x, B.y - Vb.y, B.z);
          lane.normal(0.0f, 0.0f, 1.0f);
          lane.vertex(B.x + Vb.x, B.y + Vb.y, B.z);


          PVector Vc = new PVector(C.y - D.y, D.x - C.x).normalize().mult(laneWidth/2.0f);
          lane.normal(0.0f, 0.0f, 1.0f);
          lane.vertex(C.x - Vc.x, C.y - Vc.y, C.z);
          lane.normal(0.0f, 0.0f, 1.0f);
          lane.vertex(C.x + Vc.x, C.y + Vc.y, C.z);
        }
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
