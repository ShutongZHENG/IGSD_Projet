public class Buildings {

  private Map3D map;
  private ArrayList<info_building> list_building;
  private PShape buildings;


  private class info_building {
    String fileName;
    color building_color;
    ArrayList<oneBuilding> list_maison;

    info_building(String str, color c) {
      this.fileName = str;
      this.building_color = c;
      this.list_maison = new ArrayList<oneBuilding>();
    }
  }


  private class oneBuilding {
    ArrayList<PVector> maisonCord;
    float top;
    oneBuilding(ArrayList<PVector> P, float t) {
      this.top = t;
      this.maisonCord = P;
    }
  }





  public Buildings(Map3D m) {
    this.map = m;
    list_building = new ArrayList<info_building>();
    this.buildings= createShape(GROUP);
  }

  void update() {
    if (buildings.isVisible())
      shape(buildings);
  }


  public void add(String str, color c) {
    info_building oneListbuilding  = new info_building(str, c);
    info_building listNotopbuilding = new info_building(str, c);
    File ressource = dataFile(oneListbuilding.fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + oneListbuilding.fileName + " not found.");
      return;
    }


    JSONObject geojson = loadJSONObject(oneListbuilding.fileName);
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
  w :
    for (int f=0; f<features.size(); f++) {

      ArrayList<PVector> path = new ArrayList<PVector>();
      ArrayList<PVector> noToppath = new ArrayList<PVector>();

      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      if (!feature.hasKey("properties"))
        break;
      JSONObject properties = feature.getJSONObject("properties");
      switch (geometry.getString("type", "undefined")) {
      case "Polygon":

        JSONArray coordinates = geometry.getJSONArray("coordinates");
        int levels = properties.getInt("building:levels", 1);
        float top = Map3D.heightScale * 3.0f * (float)levels;
        if (coordinates != null) {
          JSONArray point = coordinates.getJSONArray(0);
          // JSONArray point = coordinates.getJSONArray(p);
          for (int p=0; p < coordinates.getJSONArray(0).size(); p++) {
            Map3D.GeoPoint gp = this.map.new GeoPoint(point.getJSONArray(p).getDouble(0), point.getJSONArray(p).getDouble(1));
            //gp.elevation += 5.0d;
            if (gp.inside() && properties.hasKey("building:levels")) {
              Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
              path.add(op.toVector());
            } else if (gp.inside() && !properties.hasKey("building:levels")) {
              Map3D.ObjectPoint op = this.map.new ObjectPoint(gp);
              noToppath.add(op.toVector());
            } else {
              continue w;
            }
          }
        }
        if (path.size()>2)        
          oneListbuilding.list_maison.add(new oneBuilding(path, top));
        if (noToppath.size()<3)
          continue w;
        listNotopbuilding.list_maison.add(new oneBuilding(noToppath, Map3D.heightScale * 3.0f*1.f));


        
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometrytype not handled.");
        break;
      }
    }
    this.list_building.add(oneListbuilding);

    this.creatBuild(oneListbuilding);
     this.creatNotopBuild(listNotopbuilding);
  }

  void creatNotopBuild(info_building B) {

    for (int j =0; j< B.list_maison.size(); j++) {
      PShape walls;
      walls = createShape();
      walls.beginShape(QUAD_STRIP);
      walls.noStroke();
      //walls.stroke(B.building_color);
      walls.fill(B.building_color);
      //walls.strokeWeight(0.5f);

      PShape roof;
      roof = createShape();
      roof.beginShape();
      roof.noStroke();
      //roof.stroke(B.building_color);
      roof.fill(B.building_color);
     // roof.strokeWeight(0.5f);
      roof.emissive(0x60);

      //
      /*
         a=(y2-y1)(z3-z1)-(z2-z1)(y3-y1)
       b=(z2-z1)(x3-x1)-(z3-z1)(x2-x1)
       c=(x2-x1)(y3-y1)-(x3-x1)(y2-y1)
       */

      //PVector vA  =   B.list_maison.get(j).maisonCord.get(0);
      //PVector vB  =   B.list_maison.get(j).maisonCord.get(1);
      //PVector vC  =   B.list_maison.get(j).maisonCord.get(2);

      //PVector  normale = new PVector((vB.y-vA.y)*(vC.z-vA.z)-(vB.z-vA.z)*(vC.y-vA.y), (vB.z-vA.z)*(vC.x-vA.x)-(vC.z-vA.z)*(vB.x-vA.x), (vB.x-vA.x)*(vC.y-vA.y)-(vC.x-vA.x)*(vB.y-vA.y)).normalize().mult(Map3D.heightScale * 3.0f);
      for (int k =0; k<B.list_maison.get(j).maisonCord.size(); k++) {

        PVector A = B.list_maison.get(j).maisonCord.get(k);   
        walls.normal(0.0f, 0.0f, 1.0f);
        walls.vertex(A.x, A.y, A.z);
        walls.normal(0.0f, 0.0f, 1.0f);
        walls.vertex(A.x, A.y, A.z+B.list_maison.get(j).top);
        roof.normal(0.0f, 0.0f, 1.0f);
        roof.vertex(A.x, A.y, A.z+B.list_maison.get(j).top);
        //roof.normal(0.0f, 0.0f, 1.0f);
        //if (A.z>A.z+normale.z) {
        //  walls.vertex(A.x-normale.x, A.y-normale.y, A.z-normale.z);
        //  roof.vertex(A.x-normale.x, A.y-normale.y, A.z-normale.z );
        //} else {
        //  walls.vertex(A.x+normale.x, A.y+normale.y, A.z+normale.z);
        //  roof.vertex(A.x+normale.x, A.y+normale.y, A.z+normale.z);
        //}
      }
      walls.endShape();
      this.buildings.addChild(walls); 
     
      roof.endShape();
      this.buildings.addChild(roof); 

    }
  }





  void creatBuild(info_building B) {




    for (int j =0; j< B.list_maison.size(); j++) {

      PShape walls;
      walls = createShape();
      walls.beginShape(QUAD_STRIP);
      //walls.stroke(B.building_color);
      walls.fill(B.building_color);
    //  walls.strokeWeight(0.5f);
      walls.emissive(0x30);
      walls.noStroke();


      //PVector vA  =   B.list_maison.get(j).maisonCord.get(0);
      //PVector vB  =   B.list_maison.get(j).maisonCord.get(1);
      //PVector vC  =   B.list_maison.get(j).maisonCord.get(2);

  //    PVector  normale = new PVector((vB.y-vA.y)*(vC.z-vA.z)-(vB.z-vA.z)*(vC.y-vA.y), (vB.z-vA.z)*(vC.x-vA.x)-(vC.z-vA.z)*(vB.x-vA.x), (vB.x-vA.x)*(vC.y-vA.y)-(vC.x-vA.x)*(vB.y-vA.y)).normalize().mult(B.list_maison.get(j).top);


      for (int k =0; k<B.list_maison.get(j).maisonCord.size(); k++) {
        PVector A = B.list_maison.get(j).maisonCord.get(k);
        
        walls.normal(0.0f, 0.0f, 1.0f);
        walls.vertex(A.x, A.y, A.z);
        walls.normal(0.0f, 0.0f, 1.0f);
        walls.vertex(A.x, A.y, A.z+B.list_maison.get(j).top);
      //  if (A.z>A.z+normale.z) {
      //    walls.vertex(A.x-normale.x, A.y-normale.y, A.z-normale.z);
      //  } else {
      //    walls.vertex(A.x+normale.x, A.y+normale.y, A.z+normale.z);
      //  }
      }
      walls.endShape();
      this.buildings.addChild(walls); 
     
    }




    //roof
  
    for (int j =0; j< B.list_maison.size(); j++) {
      PShape roof;
      roof = createShape();
      roof.beginShape();
      roof.noStroke();
      //roof.stroke(B.building_color);
      roof.fill(B.building_color);
      //roof.strokeWeight(0.5f);
      roof.emissive(0x60);
      //PVector vA  =   B.list_maison.get(j).maisonCord.get(0);
      //PVector vB  =   B.list_maison.get(j).maisonCord.get(1);
      //PVector vC  =   B.list_maison.get(j).maisonCord.get(2);
      //PVector  normale = new PVector((vB.y-vA.y)*(vC.z-vA.z)-(vB.z-vA.z)*(vC.y-vA.y), (vB.z-vA.z)*(vC.x-vA.x)-(vC.z-vA.z)*(vB.x-vA.x), (vB.x-vA.x)*(vC.y-vA.y)-(vC.x-vA.x)*(vB.y-vA.y)).normalize().mult(B.list_maison.get(j).top);
      for (int k =0; k<B.list_maison.get(j).maisonCord.size(); k++) {
        PVector A = B.list_maison.get(j).maisonCord.get(k);

        roof.normal(0.0f, 0.0f, 1.0f);
        roof.vertex(A.x, A.y, A.z+B.list_maison.get(j).top);
        //if (A.z>A.z+normale.z) {
        //  roof.vertex(A.x-normale.x, A.y-normale.y, A.z-normale.z);
        //} else {
        //  roof.vertex(A.x+normale.x, A.y+normale.y, A.z+normale.z);
        //}
      }
      roof.endShape();
      this.buildings.addChild(roof); 
      
    }
  }

  void toggle() {
    this.buildings.setVisible(!this.buildings.isVisible());
  }
}
