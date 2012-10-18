class Hit{
	float min_t;
	Ball min_A;
	int min_Adx;
}


class Sculpture {
	
	ArrayList<Ball> Balls;
	float r=20;


	Sculpture() {
		Balls = new ArrayList();

		Balls.add(new Ball(new pt(  0,         0, 0), r));
		Balls.add(new Ball(new pt(2*r,         0, 0), r));
		Balls.add(new Ball(new pt(  r, r*sqrt(3), 0), r));
	}

	void showBalls() {
		for (int i=0; i < Balls.size(); i++) {
			Balls.get(i).show();
		}
	}
  void deleteBall(pt E, pt F){
    Ball D = new Ball(P(E), r);
    vec V = V(E, F);

    Hit hit = findFirstHit(V, D);      
    println("delete " + hit.min_Adx);    
    Balls.remove(hit.min_Adx);

  }
  Hit findFirstHit(vec V, Ball D){
    Ball A;
    float t=1e10;
    Hit retval = new Hit();
    retval.min_t = 1e10;
					
		/* find the first ball hit */
		for (int i=0; i < Balls.size(); i++) {
			A = Balls.get(i);
			t = sphere_collision_time(A, V, D);
			if ((0 < t) && (t < retval.min_t)) {
				retval.min_t = t;
				retval.min_A = A;
				retval.min_Adx = i;
			}
		} 
						return retval;
  }      

	void addBall(pt E, pt F) {
		int Adx, min_Adx = -1;
								Ball A;
		Ball D = new Ball(P(E), r);
		vec V = V(E, F);

								Hit hit = findFirstHit(V, D);

		if (hit.min_A == null) {
			println("Bad shot");
			return;
		}
		D.move(hit.min_t, V);
		A = hit.min_A;
		Adx = hit.min_Adx;

		/* roll the new sphere into place */
		Ball B, C;
		float a, min_a = TWO_PI;
		pt sol, min_sol = null;
		ArrayList<pt> sols;
		for (int Bdx=0; Bdx < Balls.size(); Bdx++) {
			if (Bdx != Adx) {
				B = Balls.get(Bdx);
				if (abs(V(A.c, B.c).norm2()-sq(A.r+B.r)) < 1e-3) {
					for (int Cdx=Bdx+1; Cdx < Balls.size(); Cdx++) {
						if (Cdx != Adx) {
							C = Balls.get(Cdx);
							if ((abs(V(A.c, C.c).norm2() - sq(A.r+B.r)) < 1e-3) && (abs(V(B.c, C.c).norm2() - sq(B.r+C.r)) < 1e-3)) {
								sols = sphere_pack(A, B, C, D.r);
								for (int i=0; i < sols.size(); i++) {
									sol = sols.get(i);
									a = angle(V(A.c, sol), V(A.c, D.c));
									if (a < min_a) {
										min_a = a;
										min_sol = sol;
									}
								}
							}
						}
					}
				}
			}
		}
		if (min_sol == null) {
			println("No kisses");
			return;
		}
		D.move(min_sol);

		Balls.add(D);
	}
}
