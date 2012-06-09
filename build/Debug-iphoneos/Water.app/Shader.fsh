 //
//  Shader.fsh
//  Water
//
//  Created by Roman Smirnov on 13.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

varying highp vec2 fTexCoords;
uniform sampler2D texture;

void main()
{
    
    gl_FragColor = texture2D(texture, fTexCoords);
    
}
