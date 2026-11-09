shader_type spatial;
void fragment() {
 float ripple=sin(UV.x*130.0+TIME*1.7)*sin(UV.y*90.0-TIME);
 ALBEDO=mix(vec3(.04,.25,.35),vec3(.25,.7,.65),ripple*.25+.5);
 ROUGHNESS=.25; METALLIC=.25;
}
