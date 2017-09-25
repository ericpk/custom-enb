//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ENBSeries effect file
// visit http://enbdev.com for updates
// Copyright (c) 2007-2011 Boris Vorontsov
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 0915v2
// edited by gp65cj04
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++
//internal parameters, can be modified
//+++++++++++++++++++++++++++++
float   FOV_ThresholdCutoff
<
	string UIName="FOV Threshold Cutoff";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=180.0;
	float UIStep=0.1;
> = {60.0};
float   FOV_ThresholdDialogue
<
	string UIName="FOV Threshold Dialogue";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=180.0;
	float UIStep=0.1;
> = {65.0};
float   FOV_ThresholdCamera
<
	string UIName="FOV Threshold Camera";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=180.0;
	float UIStep=0.1;
> = {80.0};
float   Blur_ScaleDialogue
<
	string UIName="Blur Scale";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=16.0;
	float UIStep=0.1;
> = {4.0};
float   Blur_ScaleCamera
<
	string UIName="Blur Scale Camera";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=16.0;
	float UIStep=0.1;
> = {3.0};
float	FocalPlaneDepth
<
	string UIName="Focal Plane Depth";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=10.000;
	float UIStep=0.001;
> = {0.000};
float	FarBlurDepthDialogue
<
	string UIName="Far Blur Depth (Dialogue)";
	string UIWidget="Spinner";
	float UIMin=-1.000;
	float UIMax=10000.0;
	float UIStep=0.001;
> = {1000.0};
float	FarBlurDepth3rd
<
	string UIName="Far Blur Depth (3rd Person)";
	string UIWidget="Spinner";
	float UIMin=-1.000;
	float UIMax=10000.0;
	float UIStep=0.001;
> = {10.0};
float   FarBlurDepth1st
<
	string UIName="Far Blur Depth (1st Person)";
	string UIWidget="Spinner";
	float UIMin=-1.000;
	float UIMax=10000.0;
	float UIStep=0.001;
> = {-1.0};
// noise grain
float	NoiseAmount
<
	string UIName="Noise Amount";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=10.000;
	float UIStep=0.001;
> = {0.05};
float	NoiseCurve
<
	string UIName="Noise Curve";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=100.000;
	float UIStep=0.01;
> = {0.5};


//+++++++++++++++++++++++++++++
//external parameters, do not modify
//+++++++++++++++++++++++++++++
//keyboard controlled temporary variables (in some versions exists in the config file). Press and hold key 1,2,3...8 together with PageUp or PageDown to modify. By default all set to 1.0
float4 tempF1; //0,1,2,3
float4 tempF2; //5,6,7,8
float4 tempF3; //9,0
//x=Width, y=1/Width, z=ScreenScaleY, w=1/ScreenScaleY
float4 ScreenSize;
//x=generic timer in range 0..1, period of 16777216 ms (4.6 hours), w=frame time elapsed (in seconds)
float4 Timer;
//adaptation delta time for focusing
float FadeFactor;
float   FieldOfView;



//textures
texture2D texColor;
texture2D texDepth;
texture2D texNoise;
texture2D texCurr; //4*4 texture for focusing
texture2D texPrev; //4*4 texture for focusing

sampler2D SamplerColor = sampler_state
{
	Texture   = <texColor>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerDepth = sampler_state
{
	Texture   = <texDepth>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerNoise = sampler_state
{
	Texture   = <texNoise>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;//NONE;
	AddressU  = Wrap;
	AddressV  = Wrap;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

//for focus computation
sampler2D SamplerCurr = sampler_state
{
	Texture   = <texCurr>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

//for focus computation
sampler2D SamplerPrev = sampler_state
{
	Texture   = <texPrev>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

struct VS_OUTPUT_POST
{
	float4 vpos  : POSITION;
	float2 txcoord : TEXCOORD0;
};

struct VS_INPUT_POST
{
	float3 pos  : POSITION;
	float2 txcoord : TEXCOORD0;
};


////////////////////////////////////////////////////////////////////
//begin focusing code
////////////////////////////////////////////////////////////////////
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VS_OUTPUT_POST VS_Focus(VS_INPUT_POST IN)
{
	VS_OUTPUT_POST OUT;

	float4 pos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);

	OUT.vpos=pos;
	OUT.txcoord.xy=IN.txcoord.xy;

	return OUT;
}


float linearlizeDepth(float nonlinearDepth)
{
	float2 dofProj=float2(0.0509804, 3098.0392);
	float2 dofDist=float2(0.0, 0.0509804);
		
	float4 depth=nonlinearDepth;
	
	
	depth.y=-dofProj.x + dofProj.y;
	depth.y=1.0/depth.y;
	depth.z=depth.y * dofProj.y; 
	depth.z=depth.z * -dofProj.x; 
	depth.x=dofProj.y * -depth.y + depth.x;
	depth.x=1.0/depth.x;

	depth.y=depth.z * depth.x;

	depth.x=depth.z * depth.x - dofDist.y; 
	depth.x+=dofDist.x * -0.5;

	depth.x=max(depth.x, 0.0);
		
	return depth.x;
}


//SRCpass1X=ScreenWidth;
//SRCpass1Y=ScreenHeight;
//DESTpass2X=4;
//DESTpass2Y=4;
float4 PS_ReadFocus(VS_OUTPUT_POST IN) : COLOR
{
	float res = 0.0;
	if (FieldOfView < FOV_ThresholdCamera)
	{
		float2 uvsrc=(0.5, 0.5);
	
		float2 pixelSize=ScreenSize.y;
		pixelSize.y*=ScreenSize.z;
		
		const float2 offset[4]=
		{
			float2(0.0, 1.0),
			float2(0.0, -1.0),
			float2(1.0, 0.0),
			float2(-1.0, 0.0)
		};
	
		res=linearlizeDepth(tex2D(SamplerDepth, uvsrc.xy).x);
		for (int i=0; i<4; i++)
		{
			uvsrc.xy=uvsrc.xy;
			uvsrc.xy+=offset[i] * pixelSize.xy;


	
			res+=linearlizeDepth(tex2D(SamplerDepth, uvsrc).x);
	
		}
		res*=0.2;
	}

	

	return res;
}



//SRCpass1X=4;
//SRCpass1Y=4;
//DESTpass2X=4;
//DESTpass2Y=4;
float4 PS_WriteFocus(VS_OUTPUT_POST IN) : COLOR
{
	float res=0.0;
	if (FieldOfView < FOV_ThresholdCamera)
	{
		float2 uvsrc=(0.5, 0.5);

		float curr=tex2D(SamplerCurr, uvsrc.xy).x;
		float prev=tex2D(SamplerPrev, uvsrc.xy).x;

	
		res=lerp(prev, curr, saturate(FadeFactor));//time elapsed factor
	}

	return res;
}



//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


technique ReadFocus
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Focus();
		PixelShader  = compile ps_3_0 PS_ReadFocus();

		ZEnable=FALSE;
		CullMode=NONE;
		ALPHATESTENABLE=FALSE;
		SEPARATEALPHABLENDENABLE=FALSE;
		AlphaBlendEnable=FALSE;
		FogEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}



technique WriteFocus
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Focus();
		PixelShader  = compile ps_3_0 PS_WriteFocus();

		ZEnable=FALSE;
		CullMode=NONE;
		ALPHATESTENABLE=FALSE;
		SEPARATEALPHABLENDENABLE=FALSE;
		AlphaBlendEnable=FALSE;
		FogEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}

////////////////////////////////////////////////////////////////////
//end focusing code
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////



//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VS_OUTPUT_POST VS_PostProcess(VS_INPUT_POST IN)
{
	VS_OUTPUT_POST OUT;

	float4 pos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);

	OUT.vpos=pos;
	OUT.txcoord.xy=IN.txcoord.xy;

	return OUT;
}

float4 PS_ProcessPass1(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
	float4 res;
	float2 coord=IN.txcoord.xy;
	float4 origcolor=tex2D(SamplerColor, coord.xy);
	res = origcolor;
	if (FieldOfView < FOV_ThresholdCamera)
	{
		res.xyz=origcolor.xyz;
		float scenedepth=tex2D(SamplerDepth, IN.txcoord.xy).x;
		float depth=linearlizeDepth(scenedepth);
		float focalPlaneDepth=FocalPlaneDepth;
		float farBlurtemp= (FieldOfView < FOV_ThresholdDialogue)? FarBlurDepthDialogue : FarBlurDepth3rd;
		float farBlurDepth;
		if (FieldOfView > FOV_ThresholdCutoff)
			farBlurDepth = (FieldOfView < FOV_ThresholdCamera)? farBlurtemp : FarBlurDepth1st;
		else
			farBlurDepth = -1.0;
		if(depth < focalPlaneDepth)
			res.w=(depth - focalPlaneDepth)/focalPlaneDepth;
		else
		{
			res.w=(depth - focalPlaneDepth)/(farBlurDepth - focalPlaneDepth);
			res.w=saturate(res.w);
		}
		res.w=res.w * 0.5 + 0.5;
	}
	return res;
}

float4 PS_ProcessPass2(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
	float2 coord=IN.txcoord.xy;
	float4 origcolor=tex2D(SamplerColor, coord.xy);
	float4 res = origcolor;
	if (FieldOfView < FOV_ThresholdCamera)
	{
		float centerDepth=origcolor.w;
		float2 pixelSize=ScreenSize.y;
		pixelSize.y*=ScreenSize.z;
		float Blur_Scale = (FieldOfView < FOV_ThresholdDialogue)? Blur_ScaleDialogue : Blur_ScaleCamera;
		float blurAmount=abs(centerDepth * Blur_Scale - (Blur_Scale / 2));
		res.xyz=origcolor.xyz;
		res.w=centerDepth;
	}
	return res;
}

float4 PS_ProcessPass3(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{	
	float2 coord=IN.txcoord.xy;
	float4 origcolor=tex2D(SamplerColor, coord.xy);
	float4 res=origcolor;
	if (FieldOfView < FOV_ThresholdCamera)
	{
		
		float2 pixelSize=ScreenSize.y;
		pixelSize.y*=ScreenSize.z;
		
		float depth=origcolor.w;
		float Blur_Scale = (FieldOfView < FOV_ThresholdDialogue)? Blur_ScaleDialogue : Blur_ScaleCamera;
		float blurAmount=abs(depth * Blur_Scale - (Blur_Scale / 2));
		origcolor=tex2D(SamplerColor, coord.xy);
		origcolor.w=smoothstep(0.0, depth, origcolor.w);
		res.x=lerp(res.x, origcolor.x, origcolor.w);
		origcolor=tex2D(SamplerColor, coord.xy);
		origcolor.w=smoothstep(0.0, depth, origcolor.w);
		res.z=lerp(res.z, origcolor.z, origcolor.w);
	}
	return res;
}
float4 PS_ProcessPass4(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
	float2 coord=IN.txcoord.xy;
	float4 origcolor=tex2D(SamplerColor, coord.xy);
	float4 res = origcolor;
	if (FieldOfView < FOV_ThresholdCamera)
	{
		float2 pixelSize=ScreenSize.y;
		pixelSize.y*=ScreenSize.z;
		float depth=origcolor.w;
		float Blur_Scale = (FieldOfView < FOV_ThresholdDialogue)? Blur_ScaleDialogue : Blur_ScaleCamera;
		float blurAmount=abs(depth * Blur_Scale - (Blur_Scale / 2));
		float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
		res=origcolor * weight[0];
		for(int i=1; i < 5; i++)
		{
			res+=tex2D(SamplerColor, coord.xy + float2(i*pixelSize.x*blurAmount, 0)) * weight[i];
			res+=tex2D(SamplerColor, coord.xy - float2(i*pixelSize.x*blurAmount, 0)) * weight[i];
		}
		res.w=depth;
	}
	return res;
}

float4 PS_ProcessPass5(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
	float2 coord=IN.txcoord.xy;
	float4 origcolor=tex2D(SamplerColor, coord.xy);
	float4 res=origcolor;
	if (FieldOfView < FOV_ThresholdCamera)
	{
		float2 pixelSize=ScreenSize.y;
		pixelSize.y*=ScreenSize.z;
		float depth=origcolor.w;
		float Blur_Scale = (FieldOfView < FOV_ThresholdDialogue)? Blur_ScaleDialogue : Blur_ScaleCamera;
		float blurAmount=abs(depth * Blur_Scale - (Blur_Scale / 2));
		float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 
			0.0162162162};
		res=origcolor * weight[0];

		for(int i=1; i < 5; i++)
		{
			res+=tex2D(SamplerColor, coord.xy + float2(0, i*pixelSize.y*blurAmount)) * weight[i];
			res+=tex2D(SamplerColor, coord.xy - float2(0, i*pixelSize.y*blurAmount)) * weight[i];
		}
		float origgray=dot(res.xyz, 0.3333);
		origgray/=origgray + 1.0;
		coord.xy=IN.txcoord.xy*16.0 + origgray;
		float4 cnoi=tex2D(SamplerNoise, coord);
		float noiseAmount=NoiseAmount*pow(blurAmount, NoiseCurve);
		res=lerp(res, (cnoi.x+0.5)*res, noiseAmount*saturate(1.0-origgray*1.8));
		
		res.w=depth;
	}
	
	return res;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
technique PostProcess
{
	pass P0
	{

		VertexShader = compile vs_3_0 VS_PostProcess();
		PixelShader  = compile ps_3_0 PS_ProcessPass1();

		DitherEnable=FALSE;
		ZEnable=FALSE;
		CullMode=NONE;
		ALPHATESTENABLE=FALSE;
		SEPARATEALPHABLENDENABLE=FALSE;
		AlphaBlendEnable=FALSE;
		StencilEnable=FALSE;
		FogEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}



technique PostProcess2
{
	pass P0
	{

		VertexShader = compile vs_3_0 VS_PostProcess();
		PixelShader  = compile ps_3_0 PS_ProcessPass2();

		DitherEnable=FALSE;
		ZEnable=FALSE;
		CullMode=NONE;
		ALPHATESTENABLE=FALSE;
		SEPARATEALPHABLENDENABLE=FALSE;
		AlphaBlendEnable=FALSE;
		StencilEnable=FALSE;
		FogEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}


technique PostProcess3
{
	pass P0
	{

		VertexShader = compile vs_3_0 VS_PostProcess();
		PixelShader  = compile ps_3_0 PS_ProcessPass3();

		DitherEnable=FALSE;
		ZEnable=FALSE;
		CullMode=NONE;
		ALPHATESTENABLE=FALSE;
		SEPARATEALPHABLENDENABLE=FALSE;
		AlphaBlendEnable=FALSE;
		StencilEnable=FALSE;
		FogEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}

technique PostProcess4
{
	pass P0
	{

		VertexShader = compile vs_3_0 VS_PostProcess();
		PixelShader  = compile ps_3_0 PS_ProcessPass4();

		DitherEnable=FALSE;
		ZEnable=FALSE;
		CullMode=NONE;
		ALPHATESTENABLE=FALSE;
		SEPARATEALPHABLENDENABLE=FALSE;
		AlphaBlendEnable=FALSE;
		StencilEnable=FALSE;
		FogEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}

technique PostProcess5
{
	pass P0
	{

		VertexShader = compile vs_3_0 VS_PostProcess();
		PixelShader  = compile ps_3_0 PS_ProcessPass5();

		DitherEnable=FALSE;
		ZEnable=FALSE;
		CullMode=NONE;
		ALPHATESTENABLE=FALSE;
		SEPARATEALPHABLENDENABLE=FALSE;
		AlphaBlendEnable=FALSE;
		StencilEnable=FALSE;
		FogEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}












