public class WorkSpace {
  private PShape gizmo;
  private PShape grid;
  private PShape color_xy;
  WorkSpace(int nombre){
    // Grid
    
    this.grid = createShape(); 
    this.grid.beginShape(QUADS);
    this.grid.noFill(); 
    this.grid.stroke(0x77836C3D); 
    this.grid.strokeWeight(0.5f); 
     

   
    for( int i = 0-(nombre/100/2); i<nombre/100/2;i++){
     for( int j = 0-(nombre/250/2); j<nombre/250/2; j++){
        this.grid.vertex(i*250,j*250,0);
        this.grid.vertex((i+1)*250,j*250,0);
        this.grid.vertex((i+1)*250,(j+1)*250,0);
        this.grid.vertex(i*250,(j+1)*250,0);
     }
    
    }
    this.grid.endShape();
     
    this.color_xy = createShape();
    this.color_xy.beginShape(LINES);
    this.color_xy.noFill();
    this.color_xy.strokeWeight(0.5f); 
    
    this.color_xy.stroke(0xAAFF3F7F); 
    this.color_xy.vertex((-(nombre/100/2)*250),0,0);
    this.color_xy.vertex((nombre/100/2)*250,0,0);
    
    this.color_xy.stroke(0xAA3FFF7F); 
    this.color_xy.vertex(0,(0-nombre/250/2*250),0);
    this.color_xy.vertex(0,nombre/250/2*250,0);
    this.color_xy.endShape();
    
    
    // Gizmo
    this.gizmo = createShape(); 
    this.gizmo.beginShape(LINES); 
   // this.gizmo.noFill();
    this.gizmo.strokeWeight(3.0f);
    // Red X 
    this.gizmo.stroke(0xAAFF3F7F);
    this.gizmo.vertex(0,0,0);
    this.gizmo.vertex(250,0,0);
    // Green Y 
    this.gizmo.stroke(0xAA3FFF7F);
    this.gizmo.vertex(0,0,0);
    this.gizmo.vertex(0,250,0);
    // Blue Z 
    this.gizmo.stroke(0xAA3F7FFF);
    this.gizmo.vertex(0,0,0);
    this.gizmo.vertex(0,0,250);
    this.gizmo.endShape();
   
   this.gizmo.setVisible(true);
   this.grid.setVisible(true);
    
  }
  
  
  /**
   * Show Gizmo
   */
   void update(){
     if(this.gizmo.isVisible() && this.grid.isVisible()){   
       shape(this.gizmo);
       shape(this.color_xy);
       shape(this.grid);
   
 }else{
  background(0x40);
 }
 
   }
  
  
  /**
   * Toggle Grid & Gizmo visibility.
   */
  void toggle() { 
    this.gizmo.setVisible(!this.gizmo.isVisible());
    this.grid.setVisible(!this.grid.isVisible());
  }
  

}
