shader_type spatial;
uniform vec4 tint : source_color = vec4(.3,.3,.3,1.0);
varying vec3 world_pos;
void vertex() { world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
float hash(vec2 p) {return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p) {
 vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void fragment() { float n=noise(world_pos.xz*1.4)*.25+noise(world_pos.xz*.15)*.4; ALBEDO=tint.rgb*(.65+n); ROUGHNESS=.95; }
