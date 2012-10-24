class Hit {
  float min_t;
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
    if (roller != null) {
      roller.show();
    }
  }
  void deleteBall(pt E, pt F) {
    Ball D = new Ball(P(E), r);
    vec V = V(E, F);

    Hit hit = findFirstHit(V, D);      
    //println("delete " + hit.min_Adx);    
    Balls.remove(hit.min_Adx);
  }

  Hit findFirstHit(vec V, Ball D) {
    Ball A;
    float t=1e10;
    Hit retval = new Hit();
    retval.min_t = 1e10;
    retval.min_Adx = -1;

    /* find the first ball hit */
    for (int i=0; i < Balls.size(); i++) {
      A = Balls.get(i);
      t = sphere_collision_time(A, V, D);
      if ((0 < t) && (t < retval.min_t)) {
        retval.min_t = t;
        retval.min_Adx = i;
      }
    } 
    return retval;
  }

  RollSol rollBall(int Adx, float dr, pt dc, boolean require_kissed, boolean roll_on_points) {
    Ball A = Balls.get(Adx);

    /* roll the new sphere into place */
    float a, min_a = TWO_PI;
    pt sol = null;
    RollSol min_sol = new RollSol();
    Ball B, C;
    ArrayList<pt> sols;
    for (int Bdx=0; Bdx < Balls.size(); Bdx++) {
      if (Bdx != Adx) {
        B = Balls.get(Bdx);

        if (require_kissed) {
          if (abs(V(A.c, B.c).norm2()-sq(A.r+B.r)) > 1e-3) continue;
        }
        else if (d(A.c, B.c) > 2*dr) continue;

        for (int Cdx=Bdx+1; Cdx < Balls.size(); Cdx++) {
          if (Cdx != Adx) {
            C = Balls.get(Cdx);

            if (require_kissed) {
              if ((abs(V(A.c, C.c).norm2() - sq(A.r+C.r)) > 1e-3) || (abs(V(B.c, C.c).norm2() - sq(B.r+C.r)) > 1e-3)) continue;
            }
            else if ((d(A.c, C.c) > 2*dr) || (d(B.c, C.c) > 2*dr)) continue;

            sols = sphere_pack(A, B, C, dr, roll_on_points);
            for (int i=0; i < sols.size(); i++) {
              sol = sols.get(i);
              a = angle(V(A.c, sol), V(A.c, dc));

              boolean collision = false;
              Ball test;
              for (int jdx = 0; jdx < Balls.size(); jdx++) {
                if ((jdx == Adx) || (jdx == Bdx) || (jdx == Cdx)) continue;
                test = Balls.get(jdx);
                float threshold = dr;
                if (!roll_on_points) threshold += test.r;
                if (abs(d(Balls.get(jdx).c, sol) - threshold) < 1e-3) {
                  collision = true;
                  break;
                }
              }

              if ((a < min_a) && !collision) {
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
    return min_sol;
  }

  int rollBall2(int Adx, int Bdx, Ball D) {
	Ball A = Balls.get(Adx),
	     B = Balls.get(Bdx);
    float min_th = TWO_PI;
    int min_th_Cdx = -1;
    pt min_th_sol = null;
    Ball C;
    for (int Cdx=0; Cdx < Balls.size(); Cdx++) {
      if ((Cdx == Adx) || (Cdx == Bdx)) { continue;}

      C = Balls.get(Cdx);
      // Make sure it won't roll through
      if (d(A.c, C.c) > 2*D.r) {continue;}
      if (d(B.c, C.c) > 2*D.r) {continue;}
      // K is a point on AB which the "end" of the projection of AD onto AB.  
      // 1. compute K (A + (dot(AD,U(A,B)))U(A,B) where UAB=AB/||AB||
      vec AD = V(A.c, D.c);
      vec UAB = U(A.c,B.c);
      pt K = P(A.c, d(AD,UAB), UAB);

      ArrayList<pt> sols = sphere_pack(A, B, C, D.r, true); //roll_on_points

      for (int sdx=0; sdx < sols.size(); sdx++) {
        pt DP = sols.get(sdx);
        float th = acos(d(V(K,D.c), V(K, DP))/(d(K, D.c)*d(K,DP)));
        if (d(N(V(K,D.c), V(K, DP)), V(K, A.c)) < 0){
          th = TWO_PI-th;
        }
        if (abs(th) < 1e-3){
          continue;
        }

        boolean collision = false;
        Ball test;
        for (int jdx = 0; jdx < Balls.size(); jdx++) {
          if ((jdx == Adx) || (jdx == Bdx) || (jdx == Cdx)) continue;
          test = Balls.get(jdx);
          float threshold = D.r;
          if (abs(d(Balls.get(jdx).c, DP) - threshold) < 1e-3) {
            collision = true;
            break;
          }
        }

        if ((th < min_th) && !collision){
          min_th = th;
          min_th_sol = DP;
          min_th_Cdx = Cdx;
        }
      }
    }
    //println("theta " + min_th);
    //println("D.c = (" + D.c.x + "," + D.c.y + "," + D.c.z + ")");
    if (min_th_sol == null) {
      return -1;
    }
    else {
      D.move(min_th_sol);
      //println("D.c = (" + D.c.x + "," + D.c.y + "," + D.c.z + ")");
      return min_th_Cdx;
    }
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

  void roll_skin(pt E, pt F) {
    M = new Mesh();
    for (int idx=0; idx < Balls.size(); idx++) {
       Balls.get(idx).Gdx = -1;
    }
    // triangulate by creating a large ball and rolling it around the
    // cluster of spheres
    int Adx, Bdx, Cdx, min_Adx = -1;
    Ball A, B, C;
    RollSol min_sol;

    // add a large ball
    Ball D = new Ball(P(E), r*1.5);
    //Balls.add(D);

    // define the vector we are looking through
    vec V = V(E, F);

    // find the hit point 
    Hit hit = findFirstHit(V, D);
    if (hit.min_Adx == -1) {
      println("Bad shot");
      return;
    }

    // do the inital roll
    D.move(hit.min_t, V);
    Adx = hit.min_Adx;
    A = Balls.get(Adx);
    min_sol = rollBall(Adx, D.r, D.c, false, true);  // don't require kissed, roll on points
    //min_sol = rollBall(A, D.r, D.c, Adx); // roll to sphere edges
    
    if (min_sol == null) {
      println("No kisses");
      return;
    }
    // actually move it there
    D.move(min_sol.sol);

    // add a triangle A,B,C
    // A is already defined as the first ball we hit with D, grab B and C
    Bdx = min_sol.Bdx;
    Cdx = min_sol.Cdx;
    B = Balls.get(Bdx);
    C = Balls.get(Cdx);

    // add a triangle guaranteed to face the roller
    addFacingTriangle(A, B, C, D);
	if (d(N(A.c,B.c,C.c), V(A.c, D.c)) < 0) {
      // Counter-clockwise triangle
      println("CCW");
      recursive_roll(A, B, Adx, Bdx, D.copy());
      recursive_roll(B, C, Bdx, Cdx, D.copy());
      recursive_roll(C, A, Cdx, Adx, D.copy());
    }
    else {
      // Clockwise triangle
      println("CW");
      recursive_roll(B, A, Bdx, Adx, D.copy());
      recursive_roll(C, B, Cdx, Bdx, D.copy());
      recursive_roll(A, C, Adx, Cdx, D.copy());
    }

    M.resetMarkers().updateON();
    M.makeAllVisible();    
  }
  
  void recursive_roll(Ball A, Ball B, int Adx, int Bdx, Ball D){
    boolean added;
    Ball C;
    int Cdx = rollBall2(Adx, Bdx, D);
    if (Cdx != -1) {
      C = Balls.get(Cdx);
      added = addFacingTriangle(A, B, C, D);
      if (!added) {return;}
      recursive_roll(A,C, Adx, Cdx, D.copy());
      recursive_roll(C,B, Cdx, Bdx, D.copy());
    }
    else
    {
       return; 
    }    
  }
  
  void manual_skin(pt E, pt F) {
    // triangulate by creating a large ball and rolling it around the
    // cluster of spheres
    int Adx, min_Adx = -1;
    Ball A, B, C;
    RollSol min_sol;

    // add a large ball
    if (roller == null) {
      println("adding roller");
      roller = new Ball(P(E), r*1.5);
      //Balls.add(roller);
    }
    else {
      roller.move(P(E));
    }
    vec V = V(E, F);

    // find the hit point 
    Hit hit = findFirstHit(V, roller);
    if (hit.min_Adx == -1) {
      println("Bad shot");
      return;
    }

    // do the inital roll
    roller.move(hit.min_t, V);
    Adx = hit.min_Adx;
    A = Balls.get(Adx);
    min_sol = rollBall(Adx, roller.r, roller.c, false, true);  // don't require kissed, roll to points
    //min_sol = rollBall(Adx, roller.r, roller.c); // roll to sphere edges

    if (min_sol == null) {
      println("No kisses");
      return;
    }
    roller.move(min_sol.sol);

    // add a triangle A,B,C
    // A is already defined as the first ball we hit with D, grab B and C
    A = Balls.get(min_sol.Adx);
    B = Balls.get(min_sol.Bdx);
    C = Balls.get(min_sol.Cdx);
    
    // add a triangle guaranteed to face the roller
    addFacingTriangle(A, B, C, roller);        
    
    // add code here to traverse the rest of the point set, adding triangles as we go. 
    // the idea is to rotate the sphere around one of the triangle edges until it hits another point
    M.resetMarkers().updateON();
    M.makeAllVisible();  

  }

  boolean addFacingTriangle(Ball A, Ball B, Ball C, Ball ref){
    // add a triangle which faces a reference ball  
    // Check to see if A,B,C is facing the roller, if not, switch A and B 
    // first, get a unit the triangle normal
    vec N = N(A.c, B.c, C.c);
    // dot with a vector from A to roller center;
    float dir = d(N, V(A.c, ref.c));
    // If it is positive, we're in good shape, if not,  switch A/B
    
    
    if (dir > 0){
      println("testing: (" + A.Gdx + "," + B.Gdx + "," + C.Gdx + ")");
      if (M.is_triangle(A.Gdx, B.Gdx, C.Gdx)){
        println("already have triangle");
        return false;
      }    
      else {println("no triangle found: (" + A.Gdx + "," + B.Gdx + "," + C.Gdx + ")");}
      addTriangle(A, B, C);
      println("added: (" + A.Gdx + "," + B.Gdx + "," + C.Gdx + ")");
      println("nt: " + M.nt);
    }
    else{
      println("testing: (" + B.Gdx + "," + A.Gdx + "," + C.Gdx + ")");
      if (M.is_triangle(B.Gdx, A.Gdx, C.Gdx)){
        println("already have triangle");
        return false;
      }        
      addTriangle(B, A, C);       
      println("added: (" + B.Gdx + "," + A.Gdx + "," + C.Gdx + ")");
       println("nt: " + M.nt);
    }
    return true;
  }

  void addTriangle(Ball A, Ball B, Ball C){

    if (A.Gdx == -1){ A.Gdx = M.nv; M.G[M.nv++].set(A.c.x, A.c.y, A.c.z); }
    if (B.Gdx == -1){ B.Gdx = M.nv; M.G[M.nv++].set(B.c.x, B.c.y, B.c.z); }
    if (C.Gdx == -1){ C.Gdx = M.nv; M.G[M.nv++].set(C.c.x, C.c.y, C.c.z); }
    M.V[M.nt*3] = A.Gdx;
    M.V[M.nt*3+1] = B.Gdx;
    M.V[M.nt*3+2] = C.Gdx;
    M.nt += 1;    
    M.nc = 3*M.nt;
  }

  void addBall(pt E, pt F) {
    int Adx, min_Adx = -1;
    RollSol min_sol;
    Ball A;
    Ball D = new Ball(P(E), r);
    vec V = V(E, F);

    Hit hit = findFirstHit(V, D);

    if (hit.min_Adx == -1) {
      println("Bad shot");
      return;
    }
    D.move(hit.min_t, V);
    Adx = hit.min_Adx;

    min_sol = rollBall(Adx, D.r, D.c, true, false); //require kissed, don't roll on points
    if (min_sol.sol == null) {
      println("No kisses");
      return;
    }
    D.move(min_sol.sol);
    Balls.add(D);

    A = Balls.get(0);
    Ball B = Balls.get(1), C = Balls.get(2);
	//println(d(N(A.c,B.c,C.c), V(A.c, D.c)));

    roll_skin(E, F);
  }
}
