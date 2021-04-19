public class Buildings {

  private Map3D map;
  private ArrayList<info_building> list_building;
  private PShape buildings;

  // la classe info_building  pour définir la collection de toutes les informations sur la maison dans un fichier.geojson
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

  // la classe oneBuilding pour définir la hauteur et l'emplacement d'une maison
  private class oneBuilding {
    ArrayList<PVector> maisonCord;
    float top;
    oneBuilding(ArrayList<PVector> P, float t) {
      this.top = t;
      this.maisonCord = P;
    }
  }




  //Initialiser la classe Buildings
  public Buildings(Map3D m) {
    this.map = m;
    list_building = new ArrayList<info_building>();
    this.buildings= createShape(GROUP);
  }



  //Afficher le bâtiment
  void update() {
    if (buildings.isVisible())
      shape(buildings);
  }

  //Analysez et filtrez les données dans le fichier gejson pour stocker les données de la maison dans différentes collections
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


  //Modélisez les bâtiments où le nombre d'étages n'est pas mentionné dans le fichier geojson

  void creatNotopBuild(info_building B) {

    for (int j =0; j< B.list_maison.size(); j++) {
      PShape walls;
      walls = createShape();
      walls.beginShape(QUAD_STRIP);
      walls.noStroke();
      walls.fill(B.building_color);

      PShape roof;
      roof = createShape();
      roof.beginShape();
      roof.noStroke();
      roof.fill(B.building_color);

      roof.emissive(0x60);
      for (int k =0; k<B.list_maison.get(j).maisonCord.size(); k++) {

        PVector A = B.list_maison.get(j).maisonCord.get(k);   
        walls.normal(0.0f, 0.0f, 1.0f);
        walls.vertex(A.x, A.y, A.z+3.);
        walls.normal(0.0f, 0.0f, 1.0f);
        walls.vertex(A.x, A.y, A.z+B.list_maison.get(j).top+3.);
        roof.normal(0.0f, 0.0f, 1.0f);
        roof.vertex(A.x, A.y, A.z+B.list_maison.get(j).top+3.);
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




  //Modélisez les bâtiments mentionnés dans le fichier geojson
  void creatBuild(info_building B) {




    for (int j =0; j< B.list_maison.size(); j++) {

      PShape walls;
      walls = createShape();
      walls.beginShape(QUAD_STRIP);

      walls.fill(B.building_color);

      walls.emissive(0x30);
      walls.noStroke();



      for (int k =0; k<B.list_maison.get(j).maisonCord.size(); k++) {
        PVector A = B.list_maison.get(j).maisonCord.get(k);

        walls.normal(0.0f, 0.0f, 1.0f);
        walls.vertex(A.x, A.y, A.z+3.);
        walls.normal(0.0f, 0.0f, 1.0f);
        walls.vertex(A.x, A.y, A.z+3.+B.list_maison.get(j).top);
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

      roof.fill(B.building_color);

      roof.emissive(0x60);



      for (int k =0; k<B.list_maison.get(j).maisonCord.size(); k++) {
        PVector A = B.list_maison.get(j).maisonCord.get(k);


        roof.normal(0.0f, 0.0f, 1.0f);
        roof.vertex(A.x, A.y, A.z+B.list_maison.get(j).top+3.);
      }
      roof.endShape();
      this.buildings.addChild(roof);
    }
  }

  //Contrôler l'affichage des bâtiments sur la carte
  void toggle() {
    this.buildings.setVisible(!this.buildings.isVisible());
  }
}
