//////////////////////////////////////////////////////////////////////////
//                                                                      //
//  ENBSeries effect file                                               //
//  visit http://enbdev.com for updates                                 //
//  Copyright (c) 2007-2013 Boris Vorontsov                             //
//                                                                      //
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//                                                                      //
//  enbsunsprite.fx created by kingeric1992                             //
//      dedicate to                                                     //
//          "Frazetta ENB - Human Temporal Glare Sunsprite" by Veeblix  //
//  nexus link:                                                         //
//      http://www.nexusmods.com/skyrim/mods/61405/                     //
//                                                                      //
//  for more info about sunsprite, check                                //
//      http://enbseries.enbdev.com/forum/viewtopic.php?f=7&t=3549      //
//                                                                      //
//  update: Feb.1.2015                                                  //
//////////////////////////////////////////////////////////////////////////
//                                                                      //
//  description                                                         //
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//                                                                      //
//      The purpose of this fx is to mimc human eye, so there are no    //
//  extra sprits/flare/ghost present in complex lens set in camera lens //
//  systems, just a single sun glare cause by diffraction.              //
//                                                                      //
//      This file features dynamic effect, blinking, moire, spikes.etc  //
//  as Veeblix intended.                                                //
//                                                      kingeric1992    //
//////////////////////////////////////////////////////////////////////////
//                                                                      //
//  internal parameters, can be modified                                //
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//                                                                      //
//  place "//" before "#define" to disable specific feature entirely,   //
//  equivalent to setting effect intensity 0, but save some performance //
//  by skipping computation.                                            //
//                                                                      //
//  example:                                                            //
//      //#define example                                               //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

string Param00="++++Statics+++++";
float  FOV_Threshold      <string UIName="FOV Threshold";            int UIMin=0; int UIMax=180;> = {85};    //set to fov detection threshold. 
float  Glare_Intensity    <string UIName="Glare Intensity";                      float UIMin=0; > = {0.001};  //glare intensity
float  Glare_IntensityN = 0;
float  Glare_Scale1       <string UIName="Glare Scale 1st person";               float UIMin=0; > = {1.5};  //glare scale
float  Glare_Scale3       <string UIName="Glare Scale 3rd person";               float UIMin=0; > = {1.5};  //glare scale
float3 Glare_Tint         <string UIName="Glare Tint";                 string UIWidget="Color"; > = {1, 1, 1};//color tint
string Param01="+++++Dynamics+++++";
float  Moire_Vib_Frequency<string UIName="Moire Vib Frequency(Hz)";              float UIMin=0; > = {0.2};  //moire vibration frequency
float  Moire_Vib_Scale    <string UIName="Moire Vib Scale";                      float UIMin=0; > = {0.04}; //moire vibration scale
float  Moire_Offset       <string UIName="Moire Offset";                         float UIMin=0; > = {0.12}; //moire offset (screen scale)
float  Dynamic_Rotate_Mod <string UIName="Rotation Modifier";                    float UIMin=0; > = {0.8};  //rotate glare according to sun position
string Param02="++++Blinking+++++";
int    Blink_Axis         <string UIName="Blink Axis(\xB0)";          int UIMin=0; int UIMax=90;> = {0};    //Rotate blink axis
float  Blink_Frequency    <string UIName="Blink Frequency(Hz)";                  float UIMin=0; > = {0.2};  //Times per second
float  Blink_Timemod      <string UIName="Blink Speed";                          float UIMin=0; > = {75};   //blinking speed
int    Blink_AngleMax     <string UIName="Blink Starting Angle(\xB0)";int UIMin=0; int UIMax=90;> = {80};   //diffraction pattern maximum angle
int    Blink_AngleMin     <string UIName="Blink Ending Angle(\xB0)";  int UIMin=0; int UIMax=90;> = {20};   //diffraction pattern minimum angle
float  Blink_Angle_Width  <string UIName="Blink Angle Width";                    float UIMin=0; > = {1};    //diffraction pattern angle width
float  Blink_Intensity    <string UIName="Blink Intensity";                      float UIMin=0; > = {1};    //diffraction pattern intensity
string Param03="++++Spikes+++++";
float  Spike_Intensity    <string UIName="Spike Intensity";                      float UIMin=0; > = {1};    //Spike Intensity
float  Spike_Frequency    <string UIName="Spike Frequency";                      float UIMin=0; > = {1};    //Spike Frequency
float  Spike_Speed        <string UIName="Spike Speed";                          float UIMin=0; > = {1};    //Spike Speed
float  Spike_Width        <string UIName="Spike Width";                          float UIMin=0; > = {1};    //Spike Width
//////////////////////////////////////////////////////////////////////////
//  external parameters, do not modify                                  //
//////////////////////////////////////////////////////////////////////////

//  keyboard controlled temporary variables (in some versions exists in the config file).
//  Press and hold key 1,2,3...8 together with PageUp or PageDown to modify. By default all set to 1.0
float4  tempF1;                 //1,2,3,4
float4  tempF2;                 //5,6,7,8
float4  tempF3;                 //9,0
float   ENightDayFactor;
float4  ScreenSize;             //x=Width, y=1/Width, z=ScreenScaleY, w=1/ScreenScaleY
float4  Timer;                  //x=generic timer in range 0..1, period of 16777216 ms (4.6 hours), w=frame time elapsed (in seconds)
float   EAdaptiveQualityFactor; //changes in range 0..1, 0 means full quality, 1 lowest dynamic quality (0.33, 0.66 are limits for quality levels)
float4  LightParameters;        //xy=sun position on screen, w=visibility
float   FieldOfView;            //fov in degrees

//textures
texture2D texColor;             //enbsunsprite.bmp/tga/png, .rgb == glare, .a == unused
texture2D texMask;              //hdr color of sun masked by clouds or objects

sampler2D SamplerColor = sampler_state
{
    Texture   = <texColor>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = Clamp;
    AddressV  = Clamp;
    SRGBTexture=FALSE;
    MaxMipLevel=0;
    MipMapLodBias=0;
};

sampler2D SamplerMask = sampler_state
{
    Texture   = <texMask>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = Clamp;
    AddressV  = Clamp;
    SRGBTexture=FALSE;
    MaxMipLevel=0;
    MipMapLodBias=0;
};

//////////////////////////////////////////////////////////////////////////
//  Structures                                                          //
//////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT_POST
{
    float4 vpos     : POSITION;
    float2 txcoord  : TEXCOORD0;
};

struct VS_INPUT_POST
{
    float3 pos     : POSITION;
    float2 txcoord : TEXCOORD0;
};

//////////////////////////////////////////////////////////////////////////
// Funstions                                                            //
//////////////////////////////////////////////////////////////////////////

//convert Cartesian into Polar, theta in radians
float2  Polar(float2 coord)
{
    float   r   = length(coord);
    return  float2( r, ( r == 0)? 0 : atan2(coord.y, coord.x));//(r, theta), theta = [-pi, pi]
}

//////////////////////////////////////////////////////////////////////////
//  Shaders                                                             //
//////////////////////////////////////////////////////////////////////////


//VSparameter == moire vector.xy
VS_OUTPUT_POST  VS_Draw( VS_INPUT_POST IN, uniform float2 VSparameter)
{
    VS_OUTPUT_POST OUT;
	float   Glare_Scale      = (FieldOfView < FOV_Threshold)? Glare_Scale3 : Glare_Scale1;
    float4  pos = float4(IN.pos.xy * Glare_Scale, IN.pos.z, 1.0);
//moire starts
    pos.xy += VSparameter * Moire_Offset * (1 + Moire_Vib_Scale * sin(Timer.x * 16777.216 * 6.28 * Moire_Vib_Frequency));
//moire ends
    pos.y  *= ScreenSize.z;//screen ratio fix, output squre
    pos.xy += LightParameters.xy;
    OUT.vpos       = pos;
    OUT.txcoord.xy = IN.txcoord.xy;
    return OUT;
}

//Sun glare shader
float4  PS_Glare( VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
    float2 coord   = IN.txcoord.xy;
    float  sunmask = tex2D(SamplerMask, 0.5).x;
   // pow((sunmask * 1000), 3);//skip current pixel if sunmask < 0.002
	//sunmask = saturate(sunmask);
    float4 res     = tex2D(SamplerColor, coord);
//dynamic starts
    float2 rotate;
    sincos(length(LightParameters.xy) * Dynamic_Rotate_Mod, rotate.y, rotate.x);
    coord -= 0.5;
    res   += tex2D(SamplerColor, float2(dot(coord, rotate * float2(1, -1)), dot(coord, rotate.yx)) + 0.5);
//dynamic ends
    float visible = ((saturate(LightParameters.w)) + 1.0);
	clip (visible - 1.0000001);
	visible = saturate(visible);
	float intensite = lerp(Glare_Intensity, Glare_IntensityN, ENightDayFactor);
    res.rgb *= (visible) * sunmask * Glare_Intensity; //weight
    res.rgb *= Glare_Tint;//tint
    return res;
}

float4  PS_Blink( VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
    float2 coord   = IN.txcoord.xy;
    float  sunmask = tex2D(SamplerMask, 0.5).x;
    //pow((sunmask * 1000), 3);//skip current pixel if sunmask < 0.002
	//sunmask = saturate(sunmask);
    float4 res     = tex2D(SamplerColor, coord);
    float2 weight  = 0;
    coord = Polar(coord-0.5);
    coord.y += 3.1415926;

//spikes start
    float4 spike[6]=  //rotate frequency, contrast(widh), display frequency, display contrast
    {
        float4(0.025, 25, 0.23, 2),
        float4(0.033, 22, 0.31, 1.5),
        float4(0.041, 18, 0.27, 1.6),
        float4(-0.033, 28, 0.37, 1.4),
        float4(-0.023, 28, 0.47, 1.8),
        float4(-0.037, 30, 0.29, 1.2)
    };
    for(int i=0; i<6; i++)
    {
        float delta = abs(frac(spike[i].x * 16777.216 * Timer.x * Spike_Speed - coord.y / 6.28) - 0.5) * 2;//[0, 1]
        delta       = pow(delta, spike[i].y * Spike_Width) * saturate(1 - coord.x * 3);
        delta      *= cos(saturate((sin(Timer.x * 16777.216 * 6.28 * spike[i].z * Spike_Frequency) + 1) * spike[i].w) * 3.1415926) + 1;
        weight.x   += delta;
    }
//spike ends

//blinking start
    coord.y += Blink_Axis * 0.01745;
    float  timemod = saturate((sin(Timer.x * 16777.216 * 6.28 * Blink_Frequency) + 1) * Blink_Timemod);
    float2 angle   = lerp(Blink_AngleMin, Blink_AngleMax, timemod) * 0.0111;
    angle.y *= 0.333;
    angle   -= 1 - abs(frac(coord.y / 3.1415926) * 2 - 1);
    angle    = 1 - smoothstep(0, Blink_Angle_Width / 10, abs(angle));
    weight.y = (angle.x + angle.y) * (cos(timemod * 3.1415926) + 1);//weight
//blinking ends
    float visible = ((saturate(LightParameters.w)) + 1.0);
	clip (visible - 1.0000001);
	visible = saturate(visible);
	float intensite = lerp(Glare_Intensity, Glare_IntensityN, ENightDayFactor);
    res.rgb *= dot(weight, float2(Spike_Intensity, Blink_Intensity)) * smoothstep(0.05, 0.2, coord.x);
    res.rgb *= Glare_Tint * visible * sunmask * Glare_Intensity;// * LightParameters.w; //weight, tint
    return res;
}

//////////////////////////////////////////////////////////////////////////
//  passes                                                              //
//////////////////////////////////////////////////////////////////////////
technique Draw
{
    pass P0//Glare
    {

        VertexShader = compile vs_3_0 VS_Draw(float2(1, 0));
        PixelShader  = compile ps_3_0 PS_Glare();

        AlphaBlendEnable=TRUE;
        SrcBlend=ONE;
        DestBlend=ONE;

        DitherEnable=FALSE;
        ZEnable=FALSE;
        CullMode=NONE;
        ALPHATESTENABLE=FALSE;
        SEPARATEALPHABLENDENABLE=FALSE;
        StencilEnable=FALSE;
        FogEnable=FALSE;
        SRGBWRITEENABLE=FALSE;
    }

    pass P1//Glare
    {

        VertexShader = compile vs_3_0 VS_Draw(float2(-1, 0));
        PixelShader  = compile ps_3_0 PS_Glare();

        AlphaBlendEnable=TRUE;
        SrcBlend=ONE;
        DestBlend=ONE;

        DitherEnable=FALSE;
        ZEnable=FALSE;
        CullMode=NONE;
        ALPHATESTENABLE=FALSE;
        SEPARATEALPHABLENDENABLE=FALSE;
        StencilEnable=FALSE;
        FogEnable=FALSE;
        SRGBWRITEENABLE=FALSE;
    }
    pass P2//Glare
    {

        VertexShader = compile vs_3_0 VS_Draw(float2(0, -1));
        PixelShader  = compile ps_3_0 PS_Glare();

        AlphaBlendEnable=TRUE;
        SrcBlend=ONE;
        DestBlend=ONE;

        DitherEnable=FALSE;
        ZEnable=FALSE;
        CullMode=NONE;
        ALPHATESTENABLE=FALSE;
        SEPARATEALPHABLENDENABLE=FALSE;
        StencilEnable=FALSE;
        FogEnable=FALSE;
        SRGBWRITEENABLE=FALSE;
    }
    pass P3//Glare
    {

        VertexShader = compile vs_3_0 VS_Draw(float2(0, 1));
        PixelShader  = compile ps_3_0 PS_Glare();

        AlphaBlendEnable=TRUE;
        SrcBlend=ONE;
        DestBlend=ONE;

        DitherEnable=FALSE;
        ZEnable=FALSE;
        CullMode=NONE;
        ALPHATESTENABLE=FALSE;
        SEPARATEALPHABLENDENABLE=FALSE;
        StencilEnable=FALSE;
        FogEnable=FALSE;
        SRGBWRITEENABLE=FALSE;
    }
    pass P4//Blink
    {

        VertexShader = compile vs_3_0 VS_Draw(float2(0, 0));
        PixelShader  = compile ps_3_0 PS_Blink();

        AlphaBlendEnable=TRUE;
        SrcBlend=ONE;
        DestBlend=ONE;

        DitherEnable=FALSE;
        ZEnable=FALSE;
        CullMode=NONE;
        ALPHATESTENABLE=FALSE;
        SEPARATEALPHABLENDENABLE=FALSE;
        StencilEnable=FALSE;
        FogEnable=FALSE;
        SRGBWRITEENABLE=FALSE;
    }
    
    
}

