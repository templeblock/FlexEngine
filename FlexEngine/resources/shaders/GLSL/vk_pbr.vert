#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec3 in_Position;
layout (location = 1) in vec2 in_TexCoord;
layout (location = 2) in vec3 in_Tangent;
layout (location = 3) in vec3 in_Bitangent;
layout (location = 4) in vec3 in_Normal;

layout (location = 0) out vec3 ex_WorldPos;
layout (location = 1) out vec2 ex_TexCoord;
layout (location = 2) out mat3 ex_TBN;

struct PointLight 
{
	vec4 position;

	vec4 color;

	bool enabled;
};
#define NUMBER_POINT_LIGHTS 4

// Updated once per frame
layout (binding = 0) uniform UBOConstant
{
	mat4 viewProjection;
    vec4 camPos;
	PointLight pointLights[NUMBER_POINT_LIGHTS];
} uboConstant;

// Updated once per object
layout (binding = 1) uniform UBODynamic
{
	mat4 model;
	mat4 modelInvTranspose;
} uboDynamic;

void main()
{
    vec4 worldPos = uboDynamic.model * vec4(in_Position, 1.0);
    ex_WorldPos = worldPos.xyz; 
	
	ex_TexCoord = in_TexCoord;

   	// Convert normal to model-space and prevent non-uniform scale issues
	ex_TBN = mat3(
		normalize(mat3(uboDynamic.modelInvTranspose) * in_Tangent), 
		normalize(mat3(uboDynamic.modelInvTranspose) * in_Bitangent), 
		normalize(mat3(uboDynamic.modelInvTranspose) * in_Normal));

    gl_Position = uboConstant.viewProjection * worldPos;
    
	// Convert from GL coordinates to Vulkan coordinates
	// TODO: Move out to external function in helper file
	gl_Position.y = -gl_Position.y;
	gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}