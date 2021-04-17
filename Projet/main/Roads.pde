import java.util.*;
import java.lang.String;
public class Roads {
  private Map3D map;
  private String fileName;
  private PShape roads;


  class lane {
    color laneColor;
    float laneWidth;
    ArrayList<PVector> Vop = new ArrayList<PVector>();

    lane(color c, float w, ArrayList<PVector> V) {
      this.laneColor = c;
      this.laneWidth = w;
      this.Vop = V ;
    }
  }


  private Map<String, ArrayList<lane>> list_path = new HashMap<String, ArrayList<lane>>();

  Roads(Map3D m, String s) {
    this.map = m;
    this.fileName = s;
    this.roads = createShape(GROUP);
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
      if (!feature.hasKey("properties"))
        break;
      JSONObject properties = feature.getJSONObject("properties");
      String laneKind = "unclassified";
      color laneColor = 0xFFFF0000;
      double laneOffset = 1.50d;
      float laneWidth = 0.5f;
      // See https://wiki.openstreetmap.org/wiki/Key:highway
      laneKind = properties.getString("highway", "unclassified");        
      switch (laneKind) {
      case "motorway":
        laneColor = 0xFFe990a0;
        laneOffset = 3.75d;
        laneWidth = 8.0f;
        break;
      case "trunk":
        laneColor = 0xFFfbb29a;
        laneOffset = 3.60d;
        laneWidth = 7.0f;
        break;
      case "trunk_link":
      case "primary":
        laneColor = 0xFFfdd7a1;
        laneOffset = 3.45d;
        laneWidth = 6.0f;
        break;
      case "secondary":
      case "primary_link":
        laneColor = 0xFFf6fabb;
        laneOffset = 3.30d;
        laneWidth = 5.0f;
        break;
      case "tertiary":
      case "secondary_link":
        laneColor = 0xFFE2E5A9;
        laneOffset = 3.15d;
        laneWidth = 4.0f;
        break;
      case "tertiary_link":
      case "residential":
      case "construction":
      case "living_street":
        laneColor = 0xFFB2B485;
        laneOffset = 3.00d;
        laneWidth = 3.5f;
        break;
      case "corridor":
      case "cycleway":
      case "footway":
      case "path":
      case "pedestrian":
      case "service":
      case "steps":
      case "track":
      case "unclassified":
        laneColor = 0xFFcee8B9;
        laneOffset = 2.85d;
        laneWidth = 1.0f;
        break;
      default:
        laneColor = 0xFFFF0000;
        laneOffset = 1.50d;
        laneWidth = 0.5f;
        println("WARNING: Roads kind not handled : ", laneKind);
        break;
      }
      // Display threshold (increase if more performance needed...)
      if (laneWidth < 1.0f)
        break;

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
              gp.elevation += laneOffset;
              Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
              path.add(op.toVector());
            }
          }
        if (path.isEmpty() || path.size() ==1)
          break;
        if(list_path.containsKey(laneKind)){
            ArrayList<lane> L = list_path.get(laneKind);
            L.add(new lane(laneColor, laneWidth, path));
            list_path.replace(laneKind,L);
        }else{
            ArrayList<lane> L =  new ArrayList<lane>();
            L.add(new lane(laneColor, laneWidth, path));
            list_path.put(laneKind, L);
        }

        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometrytype not handled.");
        break;
      }
    }


    for( ArrayList<lane> L : list_path.values() ){
      
        drawMap(L);
    }
    //for debug
    //for(Map.Entry<String, ArrayList<lane>> entry : list_path.entrySet()){
    //   // println(entry.getKey());
    //    drawMap(entry.getValue());
    
    //}
    
    
  }

  void update() {
    if (this.roads.isVisible())
      shape(this.roads);
  }

  void toggle() {
    this.roads.setVisible(!this.roads.isVisible());
  }

  //void drawMap(ArrayList<lane> L) {
   
  //  for (int i =0; i<L.size(); i++) {
  //    float laneWidth = L.get(i).laneWidth;
  //    PShape lane = createShape();
  //    lane.beginShape(QUAD_STRIP);
  //    lane.stroke(L.get(i).laneColor);
  //    lane.fill(L.get(i).laneColor);
  //    lane.strokeWeight(1.75f);
  //    lane.noStroke();
  //    boolean isgetBefore = false;
  //    for (int j=1; j<L.get(i).Vop.size(); j++) {
     
  //      if (j ==1 ) {
  //        PVector A = L.get(i).Vop.get(j-1);      
  //        PVector B = L.get(i).Vop.get(j);       
  //        for (int n=0; n<L.size(); n++) {
  //          if (n == i)
  //            continue;
  //          if (L.get(n).Vop.get(L.get(n).Vop.size()-1).x == A.x && L.get(n).Vop.get(L.get(n).Vop.size()-1).y == A.y) {
  //            A = L.get(n).Vop.get(L.get(n).Vop.size()-2);  
  //            B = L.get(i).Vop.get(j-1);
  //            isgetBefore = true;
  //            break;
  //          }
  //        }

  //        if (isgetBefore) {
  //          PVector Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
  //          Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
  //          lane.normal(0.0f, 0.0f, 1.0f);
  //          lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
  //          lane.normal(0.0f, 0.0f, 1.0f);
  //          lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
  //        }
  //      }
  //      PVector A = L.get(i).Vop.get(j-1);      
  //      PVector B = L.get(i).Vop.get(j);
  //      PVector Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
  //      lane.normal(0.0f, 0.0f, 1.0f);
  //      lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
  //      lane.normal(0.0f, 0.0f, 1.0f);
  //      lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
  //    }
  //    lane.endShape();
  //    this.roads.addChild(lane);
  //  }
  //}
  
  
  void drawMap(ArrayList<lane> L) {
   
    for (int i =0; i<L.size(); i++) {
      float laneWidth = L.get(i).laneWidth;
      PShape lane = createShape();
      lane.beginShape(QUAD_STRIP);
      lane.stroke(L.get(i).laneColor);
      lane.fill(L.get(i).laneColor);
      lane.strokeWeight(1.75f);
      lane.noStroke();
      for (int j=1; j<L.get(i).Vop.size(); j++) {
     

        PVector A = L.get(i).Vop.get(j-1);      
        PVector B = L.get(i).Vop.get(j);
        PVector Va = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B.x - Va.x, B.y - Va.y, B.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B.x + Va.x, B.y + Va.y, B.z);
      }
      lane.endShape();
      this.roads.addChild(lane);
      
    }
    
    
    
      for (int i =0; i<L.size(); i++) {
      float laneWidth = L.get(i).laneWidth;
      PShape lane = createShape();
      lane.beginShape(QUAD_STRIP);
      lane.stroke(L.get(i).laneColor);
      lane.fill(L.get(i).laneColor);
      lane.strokeWeight(1.75f);
      lane.noStroke();
      PVector A = L.get(i).Vop.get(0);
      for (int j=0; j<L.size(); j++) {
        if(i == j)
        continue;
        
        PVector B_1 = L.get(j).Vop.get(0);
        PVector B_2 = L.get(j).Vop.get(L.get(j).Vop.size()-1);
        if(B_1.x == A.x && B_1.y == A.y){
           B_1 = L.get(j).Vop.get(1);
        PVector Va = new PVector(A.y - B_1.y, B_1.x - A.x).normalize().mult(laneWidth/2.0f);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
        
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B_1.x - Va.x, B_1.y - Va.y, B_1.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B_1.x + Va.x, B_1.y + Va.y, B_1.z);
        
        }
        else if (B_2.x == A.x && B_2.y == A.y){
          B_2 = L.get(j).Vop.get(L.get(j).Vop.size()-2);
        PVector Va = new PVector(A.y - B_2.y, B_2.x - A.x).normalize().mult(laneWidth/2.0f);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
        
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B_2.x - Va.x, B_2.y - Va.y, B_2.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B_2.x + Va.x, B_2.y + Va.y, B_2.z);
        
        }

        
      }
      lane.endShape();
      this.roads.addChild(lane);
      
      lane = createShape();
      lane.beginShape(QUAD_STRIP);
      lane.stroke(L.get(i).laneColor);
      lane.fill(L.get(i).laneColor);
      lane.strokeWeight(1.75f);
      lane.noStroke();
       A = L.get(i).Vop.get(L.get(i).Vop.size()-1);
      for (int j=0; j<L.size(); j++) {
        if(i == j)
        continue;
        
        PVector B_1 = L.get(j).Vop.get(0);
        PVector B_2 = L.get(j).Vop.get(L.get(j).Vop.size()-1);
        if(B_1.x == A.x && B_1.y == A.y){
           B_1 = L.get(j).Vop.get(1);
        PVector Va = new PVector(A.y - B_1.y, B_1.x - A.x).normalize().mult(laneWidth/2.0f);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
        
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B_1.x - Va.x, B_1.y - Va.y, B_1.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B_1.x + Va.x, B_1.y + Va.y, B_1.z);
        
        }
        else if (B_2.x == A.x && B_2.y == A.y){
          B_2 = L.get(j).Vop.get(L.get(j).Vop.size()-2);
        PVector Va = new PVector(A.y - B_2.y, B_2.x - A.x).normalize().mult(laneWidth/2.0f);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x - Va.x, A.y - Va.y, A.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(A.x + Va.x, A.y + Va.y, A.z);
        
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B_2.x - Va.x, B_2.y - Va.y, B_2.z);
        lane.normal(0.0f, 0.0f, 1.0f);
        lane.vertex(B_2.x + Va.x, B_2.y + Va.y, B_2.z);
        
        }

        
      }
      lane.endShape();
      this.roads.addChild(lane);
      
      
    
  
}
    
  }
}
