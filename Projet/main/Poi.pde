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
    this.heat = loadShader("heat.glsl","heatFrag.glsl");
  }
  public void getPoints(String fileName) {
    this.fileName = fileName;
    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + fileName + " not found.");
      return;
    }


    JSONObject geojson = loadJSONObject(this.fileName);
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
            println("picnic_table", path);
            break;
          }
        }
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometry type not handled.");
        break;
      }
    }
  }

  void drawShape() {



    float tileSize = 25.0f;
    float w = (float)Map3D.width;
    float h = (float)Map3D.height;
    this.land = createShape();
    this.land.beginShape(POINTS);

    for ( float i = -w/2.0f; i< +w/2.0f; i+=tileSize) {
      for ( float j = -h/2.0f; j< +h/2.0f; j+=tileSize) {

        Map3D.ObjectPoint pone = this.map.new ObjectPoint(i, j);
        // calculer dist() ---> ParkingDistance

        float Dis_pone = abs(dist(pone.x, pone.y, pone.z, listHeat.get("bicycle_parking").get(0).x, listHeat.get("bicycle_parking").get(0).y, listHeat.get("bicycle_parking").get(0).z) );
        for (int a =1; a < listHeat.get("bicycle_parking").size(); a++) {
          float A = abs(dist(pone.x, pone.y, pone.z, listHeat.get("bicycle_parking").get(a).x, listHeat.get("bicycle_parking").get(a).y, listHeat.get("bicycle_parking").get(a).z) );
          if (A<Dis_pone) {
            Dis_pone = A;
          }
        }
        float nearestBykeParkingDistance = Dis_pone;

        //calculer dis_ picnic_table
        Dis_pone = abs(dist(pone.x, pone.y, pone.z, listHeat.get("picnic_table").get(0).x, listHeat.get("picnic_table").get(0).y, listHeat.get("picnic_table").get(0).z) );
        for (int a =1; a < listHeat.get("picnic_table").size(); a++) {
          float A = abs(dist(pone.x, pone.y, pone.z, listHeat.get("picnic_table").get(a).x, listHeat.get("picnic_table").get(a).y, listHeat.get("picnic_table").get(a).z) );
          if (A<Dis_pone) {
            Dis_pone = A;
          }
        }
        float nearestPicNicTableDistance = Dis_pone;

        this.land.attrib("heat", nearestBykeParkingDistance, nearestPicNicTableDistance);

        this.land.vertex(pone.x, pone.y, pone.y);
      }
    }

    this.land.endShape();
  }





  void update() {
    
    shape(land);
  }
}
