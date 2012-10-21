class Hit{
	float min_t;
	Ball min_A;
	int min_Adx;
}

class Sculpture {
	
	ArrayList<Ball> Balls;
	float r=20;
        Ball B_sol, C_sol;

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
  pt rollBall(Ball A, Ball D, int Adx){

		/* roll the new sphere into place */
    float a, min_a = TWO_PI;
    pt sol, min_sol = null;
    Ball B,C;
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
                    B_sol = B;
                    C_sol = C;
                  }
                }
              }
            }
          }
        }
      }
    }
      return min_sol;    
  }

  void triangulate(pt E, pt F){
    // triangulate by creating a large ball and rolling it around the
    // cluster of spheres
    int Adx, min_Adx = -1;
    Ball A;
    pt min_sol;

    // add a large ball
    Ball roller = new Ball(P(E), r*2);
    vec V = V(E,F);

    // find the hit point 
    Hit hit = findFirstHit(V, roller);
    if (hit.min_A == null) {
      println("Bad shot");
      return;
    }

    // do the inital roll
    roller.move(hit.min_t, V);
    A = hit.min_A;
    Adx = hit.min_Adx;
    min_sol = rollBall(A, roller, Adx);
    if (min_sol == null) {
      println("No kisses");
      return;
    }
    roller.move(min_sol);
    Balls.add(roller);
    
    // determine 

    // create the first triangle A,B,C
    M.declareVectors();
    M.nv = 3;
    println(A);
/*    M.nv = 5;
    M.G[0].set(124.8207,1.777773,9.47427);
    M.G[1].set(193.10881,23.87775,10.50819);
    M.G[2].set(-57.601803,169.47241,-87.9093);
    M.G[3].set(-66.3798,120.499794,-105.5466);
    M.G[4].set(83.9652,39.7743,-5.67807);
    M.nt = 3;    */
    println(A.toString());
    M.G[0].set(A.c.x, A.c.y, A.c.z);
    M.G[1].set(B_sol.c.x, B_sol.c.y, B_sol.c.z);
    M.G[2].set(C_sol.c.x, C_sol.c.y, C_sol.c.z);
    M.nt = 1;
    M.nc = 3*M.nt;
    M.V[0] = 2;
    M.V[1] = 1;
    M.V[2] = 0;


    //M.loadMeshVTS("data/horse2.vts");
    M.resetMarkers().updateON();
    M.makeAllVisible();
    //M.resetMarkers().computeBox().updateON(); // makes a cube around C[8]
    
  }

	void addBall(pt E, pt F) {
		int Adx, min_Adx = -1;
    pt min_sol;
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

		min_sol = rollBall(A, D, Adx);
    if (min_sol == null) {
			println("No kisses");
			return;
		}
		D.move(min_sol);
		Balls.add(D);
	}
}
	
	
