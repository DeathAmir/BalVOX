#include "raylib.h"
#include "raymath.h"
#include <algorithm>
#include <cmath>
#include <string>
#include <vector>

struct Shot { Vector3 p, v; float age=0; bool alive=true; };
struct Particle { Vector3 p, v; float life, maxLife; Color color; };
struct Target { Vector3 p; bool hit=false; float flash=0; };

static float ClampF(float v,float a,float b){return std::max(a,std::min(v,b));}
static Vector3 V(float x,float y,float z){return {x,y,z};}
static Color Alpha(Color c,float a){c.a=(unsigned char)(255*ClampF(a,0,1));return c;}

int main(){
    SetConfigFlags(FLAG_MSAA_4X_HINT|FLAG_WINDOW_RESIZABLE);
    InitWindow(1440,900,"BalVOX | Missile Sandbox");
    SetTargetFPS(120);
    Camera3D camera={V(0,22,38),V(0,2,0),V(0,1,0),55,CAMERA_PERSPECTIVE};
    Shader ground=LoadShader(0,"shaders/ground.fs");
    int timeLoc=GetShaderLocation(ground,"uTime");
    float yaw=0.0f,pitch=0.48f,power=0.68f,elapsed=0;
    bool paused=false,showHelp=true;
    std::vector<Shot> shots;
    std::vector<Particle> particles;
    std::vector<Target> targets;
    for(int i=0;i<7;i++) targets.push_back({V(-24.0f+i*8.0f,1.2f,-48.0f-(i%2)*10.0f),false,0});
    int launches=0,hits=0;
    Vector3 launcher=V(0,0,8);
    while(!WindowShouldClose()){
        float dt=std::min(GetFrameTime(),0.033f);
        elapsed+=dt;
        if(IsKeyPressed(KEY_H)) showHelp=!showHelp;
        if(IsKeyPressed(KEY_TAB)) paused=!paused;
        if(!paused){
            if(IsKeyDown(KEY_A)) yaw-=1.1f*dt;
            if(IsKeyDown(KEY_D)) yaw+=1.1f*dt;
            if(IsKeyDown(KEY_W)) pitch=ClampF(pitch+0.65f*dt,0.12f,1.18f);
            if(IsKeyDown(KEY_S)) pitch=ClampF(pitch-0.65f*dt,0.12f,1.18f);
            if(IsKeyDown(KEY_Q)) power=ClampF(power-dt*0.35f,0.25f,1.0f);
            if(IsKeyDown(KEY_E)) power=ClampF(power+dt*0.35f,0.25f,1.0f);
            if(IsKeyPressed(KEY_R)){shots.clear();particles.clear();for(auto &t:targets){t.hit=false;t.flash=0;}hits=0;}
            if(IsMouseButtonPressed(MOUSE_BUTTON_LEFT)){
                Vector3 dir=V(sinf(yaw)*cosf(pitch),sinf(pitch),-cosf(yaw)*cosf(pitch));
                shots.push_back({Vector3Add(launcher,V(0,2.5f,0)),Vector3Scale(dir,25.0f+power*37.0f),0,true});
                launches++;
            }
            for(auto &s:shots){
                if(!s.alive) continue;
                s.age+=dt;
                s.v.y-=13.5f*dt;
                s.p=Vector3Add(s.p,Vector3Scale(s.v,dt));
                bool impact=s.p.y<=0.35f||s.age>8.5f;
                for(auto &t:targets) if(!t.hit&&Vector3Distance(s.p,t.p)<3.3f){t.hit=true;t.flash=1;impact=true;hits++;}
                if(impact){
                    s.alive=false;
                    for(int i=0;i<100;i++){
                        Vector3 d=V((GetRandomValue(-100,100))/100.0f,(GetRandomValue(-10,100))/100.0f,(GetRandomValue(-100,100))/100.0f);
                        d=Vector3Normalize(d);
                        float speed=(float)GetRandomValue(5,24);
                        Color c=(i%4==0)?ORANGE:(i%3==0)?YELLOW:Color{255,115,48,255};
                        particles.push_back({s.p,Vector3Scale(d,speed),GetRandomValue(45,110)/100.0f,GetRandomValue(45,110)/100.0f,c});
                    }
                }
            }
            for(auto &p:particles){p.life-=dt;p.p=Vector3Add(p.p,Vector3Scale(p.v,dt));p.v=Vector3Scale(p.v,0.985f);p.v.y-=2.0f*dt;}
            particles.erase(std::remove_if(particles.begin(),particles.end(),[](const Particle&p){return p.life<=0;}),particles.end());
            for(auto &t:targets)t.flash=std::max(0.0f,t.flash-dt*1.7f);
        }
        Vector3 aim=V(sinf(yaw)*cosf(pitch),sinf(pitch),-cosf(yaw)*cosf(pitch));
        camera.target=V(0,3,-18);
        camera.position=V(sinf(yaw)*3.5f,19+pitch*3,35+cosf(yaw)*3.5f);
        if(IsKeyDown(KEY_RIGHT)) camera.position.x+=18*dt;
        if(IsKeyDown(KEY_LEFT)) camera.position.x-=18*dt;
        BeginDrawing();
        ClearBackground(Color{10,17,29,255});
        BeginMode3D(camera);
        SetShaderValue(ground,timeLoc,&elapsed,SHADER_UNIFORM_FLOAT);
        BeginShaderMode(ground);
        DrawPlane(V(0,-0.08f,-25),V(240,180),WHITE);
        EndShaderMode();
        for(int x=-100;x<=100;x+=10) DrawLine3D(V((float)x,0.015f,-110),V((float)x,0.015f,55),Color{53,77,91,100});
        for(int z=-110;z<=55;z+=10) DrawLine3D(V(-100,0.015f,(float)z),V(100,0.015f,(float)z),Color{53,77,91,100});
        DrawCube(V(0,-0.5f,-25),220,1,170,Color{19,31,43,255});
        DrawCube(V(0,0.15f,8),10,0.3f,9,Color{39,51,62,255});
        DrawCube(V(0,0.45f,8),5.2f,0.35f,5.5f,Color{64,76,83,255});
        DrawCylinder(V(0,0.9f,8),2.2f,2.2f,0.35f,24,Color{82,94,99,255});
        DrawCylinder(V(0,1.25f,8),0.85f,1.0f,0.5f,20,Color{143,153,151,255});
        Vector3 base=V(0,2.0f,8);
        DrawCylinderEx(base,Vector3Add(base,Vector3Scale(aim,5.4f)),0.52f,0.20f,16,Color{174,183,180,255});
        DrawSphere(Vector3Add(base,Vector3Scale(aim,5.5f)),0.23f,ORANGE);
        for(auto &t:targets){
            Color tc=t.hit?Color{48,190,126,255}:Color{210,90,68,255};
            DrawCube(t.p,3.2f,2.4f,1.4f,tc);
            DrawCubeWires(t.p,3.3f,2.5f,1.5f,RAYWHITE);
            DrawCylinder(V(t.p.x,t.p.y+1.6f,t.p.z),0.16f,0.16f,2.0f,10,tc);
            DrawSphere(V(t.p.x,t.p.y+2.7f,t.p.z),0.35f,t.hit?GREEN:RED);
            if(t.flash>0) DrawSphere(t.p,3.5f,Alpha(ORANGE,t.flash*0.25f));
        }
        for(auto &s:shots) if(s.alive){
            DrawSphere(s.p,0.34f,Color{255,208,116,255});
            DrawCylinderEx(Vector3Subtract(s.p,Vector3Scale(Vector3Normalize(s.v),2.0f)),s.p,0.12f,0.28f,8,ORANGE);
            DrawSphere(Vector3Subtract(s.p,Vector3Scale(Vector3Normalize(s.v),1.8f)),0.22f,Alpha(ORANGE,0.55f));
        }
        for(auto &p:particles) DrawSphere(p.p,0.10f+0.16f*(p.life/p.maxLife),Alpha(p.color,p.life/p.maxLife));
        DrawGrid(40,5.0f);
        EndMode3D();
        DrawRectangleGradientV(0,0,GetScreenWidth(),110,Color{7,13,23,245},Color{7,13,23,0});
        DrawText("BALVOX",28,20, thirty=30,Color{235,242,247,255});
        DrawText("MISSILE SANDBOX  /  RANGE 01",30,56,14,Color{117,174,190,255});
        DrawText("SIMULATION  ONLINE",GetScreenWidth()-245,30,15,GREEN);
        DrawCircle(GetScreenWidth()-263,38,4,GREEN);
        DrawRectangle(24,GetScreenHeight()-132,350,108,Color{7,13,23,220});
        DrawText("LAUNCH CONTROL",42,GetScreenHeight()-116,14,Color{122,190,205,255});
        DrawText(TextFormat("ELEVATION  %02.0f",pitch*57.2958f),42,GetScreenHeight()-88,16,RAYWHITE);
        DrawText(TextFormat("OUTPUT      %02.0f%%",power*100),42,GetScreenHeight()-62,16,RAYWHITE);
        DrawRectangle(220,GetScreenHeight()-59,130,9,Color{37,52,65,255});
        DrawRectangle(220,GetScreenHeight()-59,(int)(130*power),9,Color{63,190,181,255});
        DrawRectangle(GetScreenWidth()-260,GetScreenHeight()-132,236,108,Color{7,13,23,220});
        DrawText("RANGE TELEMETRY",GetScreenWidth()-242,GetScreenHeight()-116,14,Color{122,190,205,255});
        DrawText(TextFormat("LAUNCHES   %03i",launches),GetScreenWidth()-242,GetScreenHeight()-88,15,RAYWHITE);
        DrawText(TextFormat("TARGETS    %02i / 07",hits),GetScreenWidth()-242,GetScreenHeight()-62,15,RAYWHITE);
        if(showHelp){
            DrawRectangle(GetScreenWidth()/2-205,GetScreenHeight()-76,410,34,Color{7,13,23,190});
            DrawText("A/D YAW   W/S ELEVATION   Q/E POWER   CLICK LAUNCH   R RESET   H HELP",GetScreenWidth()/2-193,GetScreenHeight()-65,10,Color{203,216,222,255});
        }
        if(paused){DrawRectangle(0,0,GetScreenWidth(),GetScreenHeight(),Fade(BLACK,0.55f));DrawText("SIMULATION PAUSED",GetScreenWidth()/2-145,GetScreenHeight()/2-15,28,RAYWHITE);}
        EndDrawing();
    }
    UnloadShader(ground);
    CloseWindow();
    return 0;
}
