#version 330
in vec2 fragTexCoord;
in vec4 fragColor;
out vec4 finalColor;
uniform sampler2D texture0;
uniform vec4 colDiffuse;
uniform float uTime;
void main(){
    vec2 uv=fragTexCoord*vec2(220.0,170.0);
    float grid=max(step(0.985,fract(uv.x)),step(0.985,fract(uv.y)));
    float pulse=0.5+0.5*sin(uTime*0.35+uv.x*0.025+uv.y*0.02);
    vec3 base=mix(vec3(0.035,0.065,0.085),vec3(0.055,0.095,0.115),pulse*0.12);
    vec3 color=mix(base,vec3(0.10,0.25,0.28),grid*0.38);
    finalColor=vec4(color,1.0)*colDiffuse*fragColor;
}
