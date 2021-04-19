import java.util.*;

public class Poi {
  PShader heat;
  private String fileName;
  private Map3D map;
  private PShape land;
  private Map<String, ArrayList<PVector>> listHeat;  
  Poi(Map3D m ) {
    listHeat = new HashMap<String, ArrayList<PVector>>();
    this.map = m;
    this.heat = loadShader("heatFrag.glsl","heatVert.glsl");
  }
  public Map<String, ArrayList<PVector>>  getPoints(String fileName) {
    this.fileName = fileName;
    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + fileName + " not found.");
      return null;
    }


    JSONObject geojson = loadJSONObject(this.fileName);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      return null;
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain features collection.");
      return null;
    }
    // Parse features
    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      return null;
    }

    for (int f=0; f<features.size(); f++) {
      PVector path = new PVector() ;
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject properties = feature.getJSONObject("properties");
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {
      case "Point":


        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null) {

          Map3D.GeoPoint gp = this.map.new GeoPoint(coordinates.getDouble(0), coordinates.getDouble(1));
          if (gp.inside()) {
            Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
            path= op.toVector();
          }



          switch (properties.getString("amenity", "undefined")) {
          case "bench":
            if (listHeat.containsKey("bench")) {
              ArrayList<PVector> P = listHeat.get("bench");
              P.add(path);
              listHeat.replace("bench", P);
            } else {
              ArrayList<PVector> P =  new ArrayList<PVector>();
              P.add(path);
              listHeat.put("bench", P);
            }
           // println("Bench", path);
            break;

          case "bicycle_parking":
            if (listHeat.containsKey("bicycle_parking")) {
              ArrayList<PVector> P = listHeat.get("bicycle_parking");
              P.add(path);
              listHeat.replace("bicycle_parking", P);
            } else {
              ArrayList<PVector> P =  new ArrayList<PVector>();
              P.add(path);
              listHeat.put("bicycle_parking", P);
            }
           // println("bicycle_parking", path);
            break;

          //case "picnic_table":

          //  if (listHeat.containsKey("picnic_table")) {
          //    ArrayList<PVector> P = listHeat.get("picnic_table");
          //    P.add(path);
          //    listHeat.replace("picnic_table", P);
          //  } else {
          //    ArrayList<PVector> P =  new ArrayList<PVector>();
          //    P.add(path);
          //    listHeat.put("picnic_table", P);
          //  }
          //  println("picnic_table", path);
          //  break;

          default:
             if (listHeat.containsKey("picnic_table")) {
              ArrayList<PVector> P = listHeat.get("picnic_table");
              P.add(path);
              listHeat.replace("picnic_table", P);
            } else {
              ArrayList<PVector> P =  new ArrayList<PVector>();
              P.add(path);
              listHeat.put("picnic_table", P);
            }
            //println("picnic_table", path);
            break;
          }
        }
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometry type not handled.");
        break;
      }
    }
    
    return listHeat;
  }

  void drawShape() {



    float tileSize = 10f;
    float w = (float)Map3D.width;
    float h = (float)Map3D.height;
    println(w,"   ",h);
    this.land = createShape(GROUP);
    for ( float i = -w/2.0f; i< +w/2.0f; i+=tileSize) {
        for ( float j = -h/2.0f; j< +h/2.0f; j+=tileSize) {
        PShape p;
        p = createShape();
        p.beginShape(QUADS);
        p.noStroke();
        Map3D.ObjectPoint pone = this.map.new ObjectPoint(i, j);
        Map3D.ObjectPoint ptwo = this.map.new ObjectPoint(i, j+tileSize);
        Map3D.ObjectPoint pthree = this.map.new ObjectPoint(i+tileSize, j);
        Map3D.ObjectPoint pfour = this.map.new ObjectPoint(i+tileSize, j+tileSize);
    //    // calculer dist() ---> ParkingDistance

        float Dis_pone = abs(dist(pone.x, pone.y, pone.z, listHeat.get("bicycle_parking").get(0).x, listHeat.get("bicycle_parking").get(0).y, listHeat.get("bicycle_parking").get(0).z) );
        for (int a =1; a < listHeat.get("bicycle_parking").size(); a++) {
          float A = abs(dist(pone.x, pone.y, pone.z, listHeat.get("bicycle_parking").get(a).x, listHeat.get("bicycle_parking").get(a).y, listHeat.get("bicycle_parking").get(a).z) );
          if (A<Dis_pone) {
            Dis_pone = A;
          }
        }

        
        float nearestBykeParkingDistance = Dis_pone;
   //    println("nearestBykeParkingDistance x : y ",pone.x," " ,pone.y);
        //calculer dis_ picnic_table
        
         Dis_pone = abs(dist(pone.x, pone.y, pone.z, listHeat.get("picnic_table").get(0).x, listHeat.get("picnic_table").get(0).y, listHeat.get("picnic_table").get(0).z) );
          for (int a =1; a < listHeat.get("bench").size(); a++) {
          float A = abs(dist(pone.x, pone.y, pone.z, listHeat.get("bench").get(a).x, listHeat.get("bench").get(a).y, listHeat.get("bench").get(a).z) );
          if (A<Dis_pone) {
            Dis_pone = A;
          }
        }
        for (int a =1; a < listHeat.get("picnic_table").size(); a++) {
          float A = abs(dist(pone.x, pone.y, pone.z, listHeat.get("picnic_table").get(a).x, listHeat.get("picnic_table").get(a).y, listHeat.get("picnic_table").get(a).z) );
          if (A<Dis_pone) {
            Dis_pone = A;
          }
        }
        float nearestPicNicTableDistance = Dis_pone;
       //println("nearestPicNicTableDistance x : y ",pone.x," " ,pone.y);
       //println("a : b" ,nearestBykeParkingDistance,nearestPicNicTableDistance, "COS --->", cos(nearestBykeParkingDistance/1000/2*3.1415926));
        p.attrib("heat", nearestBykeParkingDistance, nearestPicNicTableDistance);
        
        
        
        p.vertex(pone.x, pone.y, pone.z+5.);
        
        p.vertex(ptwo.x, ptwo.y, ptwo.z+5.);
        
        
        p.vertex(pfour.x, pfour.y, pfour.z+5.);
        p.vertex(pthree.x, pthree.y, pthree.z+5.);
        
        //p.vertex(pfour.x, pfour.y, pfour.z);
        
        
        p.endShape();
        this.land.addChild(p);
        
     }
    }

   // this.land.endShape();
  
    
  }







  void update() {
if(this.land.isVisible()){
  shader(this.heat);
  this.heat.set("u_time",float(millis())/500.0 );
  shape(land);
  resetShader();
}
  }
  
  void toggle() {
    this.land.setVisible(!this.land.isVisible());

  }
}
