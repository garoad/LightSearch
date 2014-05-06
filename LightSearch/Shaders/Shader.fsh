//
//  Shader.fsh
//  LightSearcher
//
//  Created by Won-Young Sohn on 2014. 4. 22..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
