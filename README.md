3D Project
***

## High level requirements
 * Need some device which creates spheres and shoots/drops them into the
   space
 * There is a surface (infinite plane to start)
 * If a sphere intersects with the floor, it stops immediately
 * If a sphere hits another sphere, it should "roll" along the other
   sphere until it either hits the floor or contacts 2 (3?) other
spheres at which points it stops

## Detailed Requirements:
 * ~~Write a 3D interactive sculpting program.~~
 * ~~Start with an initial set of small balls, maybe filling in a large ball.~~
 * ~~Write code that let’s the user point with the mouse and spray small balls around the designated surface point.~~
 * ~~The balls should stick to the surface of the first ball they hit, roll on it away from the viewer until they hit another ball, and then roll on contact with these two until they reach a corner where they are in contact with 3 balls. Alternatively, you may directly compute that 3-ball intersection involving the ball you pointed to and go there.~~
 * Design an interface where as the mouse is pressed, it generates one new ball per frame. 
 * Explore alternatives where several balls are generated (in some cone of directions) of where several balls are placed in nearby corners.
 * Implement a tool for deleting balls that are visible and under the mouse.
 * Implement skinning for computing a triangle mesh that approximates the outer shell of the balls. Several approaches are possible. 
  1. ~~One is to run a ball-rolling algorithm with a slightly larger ball that rolls on the **centers** of the small balls. We discussed it in class.~~ 
  2. Another (possibly simpler) option is to detect all intersections between 3 spheres that are not included in any other sphere and to construct a triangle mesh from that information. Other approaches may also work. You want one that is fast, easy to implement, robust, and that produces natural results.
 * Produce a nice user interface where the user can rotate (pressing SPACE) and zoom (pressing ‘z’ and moving up or down) the view, add balls (press and keep mouse key pressed and move mouse) or delete balls (press ‘x’ and mouse key). By default the user should see only the triangle mesh, but for debugging, you may have an option to toggle displaying the balls instead.
 * ~~Add a key for exporting (saving to file) the balls and a key for exporting the triangle mesh in my .vts format (#vs, 3 vertex coordinates separated by ‘,’ for the vertices, one vertex per line, #ts, and 3 vertex indices separated by ‘,’ for the triangles, one triangle per line.~~
 * Create and save 2 models: something that looks like a human face and something that has genus 2.
 * Make a short video showing your system in action where you add, rotate, delete balls to make an interesting shape (face, caricature…). Make sure that the video title page has the course number, project title, instructor’s name, your names and head shots.

## References

 * http://realtimecollisiondetection.net/blog/?p=103 (determine if sphere and triangle intersect)
 * http://www.research.ibm.com/vistechnology/pdf/bpa_tvcg.pdf (Ball rolling) 