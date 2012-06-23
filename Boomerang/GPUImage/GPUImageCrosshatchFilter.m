#import "GPUImageCrosshatchFilter.h"

// Shader code based on http://machinesdontcare.wordpress.com/

NSString *const kGPUImageCrosshatchFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;

 uniform highp float crossHatchSpacing;
 uniform highp float lineWidth;
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

 void main()
 {
     highp float luminance = dot(texture2D(inputImageTexture, textureCoordinate).rgb, W);
     
     lowp vec4 colorToDisplay = vec4(1.0, 1.0, 1.0, 1.0);
     if (luminance < 1.00) 
     {
         if (mod(textureCoordinate.x + textureCoordinate.y, crossHatchSpacing) <= lineWidth) 
         {
             colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }
     if (luminance < 0.75) 
     {
         if (mod(textureCoordinate.x - textureCoordinate.y, crossHatchSpacing) <= lineWidth) 
         {
             colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }
     if (luminance < 0.50) 
     {
         if (mod(textureCoordinate.x + textureCoordinate.y - (crossHatchSpacing / 2.0), crossHatchSpacing) <= lineWidth) 
         {
             colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }
     if (luminance < 0.3) 
     {
         if (mod(textureCoordinate.x - textureCoordinate.y - (crossHatchSpacing / 2.0), crossHatchSpacing) <= lineWidth) 
         {
             colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }

     gl_FragColor = colorToDisplay;
 }
);


@implementation GPUImageCrosshatchFilter

@synthesize crossHatchSpacing = _crossHatchSpacing;
@synthesize lineWidth = _lineWidth;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageCrosshatchFragmentShaderString]))
    {
		return nil;
    }
    
    crossHatchSpacingUniform = [filterProgram uniformIndex:@"crossHatchSpacing"];
    lineWidthUniform = [filterProgram uniformIndex:@"lineWidth"];
    
    self.crossHatchSpacing = 0.03;
    self.lineWidth = 0.003;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setCrossHatchSpacing:(CGFloat)newValue;
{
    CGFloat singlePixelSpacing;
    if (inputTextureSize.width != 0.0)
    {
        singlePixelSpacing = 1.0 / inputTextureSize.width;
    }
    else
    {
        singlePixelSpacing = 1.0 / 2048.0;
    }
    
    if (newValue < singlePixelSpacing)
    {
        _crossHatchSpacing = singlePixelSpacing;
    }
    else
    {
        _crossHatchSpacing = newValue;
    }
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(crossHatchSpacingUniform, _crossHatchSpacing);
}

- (void)setLineWidth:(CGFloat)newValue;
{
    _lineWidth = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(lineWidthUniform, _lineWidth);
}

@end