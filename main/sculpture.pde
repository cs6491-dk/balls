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
    // A 

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

  void naive_skin(pt E, pt F) {
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
    println("naive skin complete");
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
    // triangulate by creating a large ball and rolling it around the
    // cluster of spheres
    int Adx, min_Adx = -1;
    Ball A, B, C;
    RollSol min_sol;
    float min_th=1e10;
    RollSol min_th_sol = null;

    // add a large ball
    roller = new Ball(P(E), r*1.2);
    //Balls.add(roller);

    // define the vector we are looking through
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
    // actually move it there
    roller.move(min_sol.sol);

    // add a triangle A,B,C
    // A is already defined as the first ball we hit with D, grab B and C
    B = Balls.get(min_sol.Bdx);
    C = Balls.get(min_sol.Cdx);
    
    // add a triangle guaranteed to face the roller
    addFacingTriangle(A, B, C, roller);        
    
    // add code here to traverse the rest of the point set, adding triangles as we go. 
    // the idea is to rotate the sphere around one of the triangle edges until it hits another point.
    // but we won't actually compute that rotation...
    
    // pick a ball closest to the existing triangle, which is not in the vertex list
    for (int f=0; f < 40; f++){
      println("trying to add more triangles");
      for (int b=0; b < Balls.size(); b++){
    
          Ball test = Balls.get(b); //E
          // Check to see if ball is spoken for... 
          // Better to check if the triangle exists as we can't complete the surface this way
          //if (test.has_vertex()) {continue;} 
          if (test == roller) { continue;}
          
          // Make sure it won't roll through
          if (d(A.c, test.c) < 2*roller.r) {continue;}
          if (d(B.c, test.c) < 2*roller.r) {continue;}
          println("got here1");
          // K is a point on AB which the "end" of the projection of AD onto AB.  
          // 1. compute K (A + (dot(AD,U(A,B)))U(A,B) where UAB=AB/||AB||
          vec AD = V(A.c, roller.c);
          vec UAB = U(A.c,B.c);
          pt K = P(A.c, d(AD,UAB), UAB); 
          println("got here1.5");
          min_sol = rollBall(test, roller.r, roller.c, b);
          println("got here 1.6");
          
          println("got here 1.7");
          // 2. Compute D' using modified roll.. prevent fall-through
          // by checking ||AE|| <=2r and ||BE|| <= 2r where E is new vertex         
          float th = acos(d(V(K,roller.c), V(K, min_sol.sol))/(d(K, roller.c)*d(K,min_sol.sol)));
          if (d(N(V(K,roller.c), V(K, min_sol.sol)), V(K, A.c)) < 0){
            th = 2*PI-th;
          }
          roller.move(min_th_sol.sol);
          println("got here2");
          if (th == 0){
            continue;
          }
          if (th < min_th){
            min_th = th;
            min_th_sol = min_sol;            
          }
          println("theta " + th);
        
      }
      if (min_th_sol == null)
      {}
      else
      {
        A = Balls.get(min_sol.Adx);
        B = Balls.get(min_sol.Bdx);
        C = Balls.get(min_sol.Cdx);
        addFacingTriangle(A, B, C, roller);          
      }
      
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
    
    // add a triangle guaranteed to face the roller
    addFacingTriangle(A, B, C, roller);        
    
    // add code here to traverse the rest of the point set, adding triangles as we go. 
    // the idea is to rotate the sphere around one of the triangle edges until it hits another point

  }  
  void addFacingTriangle(Ball A, Ball B, Ball C, Ball ref){
    // add a triangle which faces a reference ball  
    // Check to see if A,B,C is facing the roller, if not, switch A and B 
    // first, get a unit the triangle normal
    if (M.is_triangle(A.vtx, B.vtx, C.vtx)){
      println("already have triangle");
      return;
    }    
    vec N = N(A.c, B.c, C.c);
    // dot with a vector from A to roller center;
    float dir = d(N, V(A.c, ref.c));
    // If it is positive, we're in good shape, if not,  switch A/B

    if (dir > 0){
      addTriangle(A, B, C);
    }
    else{
      addTriangle(B, A, C);       
    }    
  }
  void addTriangle(Ball A, Ball B, Ball C){
    if (A.vtx == -1) {           
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


