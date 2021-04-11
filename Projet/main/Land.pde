public class Land {
  private PShape shadow;
  private PShape wireFrame;
  private PShape satellite;
  private Map3D map;

  /**
   * Returns a Land object.
   * Prepares land shadow, wireframe and textured shape
   * @param map Land associated elevation Map3D object
   * @return Land object
   */
  Land(Map3D map, String fileName) {
    final float tileSize = 25.0f;
    this.map = map;
    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Land texture file " + fileName + " not found.");
      exitActual();
    }
    PImage uvmap = loadImage(fileName);


    float w = (float)Map3D.width;
    float h = (float)Map3D.height;
    // Shadow shape
    this.shadow = createShape();
    this.shadow.beginShape(QUADS);
    this.shadow.fill(0x992F2F2F);
    this.shadow.noStroke();
     

    Map3D.ObjectPoint onw = this.map.new ObjectPoint(-w/2.0f, -h/2.0f);
    Map3D.ObjectPoint osw = this.map.new ObjectPoint(-w/2.0f, +h/2.0f);
    Map3D.ObjectPoint ose = this.map.new ObjectPoint(+w/2.0f, +h/2.0f);
    Map3D.ObjectPoint one = this.map.new ObjectPoint(+w/2.0f, -h/2.0f);
    this.shadow.vertex(Math.round(onw.x * 1e2)/1e2, Math.round(onw.y * 1e2)/1e2, -1);
    this.shadow.vertex(Math.round(osw.x * 1e2)/1e2, Math.round(osw.y * 1e2)/1e2, -1);
    this.shadow.vertex(Math.round(ose.x * 1e2)/1e2, Math.round(ose.y * 1e2)/1e2, -1);
    this.shadow.vertex(Math.round(one.x * 1e2)/1e2, Math.round(one.y * 1e2)/1e2, -1);
    this.shadow.endShape();
    // Wireframe shape
    this.wireFrame = createShape();
    this.wireFrame.beginShape(QUADS);
    this.wireFrame.noFill();
    this.wireFrame.stroke(#888888);
    this.wireFrame.strokeWeight(0.5f);
     

    for ( float i = -w/2.0f; i< +w/2.0f; i+=tileSize) {
      for ( float j = -h/2.0f; j< +h/2.0f; j+=tileSize) {



        Map3D.ObjectPoint pone = this.map.new ObjectPoint(i, j);
        Map3D.ObjectPoint ptwo = this.map.new ObjectPoint(i+tileSize, j);
        Map3D.ObjectPoint pthree = this.map.new ObjectPoint(i+tileSize, j+tileSize);
        Map3D.ObjectPoint pfour = this.map.new ObjectPoint(i, j+tileSize);

        this.wireFrame.vertex(pone.x, pone.y, pone.z);
        this.wireFrame.vertex(ptwo.x, ptwo.y, ptwo.z);
        this.wireFrame.vertex(pthree.x, pthree.y, pthree.z);
        this.wireFrame.vertex(pfour.x, pfour.y, pfour.z);
      }
    }



    this.wireFrame.endShape();

    this.satellite = createShape();
    this.satellite.beginShape(QUADS);
    this.satellite.texture(uvmap);
    this.satellite.noStroke();
    this.satellite.emissive(0xD0);
     
    for ( float i = -w/2.0f; i< +w/2.0f; i+=tileSize) {
      for ( float j = -h/2.0f; j< +h/2.0f; j+=tileSize) {



        Map3D.ObjectPoint op = this.map.new ObjectPoint(i, j);
        PVector n = op.toNormal();
        this.satellite.normal(n.x, n.y, n.z);
        this.satellite.vertex(op.x, op.y, op.z, (i+w/2.0f)*uvmap.width/w, (j+h/2.0f)*uvmap.height/h);
        
        Map3D.ObjectPoint op2 = this.map.new ObjectPoint(i+tileSize, j);
        PVector n2 = op2.toNormal();
        this.satellite.normal(n2.x, n2.y, n2.z);
        this.satellite.vertex(op2.x, op2.y, op2.z, ((i+w/2.0f)+tileSize)*uvmap.width/w, (j+h/2.0f)*uvmap.height/h);
        
         Map3D.ObjectPoint op3 = this.map.new ObjectPoint(i+tileSize, j+tileSize);
         PVector n3 = op3.toNormal();
        this.satellite.normal(n3.x, n3.y, n3.z);
        this.satellite.vertex(op3.x, op3.y, op3.z, ((i+w/2.0f)+tileSize)*uvmap.width/w, ((j+h/2.0f)+tileSize)*uvmap.height/h);
        
         Map3D.ObjectPoint op4 = this.map.new ObjectPoint(i, j+tileSize);
         PVector n4 = op4.toNormal();
        this.satellite.normal(n4.x, n4.y, n4.z);
        this.satellite.vertex(op4.x, op4.y, op4.z, (i+w/2.0f)*uvmap.width/w, ((j+h/2.0f)+tileSize)*uvmap.height/h);

      
    
  }
    }


    this.satellite.endShape();

    // Shapes initial visibility
    this.shadow.setVisible(true);
    this.wireFrame.setVisible(false);
    this.satellite.setVisible(true);
  }

  void update() {
    if (this.shadow.isVisible()) {
      shape(this.shadow);
    }
    if (this.wireFrame.isVisible()) {
      shape(this.wireFrame);
    }
    if (this.satellite.isVisible()) {
      shape(this.satellite);
    }
  }

  void toggle() {
    this.wireFrame.setVisible(!this.wireFrame.isVisible());
    this.satellite.setVisible(!this.satellite.isVisible());
  }
}
