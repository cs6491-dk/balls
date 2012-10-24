class Ball {
	pt c;
	float r;
        int Gdx; // ties to an entry in G

	Ball(pt arg_c, float arg_r) {
		c = arg_c;
		r = arg_r;
                Gdx = -1;
	}

	void showPoint(){
		pushMatrix();
		translate(c.x, c.y, c.z);
		sphere(1);
		popMatrix();
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

	Ball copy() {
		return new Ball(P(c), r);
	}
}


