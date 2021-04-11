//public class Buildings{
    
//    private Map3D map;
//    private ArrayList<info_building> list_building;
//    private PShape buildings;
//     private class info_building{
//        String fileName;
//        color building_color;
//        ArrayList<ArrayList<PVector>> list_maison;
        
//        info_building(String str, color c) {
//                this.fileName = str;
//            this.building_color = c;
//            this.list_maison = new ArrayList<ArrayList<PVector>>();
//        }
//    }
    
//    public Buildings(Map3D m) {
//        this.map = m;
//        list_building = new ArrayList<info_building>();

//        if(this.list_building.size() == 0){
//             println("ERROR: No building ");
//             return;
//        }
//        this.building = createShape(GROUP);

//        for(int i = 0; i < list_building.size(); i++){
//            File ressource = dataFile(list_building.get(i).fileName);
//            if (!ressource.exists() || ressource.isDirectory()) {
//             println("ERROR: GeoJSON file " + fileName + " not found.");
//            return;
//         }









//        }


//    File ressource = dataFile(fileName);
//    if (!ressource.exists() || ressource.isDirectory()) {
//      println("ERROR: GeoJSON file " + fileName + " not found.");
//      return;
//    }


//    JSONObject geojson = loadJSONObject(fileName);
//    if (!geojson.hasKey("type")) {
//      println("WARNING: Invalid GeoJSON file.");
//      return;
//    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
//      println("WARNING: GeoJSON file doesn't contain features collection.");
//      return;
//    }
//    // Parse features
//    JSONArray features = geojson.getJSONArray("features");
//    if (features == null) {
//      println("WARNING: GeoJSON file doesn't contain any feature.");
//      return;
//    }
//    for (int f=0; f<features.size(); f++) {
//       ArrayList<PVector> path = new ArrayList<PVector>();
//      JSONObject feature = features.getJSONObject(f);  
//      if (!feature.hasKey("properties"))
//        break;
//      JSONObject properties = feature.getJSONObject("properties");
//      String laneKind = "unclassified";
//      color laneColor = 0xFFFF0000;
//      double laneOffset = 1.50d;
//      float laneWidth = 0.5f;
//      // See https://wiki.openstreetmap.org/wiki/Key:highway
//      laneKind = properties.getString("highway", "unclassified");
//      if(!laneKind.equals("trunk")){
//      println("EER");
//      continue;
//      }
           
//      switch (laneKind) {
//      case "motorway":
//        laneColor = 0xFFe990a0;
//        laneOffset = 3.75d;
//        laneWidth = 8.0f;
//        break;
//      case "trunk":
//        laneColor = 0xFFfbb29a;
//        laneOffset = 3.60d;
//        laneWidth = 7.0f;
//        break;
//      case "trunk_link":
//      case "primary":
//        laneColor = 0xFFfdd7a1;
//        laneOffset = 3.45d;
//        laneWidth = 6.0f;
//        break;
//      case "secondary":
//      case "primary_link":
//        laneColor = 0xFFf6fabb;
//        laneOffset = 3.30d;
//        laneWidth = 5.0f;
//        break;
//      case "tertiary":
//      case "secondary_link":
//        laneColor = 0xFFE2E5A9;
//        laneOffset = 3.15d;
//        laneWidth = 4.0f;
//        break;
//      case "tertiary_link":
//      case "residential":
//      case "construction":
//      case "living_street":
//        laneColor = 0xFFB2B485;
//        laneOffset = 3.00d;
//        laneWidth = 3.5f;
//        break;
//      case "corridor":
//      case "cycleway":
//      case "footway":
//      case "path":
//      case "pedestrian":
//      case "service":
//      case "steps":
//      case "track":
//      case "unclassified":
//        laneColor = 0xFFcee8B9;
//        laneOffset = 2.85d;
//        laneWidth = 1.0f;
//        break;
//      default:
//        laneColor = 0xFFFF0000;
//        laneOffset = 1.50d;
//        laneWidth = 0.5f;
//        println("WARNING: Roads kind not handled : ", laneKind);
//        break;
//      }
//      // Display threshold (increase if more performance needed...)
//      if (laneWidth < 1.0f)
//        break;
        
//      if (!feature.hasKey("geometry"))
//        break;
//      JSONObject geometry = feature.getJSONObject("geometry");
//      switch (geometry.getString("type", "undefined")) {
//      case "LineString":

//        JSONArray coordinates = geometry.getJSONArray("coordinates");
//        if (coordinates != null)
//          for (int p=0; p < coordinates.size(); p++) {
//            JSONArray point = coordinates.getJSONArray(p);
//            Map3D.GeoPoint gp = this.map.new GeoPoint(point.getDouble(0), point.getDouble(1));
//            if (gp.inside()) {
//              gp.elevation += laneOffset;
//              Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
//              path.add(op.toVector());
//            }
//          }
//        list_path.add( new lane(laneColor, laneWidth, path) );
//        break;

//      default:
//        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometrytype not handled.");
//        break;
//      }
//    }





































//    }
    
//    public void add(String str, color c) {
//        list_building.add(new info_building(str,c));
//    }




































    
    
//}
