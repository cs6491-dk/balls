class Hit {
  float min_t;
  Ball min_A;
  int min_Adx;
}

class RollSol { 
  // roll solution is indices of balls a,b,c and the point for d..
  int Adx;
  int Bdx;
  int Cdx;  
  pt sol;
}

class Sculpture {

  ArrayList<Ball> Balls;
  float r=10;
  Ball roller = null;

  Sculpture() {
    Balls = new ArrayList();
    Balls.add(new Ball(new pt(  0, 0, 0), r));
    Balls.add(new Ball(new pt(2*r, 0, 0), r));
    Balls.add(new Ball(new pt(  r, r*sqrt(3), 0), r));
    M.declareVectors();    
  }

  void showBalls() {
    for (int i=0; i < Balls.size(); i++) {
      Balls.get(i).show();
    }
  }
  void deleteBall(pt E, pt F) {
    Ball D = new Ball(P(E), r);
    vec V = V(E, F);

    Hit hit = findFirstHit(V, D);      
    println("delete " + hit.min_Adx);    
    Balls.remove(hit.min_Adx);
  }
  Hit findFirstHit(vec V, Ball D) {
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
  RollSol rollBall(Ball A, Ball D, int Adx) {

    /* roll the new sphere into place */
    float a, min_a = TWO_PI;
    pt sol = null;
    RollSol min_sol = new RollSol();
    Ball B, C;
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
                    min_sol.sol = sol;
                    min_sol.Adx = Adx;
                    min_sol.Bdx = Bdx;
                    min_sol.Cdx = Cdx;
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

  void naive_triangulate(pt E, pt F) {

    // loop over all triples...
    for (int i=0; i < Balls.size(); i++) {
      for (int j=0; j < Balls.size(); j++) {
        for (int k=0; k < Balls.size(); j++) {
          // define a triangle between balls i,j,k  
          // if this triangle does not intersect any balls other than i,j,k, then add it.
          if (!intersect_balls(i, j, k)) {
            // add triangle
          }
        }
      }
    }
  }


  Boolean intersect_balls(int i, int j, int k) {
    // see if a triangle formed by balls i,j,k intersects any other balls
    Boolean does_intersect = true;

    // loop over all remaining balls and see if the triangle intersects
    for (int b=0; b < Balls.size(); b++) {
      // does this ball 
      Ball test = Balls.get(b);
      //      if (intersect_triangle_sphere(test.pt.x, test.pt.y, test.pt.z,
    }
    return does_intersect;
  }
  Boolean intersect_triangle_sphere(float sx, float sy, float sz, float tx, float ty, float tz) {
    // deter

    return false;
  }
  void roll_triangulate(pt E, pt F) {
    // triangulate by creating a large ball and rolling it around the
    // cluster of spheres
    int Adx, min_Adx = -1;
    Ball A, B, C;
    RollSol min_sol;

    // add a large ball
    if (roller == null) {
      println("adding roller");
      roller = new Ball(P(E), r*1.5);
      Balls.add(roller);
    }
    else {
      roller.move(P(E));
    }
    vec V = V(E, F);

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
    roller.move(min_sol.sol);

    // add a triangle A,B,C
    // A is already defined as the first ball we hit with D, grab B and C
    B = Balls.get(min_sol.Bdx);
    C = Balls.get(min_sol.Cdx);
    
   
    println("A: " + A.toString());
    println("B: " + B.toString());
    println("C: " + C.toString());
    if (A.vtx == -1) {     
      println("Setting A to vtx: " + M.nv);      
      A.vtx = M.nv;
      M.G[M.nv++].set(A.c.x, A.c.y, A.c.z);
    }
    if (B.vtx == -1) {
      B.vtx = M.nv;
      M.G[M.nv++].set(B.c.x, B.c.y, B.c.z);
    }
    if (C.vtx == -1) {
      C.vtx = M.nv;
      M.G[M.nv++].set(C.c.x, C.c.y, C.c.z);
    }    
    
    println("Setting nt " + M.nt + "-" + (M.nt+2));
    M.V[M.nt*3] = A.vtx;
    M.V[M.nt*3+1] = B.vtx;
    M.V[M.nt*3+2] = C.vtx;
    M.nt += 1;
    M.nc = 3*M.nt;
    println("G:");
    for (int i=0; i < 3; i++) { 
      println(M.G[i]);
    }
    println("V");
    for (int i=0; i < 6; i++) { 
      println(M.V[i]);
    }    

    M.resetMarkers().updateON();
    M.makeAllVisible();
  }

  void addBall(pt E, pt F) {
    int Adx, min_Adx = -1;
    RollSol min_sol;
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
    if (min_sol.sol == null) {
      println("No kisses");
      return;
    }
    D.move(min_sol.sol);
    Balls.add(D);
  }
}


