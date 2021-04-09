public class Hud {

  private PMatrix3D hud;
  Hud() {
    // Should be constructed just after P3D size() or fullScreen()
    this.hud = g.getMatrix((PMatrix3D) null);
  }
  private void begin() {
    g.noLights();
    g.pushMatrix();
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    g.resetMatrix();
    g.applyMatrix(this.hud);
  }
  private void end() {
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    g.popMatrix();
  }
  private void displayFPS() {
    // Bottom left area
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, height-30, 60, 20, 5, 5, 5, 5); // Value
    fill(0xF0);
    textMode(SHAPE);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(String.valueOf((int)frameRate) + " fps", 40, height-20);
  }
  private void displayCamera(Camera camera) {
    // Bottom left area
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, 10, 200, 110, 5, 5, 5, 5); // Value
    fill(0xF0);
    textMode(SHAPE);
    textSize(20);
    textAlign(CENTER, TOP);
    text("Camera",100,10);
    textSize(16);
    textAlign(LEFT, CENTER);
    text("Longitude     ", 15, 50);
    text("Latitude      ", 15, 75);
    text("Radius        ", 15, 100);
     textAlign(RIGHT, CENTER);
    text(String.valueOf(camera.getLongitude())+"°",205,50);
    text(String.valueOf(camera.getColatitude())+"°",205,75);
    text(String.valueOf(camera.getRaduis())+" m",205,100);
  }
  public void update(Camera c){
  this.begin();
  this.displayFPS();
  this.displayCamera(c);
  this.end();
  }
}
