float sphere_collision_time(Ball A, vec V, Ball B) {
	/* A collides with B+V*t */

	vec B_prime = V(A.c, B.c);

	float a = V.norm2(),
	      b = 2*d(V, B_prime),
	      c = B_prime.norm2() - sq(A.r+B.r);

	float disc = sq(b) - 4*a*c;
	if (disc < 0) {
		return Float.NaN;
	}
	else {
		return (-b-sqrt(disc))/2/a;
	}
}

pt rot_angle_axis(pt P, float angle, vec axis) {
	vec V = V(P);
	float cos_a = cos(angle);
	pt ret = P(cos_a,P);
	ret.add(N(axis,V).mul(sin(angle)));
	ret.add(V(d(axis,V)*(1-cos_a),axis));
	return ret;
}

ArrayList<pt> sphere_pack(Ball A, Ball B, Ball C, float Dr) {
	/*vec AB = V(A.c, B.c),
	    AC = V(A.c, C.c),
	    BC = V(B.c, C.c);

	vec M_AB = P(A.c, U(AB).mul((AB.norm2() + sq(A.r+D.r) - sq(B.r+D.r))/2/AB.norm())),
	    M_AC = P(A.c, U(BC).mul((AB.norm2() + sq(A.r+D.r) - sq(C.r+D.r))/2/AB.norm()));

	vec V_AB = B(AB, AC),
	    V_AC = B(AC, AB);

	find intersection D_proj */

	/* We solve for the solution of the axis-aligned tetrahedron,
	 * then apply that solution to the real tetrahedron.
	 * This may well be faster, and avoids more complicated algorithms,
	 * such as intersection of 3D lines. */
	/* Alignment is as follows: A is at the origin, B is on the positive x axis,
	 * C is in the z=0 plane */

	/* Solve for projection of 4th vertex onto plane of first 3 */
	float len_AB = A.r + B.r,
	      len_AC = A.r + C.r,
	      len_BC = B.r + C.r,
	      len_AD = A.r + Dr;
	float cos_CAB = (sq(len_AB)+sq(len_AC)-sq(len_BC))/2/len_AB/len_AC;
	float M_AB_x = cos_CAB*len_AC;

	float len_M_AC = cos_CAB*len_AB;
	float M_AC_x = cos_CAB*len_M_AC;
	float M_AC_y = sqrt(sq(len_M_AC)-sq(M_AC_x));
	float V_AC_x = -M_AC_y,
	      V_AC_y =  M_AC_x;

	float s = V_AC_y*(M_AB_x - M_AC_x)/V_AC_x + M_AC_y;

	float len_M = sqrt(sq(M_AB_x) + sq(s));
	float height = sqrt(sq(len_AD) - sq(len_M));
	float MAB = atan2(s, M_AB_x);

	/* Apply to actual sphere locations */
	vec norm_axis = N(U(A.c, B.c), U(A.c, C.c)).normalize();
	pt M = A(A.c, rot_angle_axis(P(0,0,0).add(len_M, V(A.c,B.c).normalize()), MAB, norm_axis));

	ArrayList<pt> ret = new ArrayList();
	ret.add(P(M,  height, norm_axis));
	ret.add(P(M, -height, norm_axis));

	return ret;
}
