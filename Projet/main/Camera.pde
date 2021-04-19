public class Camera {
  private float rayon;
  private float longitude;
  private float colatitude;
  private float x;
  private float y;
  private float z;
  private final float min_rayon = width*0.5;
  private final float max_rayon = width*3.0*2;
  private final float min_longitude = -3*PI/2;
  private final float max_longitude = PI/2;
  private final double min_colatitude = 0.001;
  private final float max_colatitude = PI/2;
  private boolean lightning;

  Camera(float r, float l, float c) {
    this.rayon = r;
    this.longitude = l;
    this.colatitude = c;
    this.x=r*sin(c)*cos(l);
    this.y=r*sin(c)*sin(l);
    this.z=r*cos(c);
    this.lightning = false;
  }

  public void update() {
     camera(this.x, -this.y, this.z, 0, 0, 0, 0, 0, -1);
    // Sunny vertical lightning 
    ambientLight(0xAA, 0xAA, 0xAA); 
    if (lightning)
    directionalLight(0xA0, 0xA0, 0x60, 0, 0, -1);
    lightFalloff(0.0f, 0.0f, 1.0f);
    lightSpecular(0.0f, 0.0f, 0.0f);
    
  }

  public  void adjustRadius(float offset) {
    float res = this.rayon + offset;
    if (res < min_rayon) {
      this.rayon = min_rayon;
    } else if (res > max_rayon) {
      this.rayon = max_rayon;
    } else {
      this.rayon = res;
    }
    this.x=this.rayon*sin(this.colatitude)*cos(this.longitude);
    this.y=this.rayon*sin(this.colatitude)*sin(this.longitude);
    this.z=this.rayon*cos(this.colatitude);
  }

  public void adjustLongitude(float delta) {
    float res = this.longitude + delta;
    if (res < this.min_longitude) {
      this.longitude = this.min_longitude;
    } else if (res > this.max_longitude) {
      this.longitude = this.max_longitude;
    } else {
      this.longitude = res;
    }
    this.x=this.rayon*sin(this.colatitude)*cos(this.longitude);
    this.y=this.rayon*sin(this.colatitude)*sin(this.longitude);
    this.z=this.rayon*cos(this.colatitude);
  }

  public void adjustColatitude(float delat) {
    float res = this.colatitude + delat;

    if ((double)res < this.min_colatitude) {
      this.colatitude = (float)this.min_colatitude;
    } else if (res > this.max_colatitude) {
      this.colatitude = this.max_colatitude;
    } else {
      this.colatitude = res;
    }

    this.x=this.rayon*sin(this.colatitude)*cos(this.longitude);
    this.y=this.rayon*sin(this.colatitude)*sin(this.longitude);
    this.z=this.rayon*cos(this.colatitude);
  }

  public int getRaduis() {

    return (int)this.rayon;
  }

  public int getLongitude() {

    return (int)(180*this.longitude/PI);
  }

  public int getColatitude() {

    return (int)(180*this.colatitude/PI);
  }

  public void toggle() {
    this.lightning = !this.lightning;
  }
}
