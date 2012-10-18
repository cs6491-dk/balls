class Sculpture {
	ArrayList<Ball> B;
	float r=20;

	Sculpture() {
		B = new ArrayList();

		B.add(new Ball(new pt(  0,         0, 0), r));
		B.add(new Ball(new pt(2*r,         0, 0), r));
		B.add(new Ball(new pt(  r, r*sqrt(3), 0), r));
	}

	void showBalls() {
		for (int i=0; i < B.size(); i++) {
			B.get(i).show();
		}
	}

	void addBall(pt E, pt F) {
		Ball A = new Ball(P(E), r);
		vec V = V(E, F);

		float t, min_t = 1e10;
		for (int i=0; i < B.size(); i++) {
			t = sphere_collision_time(B.get(i), V, A);
			println("collision time = " + t);
			if ((0 < t) && (t < min_t)) {
				min_t = t;
			}
		}
		A.move(min_t, V);
		B.add(A);
	}
}
