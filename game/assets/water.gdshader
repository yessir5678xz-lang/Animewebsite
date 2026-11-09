shader_type spatial;
render_mode cull_disabled;
uniform vec4 deep_color : source_color = vec4(.035,.19,.23,1.0);
uniform vec4 crest_color : source_color = vec4(.28,.61,.60,1.0);
varying vec3 position_world;
void vertex() {
 position_world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 VERTEX.y+=sin(position_world.x*.7+TIME*.9)*.035+sin(position_world.z*1.2-TIME)*.025;
}
void fragment() {
 float a=sin(position_world.x*1.8+TIME*1.4);
 float b=cos(position_world.z*2.4-TIME*.8);
 float foam=pow(max(0.0,a*b),8.0);
 ALBEDO=mix(deep_color.rgb,crest_color.rgb,.25+.25*a*b)+foam*.12;
 NORMAL_MAP=vec3(.5+a*.12,.5+b*.12,1.0);
 ROUGHNESS=.24; METALLIC=.15; SPECULAR=.8;
}
