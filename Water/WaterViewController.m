//
//  WaterViewController.m
//  Water
//
//  Created by Roman Smirnov on 13.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaterViewController.h"
#import "SettingsTableViewController.h"
#import "Water3.h"
#import "Wave.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TIME,
    UNIFORM_TEXTURE,
    UNIFORM_WAVE_1,
    UNIFORM_WAVE_1_PARAM_2,
    UNIFORM_WAVE_2,
    UNIFORM_WAVE_2_PARAM_2,
    UNIFORM_WAVE_3,
    UNIFORM_WAVE_3_PARAM_2,
    UNIFORM_WAVE_4,
    UNIFORM_WAVE_4_PARAM_2,

    UNIFORM_WAVE_1234_DIRECTION,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    ATTRIB_TEX_COORDS,
    NUM_ATTRIBUTES
};

@interface WaterViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
        
    GLuint _waterVertexArray;
    GLuint _waterVertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation WaterViewController

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize popController = _popController;

- (NSMutableArray *) waves
{
    if (!_waves) {
        _waves = [NSMutableArray array];
    }
    return _waves;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    UIGestureRecognizer *pinchgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinchgr];
    UIGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pangr];
    UIPanGestureRecognizer *pangr2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan2:)];
    pangr2.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:pangr2];
    UIPanGestureRecognizer *pangr3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan3:)];
    pangr3.minimumNumberOfTouches = 3;
    [self.view addGestureRecognizer:pangr3];
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tapgr.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapgr];
    UITapGestureRecognizer *tapgr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.view addGestureRecognizer:tapgr1];
    
    scale.x = 0.85f;
    scale.y = 0.85f;
    scale.z = 0.85f;
    
    Wave *wave1 = [[Wave alloc] init];
    wave1.name = @"Wave 1";
    wave1.type = WAVE_TYPE_HARMONIC;
    wave1.amplitude = 0.5f;
    wave1.wavenumber = 0.5f;
    wave1.angularFrequency = 1.5f;
    wave1.phase = 0.0f;
    wave1.direction = 0.0f;
    wave1.positionX = 0.0f;
    wave1.positionY = 0.0f;
    [self.waves addObject:wave1];

    Wave *wave2 = [[Wave alloc] init];
    wave2.name = @"Wave 2";
    wave2.type = WAVE_TYPE_HARMONIC;
    wave2.amplitude = 0.0f;
    wave2.wavenumber = 0.5f;
    wave2.angularFrequency = 1.5f;
    wave2.phase = 0.0f;
    wave2.direction = 0.0f;
    wave2.positionX = 0.0f;
    wave2.positionY = 0.0f;
    [self.waves addObject:wave2];

    Wave *wave3 = [[Wave alloc] init];
    wave3.name = @"Wave 3";
    wave3.type = WAVE_TYPE_HARMONIC;
    wave3.amplitude = 0.0f;
    wave3.wavenumber = 0.5f;
    wave3.angularFrequency = 1.5f;
    wave3.phase = 0.0f;
    wave3.direction = 0.0f;
    wave3.positionX = 0.0f;
    wave3.positionY = 0.0f;
    [self.waves addObject:wave3];
    
    Wave *wave4 = [[Wave alloc] init];
    wave4.name = @"Wave 4";
    wave4.type = WAVE_TYPE_HARMONIC;
    wave4.amplitude = 0.0f;
    wave4.wavenumber = 0.5f;
    wave4.angularFrequency = 1.5f;
    wave4.phase = 0.0f;
    wave4.direction = 0.0f;
    wave4.positionX = 0.0f;
    wave4.positionY = 0.0f;
    [self.waves addObject:wave4];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                            target:self
                                                                                            action:@selector(settingsPressed:)];
    self.wantsFullScreenLayout = YES;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidUnload
{    
    display = nil;
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)updateDisplay
{
    NSString *text = [NSString stringWithFormat:@"rotation = (%f, %f, %f)\n", rotation.x, rotation.y, rotation.z];
    text = [text stringByAppendingFormat:@"translation = (%f, %f, %f)\n", translation.x, translation.y, translation.z];
    text = [text stringByAppendingFormat:@"scale = (%f, %f, %f)\n", scale.x, scale.y, scale.z];

    [display setText:text];
}

- (GLuint)setupTexture:(NSString *)fileName {    
    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, 
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);    
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);        
    return texName;    
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
        
    glEnable(GL_DEPTH_TEST);

    glGenVertexArraysOES(1, &_waterVertexArray);
    glBindVertexArrayOES(_waterVertexArray);
    
    glGenBuffers(1, &_waterVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _waterVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(WaterMeshVertexData), WaterMeshVertexData, GL_STATIC_DRAW);

    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), BUFFER_OFFSET(12));
    glEnableVertexAttribArray(ATTRIB_TEX_COORDS);
    glVertexAttribPointer(ATTRIB_TEX_COORDS, 2, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), BUFFER_OFFSET(24));

    
    glBindVertexArrayOES(0);
    
    _waterTexture = [self setupTexture:@"waterTexture1024.jpg"];
//    _waterTexture = [self setupTexture:@"waterTexture2048.jpg"];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_waterVertexArray);
    glDeleteVertexArraysOES(1, &_waterVertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - Gesture recognisers handlers

- (void) pinch:(UIPinchGestureRecognizer *) gesture
{
    //        NSLog(@"OpenGLViewController > pinch:");
    
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        scale.x *= gesture.scale; if (scale.x < 0.3f) scale.x = 0.3f; if (scale.x > 1.0f) scale.x = 1.0f; 
        scale.y *= gesture.scale; if (scale.y < 0.3f) scale.y = 0.3f; if (scale.y > 1.0f) scale.y = 1.0f; 
        scale.z *= gesture.scale; if (scale.z < 0.3f) scale.z = 0.3f; if (scale.z > 1.0f) scale.z = 1.0f; 

        
        //        NSLog(@"gesture.scale == %f", gesture.scale);
        gesture.scale = 1;
        [self updateDisplay];

    }
}

- (void) singleTap:(UITapGestureRecognizer *) gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (!self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.navigationController.navigationBar.translucent = YES;

        } else {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            self.navigationController.navigationBar.translucent = YES;

        }
    }
}

- (void) doubleTap:(UITapGestureRecognizer *) gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        scale = (vec3){1.0f, 1.0f, 1.0f};
        rotation = (vec3){0.0f, 0.0f, 0.0f};
        [self updateDisplay];
    }
}


- (void) pan:(UIPanGestureRecognizer *)gesture
{
//    NSLog(@"OpenGLViewController > pan:");
    
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint trans = [gesture translationInView:self.view];
        rotation.y += trans.x * M_PI / 180.0f;
        rotation.x += trans.y * M_PI / 180.0f;
//        translation.x += trans.x/10.0;
//        translation.y += trans.y/10.0;
        //        NSLog(@"rotationSpeed.x == %f", rotationSpeed.x);
        //        NSLog(@"rotationSpeed.y == %f", rotationSpeed.y);        
        [gesture setTranslation:CGPointZero inView:self.view];
        [self updateDisplay];
    }
}

- (void) pan2:(UIPanGestureRecognizer *)gesture
{
    
//    NSLog(@"OpenGLViewController > pan2:");
    
//    if ((gesture.state == UIGestureRecognizerStateChanged) ||
//        (gesture.state == UIGestureRecognizerStateEnded)) {
//        CGPoint trans = [gesture translationInView:self.view];
//        //        rotation.y += trans.x * M_PI / 180.0f;
//        //        rotation.z += trans.y * M_PI / 180.0f;
//        translation.x += trans.x/10.0;
//        translation.z += trans.y/10.0;
//        //        NSLog(@"rotationSpeed.x == %f", rotationSpeed.x);
//        //        NSLog(@"rotationSpeed.y == %f", rotationSpeed.y);        
//        [gesture setTranslation:CGPointZero inView:self.view];
//        [self updateDisplay];
//    }
}

- (void) pan3:(UIPanGestureRecognizer *)gesture
{
//        NSLog(@"OpenGLViewController > pan3:");
    
//    if ((gesture.state == UIGestureRecognizerStateChanged) ||
//        (gesture.state == UIGestureRecognizerStateEnded)) {
//        CGPoint trans = [gesture translationInView:self.view];
//
//        translation.y += trans.y/10.0;
//
//        //        rotation.y += trans.x * M_PI / 180.0f;
//        //        rotation.z += trans.y * M_PI / 180.0f;
////        translation.x += trans.x/10.0;
////        translation.y += trans.y/10.0;
//        //        NSLog(@"rotationSpeed.x == %f", rotationSpeed.x);
//        //        NSLog(@"rotationSpeed.y == %f", rotationSpeed.y);        
//        [gesture setTranslation:CGPointZero inView:self.view];
//        [self updateDisplay];
//    }
}

#pragma mark - Buttons handlers

- (void) settingsPressed:(id)sender
{
    //popover here
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        
        //мы на iPad
        
        if (!self.popController) {
            SettingsTableViewController* settings = [[SettingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
            settings.delegate = self;
            settings.tableView.scrollEnabled = NO;
            UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:settings];
            UIPopoverController* aPopover = [[UIPopoverController alloc]
                                             initWithContentViewController:navcon];
            aPopover.delegate = self;
            
            // Store the popover in a custom property for later use.
            self.popController = aPopover;
            
            [self.popController presentPopoverFromBarButtonItem:sender
                                       permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [self.popController dismissPopoverAnimated:YES];
            self.popController = nil;
        }    
    } 
    else if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) 
    {
        // мы на iPhone
        
        SettingsTableViewController* settings = [[SettingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
        settings.delegate = self;
//        settings.tableView.scrollEnabled = YES;
        [[self navigationController] pushViewController:settings animated:YES];

    }
    

}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
//    NSLog(@" (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController");
    self.popController = nil;
}


#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    
//    aspect = 1.0f;
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), aspect, 0.1f, 100.0f);
    
//    self.effect.transform.projectionMatrix = projectionMatrix;
    
//    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
//    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);

//    GLKMatrix4 baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
//    baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    
    //двигаем весь мир
//    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(translation.x, translation.y, -100.0 + translation.z);
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(translation.x, translation.y, -10.0 + translation.z);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, rotation.x, 1.0f, 0.0f, 0.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, rotation.y, 0.0f, 1.0f, 0.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, rotation.z, 0.0f, 0.0f, 1.0f);

    baseModelViewMatrix = GLKMatrix4Scale(baseModelViewMatrix, scale.x, scale.y, scale.z);
    
    //поворот на 90 для согласования осей координат blender и OpenGL
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, GLKMathDegreesToRadians(-75.0f), 1.0f, 0.0f, 0.0f);

//    baseModelViewMatrix = GLKMatrix4Scale(baseModelViewMatrix, 20.0f, 50.0f, 1.0f);

    
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
//    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
//    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale.x, scale.y, scale.z);

//    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 3.0f, 5.0f, 1.0f);
    
    
    
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    time = self.timeSinceLastResume;
    
//    NSLog(@"time= %f", time);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    glBindVertexArrayOES(_vertexArray);
//    
//    // Render the object with GLKit
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLES, 0, 36);
//    
//    // Render the object again with ES2
//    glUseProgram(_program);
//    
//    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
//    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
//    
//    glDrawArrays(GL_TRIANGLES, 0, 36);

    glBindVertexArrayOES(_waterVertexArray);

    
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform1f(uniforms[UNIFORM_TIME], time);
    
    glActiveTexture(GL_TEXTURE0); 
    glBindTexture(GL_TEXTURE_2D, _waterTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);


    Wave *wave1 = [self.waves objectAtIndex:0];
    Wave *wave2 = [self.waves objectAtIndex:1];
    Wave *wave3 = [self.waves objectAtIndex:2];
    Wave *wave4 = [self.waves objectAtIndex:3];
    glUniform4f(uniforms[UNIFORM_WAVE_1],           wave1.amplitude,          wave1.wavenumber, wave1.angularFrequency, wave1.phase);
    glUniform4f(uniforms[UNIFORM_WAVE_1_PARAM_2],   (GLfloat)wave1.type/10.0, wave1.direction,  wave1.positionX,        wave1.positionY);
    glUniform4f(uniforms[UNIFORM_WAVE_2],           wave2.amplitude,          wave2.wavenumber, wave2.angularFrequency, wave2.phase);
    glUniform4f(uniforms[UNIFORM_WAVE_2_PARAM_2],   (GLfloat)wave2.type/10.0, wave2.direction,  wave2.positionX,        wave2.positionY);
    glUniform4f(uniforms[UNIFORM_WAVE_3],           wave3.amplitude,          wave3.wavenumber, wave3.angularFrequency, wave3.phase);
    glUniform4f(uniforms[UNIFORM_WAVE_3_PARAM_2],   (GLfloat)wave3.type/10.0, wave3.direction,  wave3.positionX,        wave3.positionY);
    glUniform4f(uniforms[UNIFORM_WAVE_4],           wave4.amplitude,          wave4.wavenumber, wave4.angularFrequency, wave4.phase);
    glUniform4f(uniforms[UNIFORM_WAVE_4_PARAM_2],   (GLfloat)wave4.type/10.0, wave4.direction,  wave4.positionX,        wave4.positionY);

    glUniform4f(uniforms[UNIFORM_WAVE_1234_DIRECTION], wave1.direction, wave2.direction, wave3.direction, wave4.direction);

    
    
    glDrawArrays(GL_TRIANGLES, 0, 19602 * 3);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIB_NORMAL, "normal");
    glBindAttribLocation(_program, ATTRIB_TEX_COORDS, "textureCoord");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TIME] = glGetUniformLocation(_program, "time");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    uniforms[UNIFORM_WAVE_1] = glGetUniformLocation(_program, "wave1");
    uniforms[UNIFORM_WAVE_2] = glGetUniformLocation(_program, "wave2");
    uniforms[UNIFORM_WAVE_3] = glGetUniformLocation(_program, "wave3");
    uniforms[UNIFORM_WAVE_4] = glGetUniformLocation(_program, "wave4");
    uniforms[UNIFORM_WAVE_1_PARAM_2] = glGetUniformLocation(_program, "wave1param2");
    uniforms[UNIFORM_WAVE_2_PARAM_2] = glGetUniformLocation(_program, "wave2param2");
    uniforms[UNIFORM_WAVE_3_PARAM_2] = glGetUniformLocation(_program, "wave3param2");
    uniforms[UNIFORM_WAVE_4_PARAM_2] = glGetUniformLocation(_program, "wave4param2");

    
    uniforms[UNIFORM_WAVE_1234_DIRECTION] = glGetUniformLocation(_program, "wave1234direction");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
