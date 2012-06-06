//
//  Shader.vsh
//  Water
//
//  Created by Roman Smirnov on 13.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

attribute vec3 position;
//attribute vec3 normal;
attribute vec2 textureCoord;

varying lowp vec4 colorVarying;
varying highp vec2 fTexCoords;

uniform mat4 modelViewProjectionMatrix;
//uniform mat3 normalMatrix;
uniform float time;

//wave = (Amplitude, Wavenumber, Angular frequency, Phase)
//waveparam = (Type, Direction, Center Position X, Center Position Y)

//TEST


uniform vec4 wave1;
uniform vec4 wave1param2;
uniform vec4 wave2;
uniform vec4 wave2param2;
uniform vec4 wave3;
uniform vec4 wave3param2;
uniform vec4 wave4;
uniform vec4 wave4param2;

// waveDirection = (angle of wave 1, angle of wave 2, ..., angle of wave 4)

uniform vec4 wave1234direction;

void main()
{
//    vec3 eyeNormal = normalize(normalMatrix * normal);
//    vec3 lightPosition = vec3(0.0, 2.0, 0.0);
//    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0) ;
//    
//    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
//                 
//    colorVarying = diffuseColor * nDotVP;
    
    //затухающая волна
//    vec4 posWave = vec4(position.x, position.z, 5.0*sin(20.0*(position.x + time))/(20.0*(1.0 + position.x + time)), 1.0); 
    
    float wave1positionZ, wave2positionZ, wave3positionZ, wave4positionZ;
    
    //Wave 1
    //синусоидальная волна
    if ( abs(wave1param2.x - 1.0/10.0) < 0.0001 ) {
        vec2 waveVector = vec2(cos(wave1param2.y), sin(wave1param2.y));
        wave1positionZ = wave1.x*sin( (wave1.y * (waveVector.x*position.x + waveVector.y*position.z) - wave1.z * time) + wave1.w ); 
    }
    //сферическая волна
    else if ( abs(wave1param2.x - 2.0/10.0) < 0.0001 ) {
        vec2 center = vec2(wave1param2.z, wave1param2.w);
        float dist = length (position.xz - center);
        wave1positionZ = wave1.x*cos(wave1.y*dist - wave1.z*time + wave1.w);
        
        //    //затухающая сомбреро-волна
        //    float posSombreroWaveZ = 0.5/(1.0+dist*5.0+time)*cos(1.0*time + 5.00*dist +0.0);
        
    }
    //спиральная волна
    else if ( abs(wave1param2.x - 3.0/10.0) < 0.0001 ) {
        vec2 center = vec2(wave1param2.z, wave1param2.w);
        float r = length (position.xz - center);
        float q;
        if (position.x-center.x > 0.0 && position.z-center.y >= 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x));
        }
        if (position.x-center.x > 0.0 && position.z-center.y < 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x)) + radians (360.0);
        }
        if (position.x-center.x < 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x)) + radians(180.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y > 0.0) { 
            q = radians (90.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y < 0.0) { 
            q = radians (-90.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y == 0.0) { 
            q = radians (0.0);
        }        
        
        wave1positionZ = wave1.x * sin( wave1.y*r - q - wave1.z*time + wave1.w);
    }
    //Wave 2
    //синусоидальная волна
    if ( abs(wave2param2.x - 1.0/10.0) < 0.0001 ) {
        vec2 waveVector = vec2(cos(wave2param2.y), sin(wave2param2.y));
        wave2positionZ = wave2.x*sin( (wave2.y * (waveVector.x*position.x + waveVector.y*position.z) - wave2.z * time) + wave2.w ); 
    }
    //сферическая волна
    else if ( abs(wave2param2.x - 2.0/10.0) < 0.0001 ) {
        vec2 center = vec2(wave2param2.z, wave2param2.w);
        float dist = length (position.xz - center);
        wave2positionZ = wave2.x*cos(wave2.y*dist - wave2.z*time + wave2.w);        
    }
    //спиральная волна
    else if ( abs(wave2param2.x - 3.0/10.0) < 0.0001 ) {
        vec2 center = vec2(wave2param2.z, wave2param2.w);
        float r = length (position.xz - center);
        float q;
        if (position.x-center.x > 0.0 && position.z-center.y >= 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x));
        }
        if (position.x-center.x > 0.0 && position.z-center.y < 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x)) + radians (360.0);
        }
        if (position.x-center.x < 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x)) + radians(180.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y > 0.0) { 
            q = radians (90.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y < 0.0) { 
            q = radians (-90.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y == 0.0) { 
            q = radians (0.0);
        }        
        
        wave2positionZ = wave2.x * sin( wave2.y*r - q - wave2.z*time + wave2.w);
    }
    
    //Wave 3
    //синусоидальная волна
    if ( abs(wave3param2.x - 1.0/10.0) < 0.0001 ) {
        vec2 waveVector = vec2(cos(wave3param2.y), sin(wave3param2.y));
        wave3positionZ = wave3.x*sin( (wave3.y * (waveVector.x*position.x + waveVector.y*position.z) - wave3.z * time) + wave3.w ); 
    }
    //сферическая волна
    else if ( abs(wave3param2.x - 2.0/10.0) < 0.0001 ) {
        vec2 center = vec2(wave3param2.z, wave3param2.w);
        float dist = length (position.xz - center);
        wave3positionZ = wave3.x*cos(wave3.y*dist - wave3.z*time + wave3.w);        
    }
    //спиральная волна
    else if ( abs(wave3param2.x - 3.0/10.0) < 0.0001 ) {
        vec2 center = vec2(wave3param2.z, wave3param2.w);
        float r = length (position.xz - center);
        float q;
        if (position.x-center.x > 0.0 && position.z-center.y >= 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x));
        }
        if (position.x-center.x > 0.0 && position.z-center.y < 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x)) + radians (360.0);
        }
        if (position.x-center.x < 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x)) + radians(180.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y > 0.0) { 
            q = radians (90.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y < 0.0) { 
            q = radians (-90.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y == 0.0) { 
            q = radians (0.0);
        }        
        
        wave3positionZ = wave3.x * sin( wave3.y*r - q - wave3.z*time + wave3.w);
    }
    
    
    //Wave 4
    //синусоидальная волна
    if ( abs(wave4param2.x - 1.0/10.0) < 0.0001 ) {
        vec2 waveVector = vec2(cos(wave4param2.y), sin(wave4param2.y));
        wave4positionZ = wave4.x*sin( (wave4.y * (waveVector.x*position.x + waveVector.y*position.z) - wave4.z * time) + wave4.w ); 
    }
    //сферическая волна
    else if ( abs(wave4param2.x - 2.0/10.0) < 0.0001 ) {
        vec2 center = vec2(wave4param2.z, wave4param2.w);
        float dist = length (position.xz - center);
        wave4positionZ = wave4.x*cos(wave4.y*dist - wave4.z*time + wave4.w);        
    }
    //спиральная волна
    else if ( abs(wave4param2.x - 3.0/10.0) < 0.0001 ) {
        vec2 center = vec2(wave4param2.z, wave4param2.w);
        float r = length (position.xz - center);
        float q;
        if (position.x-center.x > 0.0 && position.z-center.y >= 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x));
        }
        if (position.x-center.x > 0.0 && position.z-center.y < 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x)) + radians (360.0);
        }
        if (position.x-center.x < 0.0) { 
            q = atan((position.z-center.y)/(position.x-center.x)) + radians(180.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y > 0.0) { 
            q = radians (90.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y < 0.0) { 
            q = radians (-90.0);
        }
        if (position.x-center.x == 0.0 && position.z-center.y == 0.0) { 
            q = radians (0.0);
        }        
        
        wave4positionZ = wave4.x * sin( wave4.y*r - q - wave4.z*time + wave4.w);
    }
    
    float resultZ = wave1positionZ + wave2positionZ + wave3positionZ + wave4positionZ;
        
    vec4 posResult = vec4(position.x, position.z, resultZ, 1.0);
//    posResult.xy = posResult.xy * 100.0;
 
    fTexCoords = textureCoord;
               
    gl_Position = modelViewProjectionMatrix * posResult;
    
//    colorVarying = vec4(0.0, 0.0, 1.0-gl_Position.x, 1.0);
}
