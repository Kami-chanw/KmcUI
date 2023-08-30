#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D maskSource;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    bool invert;
};

void main()
{
    float mask = texture(maskSource, qt_TexCoord0).a;
    if(invert)
        mask = 1.0 - mask;
    fragColor = texture(source, qt_TexCoord0) * mask * qt_Opacity;
}