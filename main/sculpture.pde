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
  float r=20;
  Ball roller = null;

  Sculpture() {
    Balls = new ArrayList();
    Balls.add(new Ball(new pt(  0, 0, 0), r));
    Balls.add(new Ball(new pt(2*r, 0, 0), r));
    Balls.add(new Ball(new pt(  r, r*sqrt(3), 0), r));
    M.declareVectors();    
  }
  void showBallCenters() {
    for (int i=0; i < Balls.size(); i++) {
      Balls.get(i).showPoint();
    }
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
  RollSol rollBall(Ball A, float dr, pt dc, int Adx) {

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
                sols = sphere_pack(A, B, C, dr);
                for (int i=0; i < sols.size(); i++) {
                  sol = sols.get(i);
                  a = angle(V(A.c, sol), V(A.c, dc));
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
    float a, min_a = TWO_PI;
    pt min_sol = null;
    // loop over all triples...
    for (int i=0; i < Balls.size(); i++) {
      for (int j=i+1; j < Balls.size(); j++) {
        for (int k=j+1; k < Balls.size(); k++) {
          Ball bi = Balls.get(i);
          Ball bj = Balls.get(j);
          Ball bk = Balls.get(k);
          if (M.is_triangle(bi.vtx, bj.vtx, bk.vtx)){continue;}
          // Define a sphere which touches the centers of the 3 balls
          roller = new Ball(P(E), r*3);
          ArrayList<pt> sols = sphere_pack(Balls.get(i), Balls.get(j), Balls.get(k), roller.r-Balls.get(i).r);
          for (int idx=0; idx < sols.size(); idx++) {
            pt sol = sols.get(idx);
            a = angle(V(Balls.get(i).c, sol), V(Balls.get(i).c, roller.c));
            if (a < min_a) {
              min_a = a;
              min_sol = sol;
            }          
          // if this sphere does not intersect other spheres, add it. 
          Boolean res = false;
          for (int b=0; b < Balls.size(); b++){
            Ball test = Balls.get(b);
              if (d(min_sol, test.c) < (roller.r + test.r)){
                if (M.is_triangle(bi.vtx, bj.vtx, bk.vtx)){continue;}
                 addTriangle(Balls.get(i), Balls.get(j), Balls.get(k));
                 
                 println("add triangle " + i + "," + j + "," + k);
                 
              } 
            }              
          }                               
        }
      }
    }
    println("naive triangulation complete");
    }


  Boolean intersect_balls(int i, int j, int k) {
    // see if a triangle formed by balls i,j,k intersects any other balls
    // loop over all remaining balls and see if the triangle intersects
    for (int b=0; b < Balls.size(); b++) {
      // does this ball 
      Ball test = Balls.get(b);
      if ((b == i) | (b == j ) | (b == k)){
          continue;
      }
      if (intersect_triangle_sphere(test.c, test.r, Balls.get(i).c, Balls.get(j).c, Balls.get(k).c)) {return true;}
    }
    return false;
  }
  Boolean intersect_triangle_sphere(pt sc, float r, pt pa, pt pb, pt pc) {
    // does a triangle defined by a,b,c interest a sphere with center sc and radius r?
    // great reference here.. http://realtimecollisiondetection.net/blog/?p=103
    
    // For a simple test, we can look at a plane defined by the triangle and see if the sphere center 
    // sc lies at least r away from the normal.  if this is true than it definitely does not intersect.
    // There may be other cases where it also does not intersect, but maybe this is good enough to catch most
    // of them.  worst case we don't add a triangle when we should, but we will never add one when we shouldn't.  :-)
    
    pt ta = P(pa).sub(sc);
    pt tb = P(pb).sub(sc);
    pt tc = P(pc).sub(sc);
    // find a unit normal vector  by taking cross product of ab and ac and divide by magnitude
    vec N = N(ta, tb, tc);
    float sep = d(V(ta), N);
    return !(sep*sep > r*r);
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
    min_sol = rollBall(A, roller.r-A.r, roller.c, Adx);  // roll to points
    //min_sol = rollBall(A, roller.r, roller.c, Adx); // roll to sphere edges
    
    if (min_sol == null) {
      println("No kisses");
      return;
    }
    roller.move(min_sol.sol);

    // add a triangle A,B,C
    // A is already defined as the first ball we hit with D, grab B and C
    B = Balls.get(min_sol.Bdx);
    C = Balls.get(min_sol.Cdx);
    
    // Check to see if A,B,C is facing the roller, if not, switch A and B 
    // first, get a unit the triangle normal
    vec N = N(A.c, B.c, C.c);
    // dot with a vector from A to roller center;
    float dir = d(N, V(A.c, roller.c));
    // If it is positive, we're in good shame, if not, need to reverse
    if (dir > 0){
      addTriangle(A, B, C);
    }
    else{
      addTriangle(B, A, C);       
    }

  }
  void addTriangle(Ball A, Ball B, Ball C){
    /*println("A: " + A.toString());
    println("B: " + B.toString());
    println("C: " + C.toString());*/
    if (A.vtx == -1) {     
      //println("Setting A to vtx: " + M.nv);      
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
    //println("Setting nt " + M.nt + "-" + (M.nt+2));
    M.V[M.nt*3] = A.vtx;
    M.V[M.nt*3+1] = B.vtx;
    M.V[M.nt*3+2] = C.vtx;
    M.nt += 1;
    M.nc = 3*M.nt;
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

    min_sol = rollBall(A, D.r, D.c, Adx);
    if (min_sol.sol == null) {
      println("No kisses");
      return;
    }
    D.move(min_sol.sol);
    Balls.add(D);
  }
}


