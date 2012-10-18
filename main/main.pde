//*********************************************************************
//**                            3D template                          **
//**                 Jarek Rossignac, Oct  2012                      **   
//*********************************************************************
import processing.opengl.*;                // load OpenGL libraries and utilities
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*;
GL gl; 
GLU glu; 

// ****************************** GLOBAL VARIABLES FOR DISPLAY OPTIONS *********************************
Boolean
  showBalls=true,
  showMesh=false,
  translucent=false,   
  showSilhouette=true, 
  showHelpText=false; 

// ****************************** VIEW PARAMETERS *******************************************************
pt F = P(0,0,0); pt T = P(0,0,0); pt E = P(0,0,1000); vec U=V(0,1,0);  // focus  set with mouse when pressing ';', eye, and up vector
pt Q=P(0,0,0); vec I=V(1,0,0); vec J=V(0,1,0); vec K=V(0,0,1); // picked surface point Q and screen aligned vectors {I,J,K} set when picked
void initView() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,0,1000); U=V(0,1,0); } // declares the local frames

// ******************************** MESHES ***********************************************
Mesh M=new Mesh(); // meshes for models M0 and M1
Sculpture S = new Sculpture();

float sampleDistance=1;

// *******************************************************************************************************************    SETUP
void setup() {
  size(800, 800, OPENGL);  
  setColors(); sphereDetail(20);
  PFont font = loadFont("GillSans-24.vlw"); textFont(font, 20);  // font for writing labels on //  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12); 
  // ***************** OpenGL and View setup
  glu= ((PGraphicsOpenGL) g).glu;  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  gl = pgl.beginGL();  pgl.endGL();
  initView(); // declares the local frames for 3D GUI

  // ***************** Load meshes
  M.declareVectors().loadMeshVTS("data/horse.vts");
  M.resetMarkers().computeBox().updateON(); // makes a cube around C[8]

  F=P(); E=P(0,0,500);
  for(int i=0; i<10; i++) vis[i]=true; // to show all types of triangles
  }
  
// ******************************************************************************************************************* DRAW      
void draw() {  
  background(white);
  // -------------------------------------------------------- Help ----------------------------------
  if(showHelpText) {
    camera(); // 2D display to show cutout
    lights();
    fill(black); writeHelp();
    return;
    } 
    
  // -------------------------------------------------------- 3D display : set up view ----------------------------------
  camera(E.x, E.y, E.z, F.x, F.y, F.z, U.x, U.y, U.z); // defines the view : eye, ctr, up
  vec Li=U(A(V(E,F),0.1*d(E,F),J));   // vec Li=U(A(V(E,F),-d(E,F),J)); 
  directionalLight(255,255,255,Li.x,Li.y,Li.z); // direction of light: behind and above the viewer
  specular(255,255,0); shininess(5);

     // -------------------------------------------------------- show balls ---------------------------------
   if(showBalls) S.showBalls();

     // -------------------------------------------------------- show mesh ----------------------------------   
   if(showMesh) { fill(yellow); if(M.showEdges) stroke(white);  else noStroke(); M.showFront();} 
   
    // -------------------------- pick mesh corner ----------------------------------   
   if(pressed) if (keyPressed&&(key=='.')) M.pickc(Pick());
 
 
     // -------------------------------------------------------- show mesh corner ----------------------------------   
   if(showMesh) { fill(red); noStroke(); M.showc();} 
 
    // -------------------------------------------------------- edit mesh  ----------------------------------   
  if(pressed) {
     if (keyPressed&&(key=='x'||key=='z')) M.pickc(Pick()); // sets M.sc to the closest corner in M from the pick point
     if (keyPressed&&(key=='X'||key=='Z')) M.pickc(Pick()); // sets M.sc to the closest corner in M from the pick point
     }
 
  // -------------------------------------------------------- graphic picking on surface and view control ----------------------------------   
  if (keyPressed&&key==' ') T.set(Pick()); // sets point T on the surface where the mouse points. The camera will turn toward's it when the ';' key is released
  SetFrame(Q,I,J,K);  // showFrame(Q,I,J,K,30);  // sets frame from picked points and screen axes
  // rotate view 
  if(!keyPressed&&mousePressed) {E=R(E,  PI*float(mouseX-pmouseX)/width,I,K,F); E=R(E,-PI*float(mouseY-pmouseY)/width,J,K,F); } // rotate E around F 
  if(keyPressed&&key=='D'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K); }  //   Moves E forward/backward
  if(keyPressed&&key=='d'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K);U=R(U, -PI*float(mouseX-pmouseX)/width,I,J); }//   Moves E forward/backward and rotatees around (F,Y)
   
  // -------------------------------------------------------- Disable z-buffer to display occluded silhouettes and other things ---------------------------------- 
  hint(DISABLE_DEPTH_TEST);  // show on top
  if(showMesh&&showSilhouette) {stroke(dbrown); M.drawSilhouettes(); }  // display silhouettes
  camera(); // 2D view to write help text
  writeFooterHelp();
  hint(ENABLE_DEPTH_TEST); // show silouettes

  // -------------------------------------------------------- SNAP PICTURE ---------------------------------- 
   if(snapping) snapPicture(); // does not work for a large screen
    pressed=false;

 } // end draw
 
 
 // ****************************************************************************************************************************** INTERRUPTS
Boolean pressed=false;

void mousePressed() {pressed=true; }
  
void mouseDragged() {
  if(keyPressed&&key=='x') {M.add(float(mouseX-pmouseX),I).add(-float(mouseY-pmouseY),J); M.normals();} // move selected vertex in screen plane
  if(keyPressed&&key=='z') {M.add(float(mouseX-pmouseX),I).add(float(mouseY-pmouseY),K); M.normals();}  // move selected vertex in X/Z screen plane
  if(keyPressed&&key=='X') {M.addROI(float(mouseX-pmouseX),I).addROI(-float(mouseY-pmouseY),J); M.normals();} // move selected vertex in screen plane
  if(keyPressed&&key=='Z') {M.addROI(float(mouseX-pmouseX),I).addROI(float(mouseY-pmouseY),K); M.normals();}  // move selected vertex in X/Z screen plane 
  }

void mouseReleased() {
     U.set(M(J)); // reset camera up vector
    }
  
void keyReleased() {
   if(key==' ') F=P(T);                           //   if(key=='c') M0.moveTo(C.Pof(10));
   U.set(M(J)); // reset camera up vector
   } 

 
void keyPressed() {
  if(key=='a') {}
  if(key=='b') {showBalls=!showBalls;}
  if(key=='c') {}
  if(key=='d') {} 
  if(key=='e') {}
  if(key=='f') {}
  if(key=='g') {}
  if(key=='h') {}
  if(key=='i') {}
  if(key=='j') {}
  if(key=='k') {}
  if(key=='l') {}
  if(key=='m') {showMesh=!showMesh;}
  if(key=='n') {}
  if(key=='o') {}
  if(key=='p') {}
  if(key=='q') {}
  if(key=='r') {}
  if(key=='s') { S.addBall(E, F);}
  if(key=='t') {}
  if(key=='u') {}
  if(key=='v') {}
  if(key=='w') {}
  if(key=='x') {} // drag mesh vertex in xy (mouseDragged)
  if(key=='y') {}
  if(key=='z') {} // drag mesh vertex in xz (mouseDragged)
   
  if(key=='A') {}
  if(key=='B') {}
  if(key=='C') {}
  if(key=='D') {} //move in depth without rotation (draw)
  if(key=='E') {M.smoothen(); M.normals();}
  if(key=='F') {}
  if(key=='G') {}
  if(key=='H') {}
  if(key=='I') {}
  if(key=='J') {}
  if(key=='K') {}
  if(key=='L') {M.loadMeshVTS().updateON().resetMarkers().computeBox(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K)); for(int i=0; i<10; i++) vis[i]=true;}
  if(key=='M') {}
  if(key=='N') {M.next();}
  if(key=='O') {}
  if(key=='P') {}
  if(key=='Q') {exit();}
  if(key=='R') {}
  if(key=='S') {M.swing();}
  if(key=='T') {}
  if(key=='U') {}
  if(key=='V') {} 
  if(key=='W') {M.saveMeshVTS();}
  if(key=='X') {} // drag mesh vertex in xy and neighbors (mouseDragged)
  if(key=='Y') {M.refine(); M.makeAllVisible();}
  if(key=='Z') {} // drag mesh vertex in xz and neighbors (mouseDragged)

  if(key=='`') {M.perturb();}
  if(key=='~') {}
  if(key=='!') {snapping=true;}
  if(key=='@') {}
  if(key=='#') {}
  if(key=='$') {}
  if(key=='%') {}
  if(key=='&') {}
  if(key=='*') {}
  if(key=='(') {}
  if(key==')') {showSilhouette=!showSilhouette;}
  if(key=='_') {M.flatShading=!M.flatShading;}
  if(key=='+') {M.flip();} // flip edge of M
  if(key=='-') {M.showEdges=!M.showEdges;}
  if(key=='=') {}
  if(key=='{') {}
  if(key=='}') {}
  if(key=='|') {}
  if(key=='[') {initView(); F.set(M.Cbox); E.set(P(F,M.rbox*2,K));}
  if(key==']') {F.set(M.Cbox);}
  if(key==':') {translucent=!translucent;}
  if(key==';') {}
  if(key=='<') {}
  if(key=='>') {if (shrunk==0) shrunk=1; else shrunk=0;}
  if(key=='?') {showHelpText=!showHelpText;}
  if(key=='.') {} // pick corner
  if(key==',') {}
  if(key=='^') {} 
  if(key=='/') {} 
  //if(key==' ') {} // pick focus point (will be centered) (draw & keyReleased)

//  for(int i=0; i<10; i++) if (key==char(i+48)) vis[i]=!vis[i];
  
  } //------------------------------------------------------------------------ end keyPressed

float [] Volume = new float [3];
float [] Area = new float [3];
float dis = 0;
  
Boolean prev=false;

void showGrid(float s) {
  for (float x=0; x<width; x+=s*20) line(x,0,x,height);
  for (float y=0; y<height; y+=s*20) line(0,y,width,y);
  }
  
  // Snapping PICTURES of the screen
PImage myFace; // picture of author's face, read from file pic.jpg in data folder
int pictureCounter=0;
Boolean snapping=false; // used to hide some text whil emaking a picture
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); snapping=false;}

 

