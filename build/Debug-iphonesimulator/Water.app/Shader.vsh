//
//  Shader.vsh
//  Water
//
//  Created by Roman Smirnov on 13.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

attribute vec3 position;
attribute vec3 normal;
attribute vec2 textureCoord;

varying lowp vec4 colorVarying;
varying highp vec2 fTexCoords;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform float time;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 2.0, 0.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0) ;
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;

    
    //затухающая волна
    vec4 posWave = vec4(position.x, position.z, 5.0*sin(20.0*(position.x + time))/(20.0*(1.0 + position.x + time)), 1.0); 
    
    
    //синусоидальная волна
    vec2 waveVector = vec2(1.0, 0.3);
    vec4 posSinWave = vec4(position.x, position.z, 0.04*sin(20.0*(waveVector.x*position.x + waveVector.y*position.z+0.05*time)), 1.0); 

    //синусоидальная в  vec2(1.0, 1.0);
    vec2 waveVector2 = vec2(1.0, 1.0);
    vec4 posSinWave2 = vec4(position.x, position.z, 0.04*sin(20.0*(waveVector2.x*position.x + waveVector2.y*position.z+0.05*time)), 1.0); 

    //затухающая сомбреро-волна
    vec2 sombreroSource = vec2(0.0, -0.5);
    float dist = length (position.xz - sombreroSource);
    float posSombreroWaveZ = 0.5/(1.0+dist*5.0+time)*cos(1.0*time + 5.00*dist +0.0);

//    float resultZ = posSinWave.z + posSinWave2.z + posSombreroWaveZ;
    float resultZ = posSombreroWaveZ;
    
    vec4 posResult = vec4(position.x, position.z, resultZ, 1.0);
 
    fTexCoords = textureCoord;
               
    gl_Position = modelViewProjectionMatrix * posResult;
    
//    colorVarying = vec4(0.0, 0.0, 1.0-gl_Position.x, 1.0);
}
