//
//  ModelDataStructures.h
//  Collections
//
//  Created by Roman Smirnov on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Collections_ModelDataStructures_h
#define Collections_ModelDataStructures_h



#endif


struct texCoord
{
    GLfloat		u;
    GLfloat		v;
};
typedef struct texCoord texCoord;
typedef texCoord* texCoordPtr;

typedef struct vec2 vec2;
typedef vec2* vec2Ptr;

struct vec3
{
    GLfloat x;
    GLfloat y;
    GLfloat z;
};

typedef struct vec3 vec3;
typedef vec3* vec3Ptr;

struct vec4
{
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat w;
};

typedef struct vec4 vec4;
typedef vec4* vec4Ptr;

struct vertexDataTextured
{
	vec3		vertex;
	vec3		normal;
	texCoord	texCoord;
};
typedef struct vertexDataTextured vertexDataTextured;
typedef vertexDataTextured* vertexDataTexturedPtr;

struct vertexData
{
	vec3		vertex;
	vec3		normal;
};
typedef struct vertexData vertexData;
typedef vertexData* vertexDataPtr;
