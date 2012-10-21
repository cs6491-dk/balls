class Ball {
	pt c;
	float r;
        int vtx = -1; //vtx

	Ball(pt arg_c, float arg_r) {
		c = arg_c;
		r = arg_r;
	}

	void show() {
		pushMatrix();
		translate(c.x,c.y,c.z);
		sphere(r);
		popMatrix();
	}

	void move(pt C) {
		c = P(C);
	}

	void move(float t, vec V) {
		c.add(t, V);
	}
        String toString(){
          return c.toString() + "vtx: " + vtx;
        }
}
