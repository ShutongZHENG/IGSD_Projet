#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform float u_time;


smooth in vec4 vertColor;
smooth in vec4 vertTexCoord;
smooth in vec2 vertHeat;

void main() {
  
  
  
  
  
  
 
  bool c = false;
  bool c1 = false;
  float o = 100;
  if(vertHeat[0]<o){
    gl_FragColor.g = 1.0;
    //gl_FragColor.g  = 76/255* abs(sin(u_time));
    //gl_FragColor.b  = 60/255* abs(sin(u_time));
    gl_FragColor.a =  (o - vertHeat[0])/o;
    //gl_FragColor.g = gl_FragColor.g * abs(sin(u_time));
    c = true;
  }
  if( vertHeat[1]<o ){
    gl_FragColor.r = 1.0;
    //if(gl_FragColor.r >= 138/255){
    //  gl_FragColor.r = 46/255;
    //}
    //gl_FragColor.b = 113/255; 
    //if( !c ){
    //  gl_FragColor.a = 0;
    //}
    gl_FragColor.r = gl_FragColor.r * abs(sin(u_time));
    gl_FragColor.a =  (o - vertHeat[1])/o ;
    ////gl_FragColor.a = gl_FragColor.a * abs(sin(u_time));;
    c1 = true;
  }
    
    
  //}
  if( !c && !c1)
  {
    gl_FragColor.a =0;
  
  }
  //gl_FragColor.a = gl_FragColor.a * abs(sin(u_time));;
  
  //if( vertHeat[0]>200 )
  //{
  //gl_FragColor.a =1;
  
  //}
  
  
  
  
} 
