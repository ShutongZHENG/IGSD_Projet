#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

  uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;
smooth in vec2 vertHeat;

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  gl_FragColor.r=vertHeat[0]/100;
  gl_FragColor.g=vertHeat[1]/100;
  gl_FragColor.b = 0;
}
