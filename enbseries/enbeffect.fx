//++++++++++++++++++++++++++++++++++++++++++++
// ENBSeries effect file
// visit http://enbdev.com for updates
// Copyright (c) 2007-2013 Boris Vorontsov
// Nighteye code by scegielski http://www.nexusmods.com/skyrim/mods/50731/?
//++++++++++++++++++++++++++++++++++++++++++++

//use original game processing first, then mine
//#define APPLYGAMECOLORCORRECTION

//#define LETTERBOX_BARS      1   // Enable Matso's cinematic bars (black bars at top and bottom).

//  List of Camera States
// -1  = unknown
//  0  = first person
//  1  = auto vanity
//  2  = VATS
//  3  = free
//  4  = iron sights
//  5  = furniture
//  6  = transition
//  7  = tweenmenu
//  8  = third person 1
//  9  = third person 2
//  10 = horse
//  11 = bleedout
//  12 = dragon 

//set these to match to enbseries.ini [TIME OF DAY]
#define TOD_DAWN_DURATION   2.5
#define TOD_DUSK_DURATION   2.5
#define TOD_SUNRISE_TIME    8.5   
#define TOD_DAY_TIME        13
#define TOD_SUNSET_TIME     17.5
#define TOD_NIGHT_TIME      1.0

struct TM_FilmicALU_struct{float a, b, c, d, e, f, g, w;};

float4 TM_FlimicALU_func(float4 color, const TM_FilmicALU_struct i) {
    float4 l = max(color - i.g, 0.0);
    return pow(saturate( l*(i.a*l+i.b) / 
                       ( l*(i.c*l+i.d) + i.e)), i.f);
}

float3 TM_FilmicALU( float3 color, const TM_FilmicALU_struct i) { 
     float4 res = TM_FlimicALU_func(float4(color, i.w), i);
     return res.rgb/res.a;
}

// #########################
// BEGIN NIGHTEYE  UTILITIES
// #########################

// ##########################################
// INCLUDE ENHANCED ENB DIAGNOSTICS  HEADER
// ##########################################
#include "EnhancedENBDiagnostics.fxh"

	float3 RGBtoHSV(float3 c)
	{
		float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
		float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

		float d = q.x - min(q.w, q.y);
		float e = 1.0e-10;
		return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	float3 HSVtoRGB(float3 c)
	{
		float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
		return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
	}

	float randomNoise(in float3 uvw)
	{
		float3 noise = (frac(sin(dot(uvw ,float3(12.9898,78.233, 42.2442)*2.0)) * 43758.5453));
		return abs(noise.x + noise.y + noise.z) * 0.3333;
	}

	float linStep(float minVal, float maxVal, float t)
	{
		return saturate((t - minVal) / (maxVal - minVal));
	}
	
// #########################
// END NIGHTEYE  UTILITIES
// #########################

//+++++++++++++++++++++++++++++
//internal parameters, can be modified
//+++++++++++++++++++++++++++++

//--------------------------------------------------
// Exterior controls
// Day
/*
string Param00 = "+++++Camera State Control+++++";
int	CameraState
<
	string UIName="Camera Mode";
	int UIMin=-1;
	int UIMax=12;
> = {-1};
float FOVState
<
	string UIName="Field Of View";
	string UIWidget="Spinner";
	float UIMin=0;
	float UIMax=180.0;
	float UIStep=0.1;
> = {90};
float FOV_Threshold
<
	string UIName="FoV Threshold";
	string UIWidget="Spinner";
	float UIMin=0;
	float UIMax=180.0;
	float UIStep=0.1;
> = {75};
bool InvertThreshold < 
string UIName = "Invert Threshold"; 
> = {false};
*/
string Param01 = "+++++EXTERIOR DAY+++++";

float	AdaptationMin_ED
<
	string UIName="Adaptation Min Day";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
	float UIStep=0.00001;
> = {0.00038};

float	AdaptationMax_ED
<
	string UIName="Adaptation Max Day";
	string UIWidget="Spinner";
	float UIStep=0.0001;
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.042};

float	Gamma_ED
<
	string UIName="Gamma Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {1.38};

float	RedFilter_ED
<
	string UIName="Red Filter Day";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	GreenFilter_ED
<
	string UIName="Green Filter Day";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	BlueFilter_ED
<
	string UIName="Blue Filter Day";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatR_ED
<
	string UIName="Desat Red Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatG_ED
<
	string UIName="Desat Green Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.1};

float	DesatB_ED
<
	string UIName="Desat Blue Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.6};

float	IntensityContrast_ED
<
	string UIName="Intensity Contrast Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Saturation_ED
<
	string UIName="Saturation Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.7};

float	Brightness_ED
<
	string UIName="Brightness Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {0.15};

float	TM_aED
<
	string UIName="Tonemap Highlight Day";
	string UIWidget="Spinner";
> = {6.0};

float	TM_bED
<
	string UIName="Tonemap Midrange Day";
	string UIWidget="Spinner";
> = {1.5};

float	TM_dED
<
	string UIName="Tonemap Mid Limiter Day";
	string UIWidget="Spinner";
> = {2.6};

float	TM_eED
<
	string UIName="Tonemap Black Offset Day";
	string UIWidget="Spinner";
	float UIStep=0.0001;
> = {0.07};

float	TM_fED
<
	string UIName="Tonemap Gamma Day";
	string UIWidget="Spinner";
> = {2.25};

float	TM_wED
<
	string UIName="Tonemap Overexposure Day";
	string UIWidget="Spinner";
> = {8.0};

//--------------------------------------------------
// Night
string Param02 = "+++++EXTERIOR NIGHT+++++";

float	AdaptationMin_EN
<
	string UIName="Adaptation Min Night";
	string UIWidget="Spinner";
	float UIStep=0.0001;
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.0016};

float	AdaptationMax_EN
<
	string UIName="Adaptation Max Night";
	string UIWidget="Spinner";
	float UIStep=0.0001;
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.0026};

float	Gamma_EN
<
	string UIName="Gamma Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {1.25};

float	RedFilter_EN
<
	string UIName="Red Filter Night";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	GreenFilter_EN
<
	string UIName="Green Filter Night";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	BlueFilter_EN
<
	string UIName="Blue Filter Night";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatR_EN
<
	string UIName="Desat Red Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatG_EN
<
	string UIName="Desat Green Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.2};

float	DesatB_EN
<
	string UIName="Desat Blue Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.8};

float	IntensityContrast_EN
<
	string UIName="Intensity Contrast Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Saturation_EN
<
	string UIName="Saturation Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Brightness_EN
<
	string UIName="Brightness Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {0.15};

float	TM_aEN
<
	string UIName="Tonemap Highlight Night";
	string UIWidget="Spinner";
> = {6.2};

float	TM_bEN
<
	string UIName="Tonemap Midrange Night";
	string UIWidget="Spinner";
> = {0.5};

float	TM_dEN
<
	string UIName="Tonemap Mid Limiter Night";
	string UIWidget="Spinner";
> = {1.7};

float	TM_eEN
<
	string UIName="Tonemap Black Offset Night";
	string UIWidget="Spinner";
	float UIStep=0.0001;
> = {0.03};

float	TM_fEN
<
	string UIName="Tonemap Gamma Night";
	string UIWidget="Spinner";
> = {2.2};

float	TM_wEN
<
	string UIName="Tonemap Overexposure Night";
	string UIWidget="Spinner";
> = {8.0};

//--------------------------------------------------
// SUNRISE/SUNSET
string Param012 = "+++++EXTERIOR SUNRISE/SET+++++";

float	AdaptationMin_ES
<
	string UIName="Adaptation Min Sunrise/set";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
	float UIStep=0.00001;
> = {0.00038};

float	AdaptationMax_ES
<
	string UIName="Adaptation Max Sunrise/set";
	string UIWidget="Spinner";
	float UIStep=0.0001;
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.042};

float	Gamma_ES
<
	string UIName="Gamma Sunrise/set";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {1.38};

float	RedFilter_ES
<
	string UIName="Red Filter Sunrise/set";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	GreenFilter_ES
<
	string UIName="Green Filter Sunrise/set";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	BlueFilter_ES
<
	string UIName="Blue Filter Sunrise/set";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatR_ES
<
	string UIName="Desat Red Sunrise/set";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatG_ES
<
	string UIName="Desat Green Sunrise/set";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.1};

float	DesatB_ES
<
	string UIName="Desat Blue Sunrise/set";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.6};

float	IntensityContrast_ES
<
	string UIName="Intensity Contrast Sunrise/set";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Saturation_ES
<
	string UIName="Saturation Sunrise/set";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.7};

float	Brightness_ES
<
	string UIName="Brightness Sunrise/set";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {0.15};

float	TM_aES
<
	string UIName="Tonemap Highlight Sunrise/set";
	string UIWidget="Spinner";
> = {6.0};

float	TM_bES
<
	string UIName="Tonemap Midrange Sunrise/set";
	string UIWidget="Spinner";
> = {1.5};

float	TM_dES
<
	string UIName="Tonemap Mid Limiter Sunrise/set";
	string UIWidget="Spinner";
> = {2.6};

float	TM_eES
<
	string UIName="Tonemap Black Offset Sunrise/set";
	string UIWidget="Spinner";
	float UIStep=0.0001;
> = {0.07};

float	TM_fES
<
	string UIName="Tonemap Gamma Sunrise/set";
	string UIWidget="Spinner";
> = {2.25};

float	TM_wES
<
	string UIName="Tonemap Overexposure Sunrise/set";
	string UIWidget="Spinner";
> = {8.0};

//--------------------------------------------------
// DAWN/DUSK
string Param013 = "+++++EXTERIOR DAWN/DUSK+++++";

float	AdaptationMin_ET
<
	string UIName="Adaptation Min Dawn/Dusk";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
	float UIStep=0.00001;
> = {0.00038};

float	AdaptationMax_ET
<
	string UIName="Adaptation Max Dawn/Dusk";
	string UIWidget="Spinner";
	float UIStep=0.0001;
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.042};

float	Gamma_ET
<
	string UIName="Gamma Dawn/Dusk";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {1.38};

float	RedFilter_ET
<
	string UIName="Red Filter Dawn/Dusk";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	GreenFilter_ET
<
	string UIName="Green Filter Dawn/Dusk";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	BlueFilter_ET
<
	string UIName="Blue Filter Dawn/Dusk";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatR_ET
<
	string UIName="Desat Red Dawn/Dusk";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatG_ET
<
	string UIName="Desat Green Dawn/Dusk";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.1};

float	DesatB_ET
<
	string UIName="Desat Blue Dawn/Dusk";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.6};

float	IntensityContrast_ET
<
	string UIName="Intensity Contrast Dawn/Dusk";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Saturation_ET
<
	string UIName="Saturation Dawn/Dusk";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.7};

float	Brightness_ET
<
	string UIName="Brightness Dawn/Dusk";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {0.15};

float	TM_aET
<
	string UIName="Tonemap Highlight Dawn/Dusk";
	string UIWidget="Spinner";
> = {6.0};

float	TM_bET
<
	string UIName="Tonemap Midrange Dawn/Dusk";
	string UIWidget="Spinner";
> = {1.5};

float	TM_dET
<
	string UIName="Tonemap Mid Limiter Dawn/Dusk";
	string UIWidget="Spinner";
> = {2.6};

float	TM_eET
<
	string UIName="Tonemap Black Offset Dawn/Dusk";
	string UIWidget="Spinner";
	float UIStep=0.0001;
> = {0.07};

float	TM_fET
<
	string UIName="Tonemap Gamma Dawn/Dusk";
	string UIWidget="Spinner";
> = {2.25};

float	TM_wET
<
	string UIName="Tonemap Overexposure Dawn/Dusk";
	string UIWidget="Spinner";
> = {8.0};

// Interior day controls
string Param03 = "+++++INTERIOR DAY+++++";

float	AdaptationMin_ID
<
	string UIName="Adaptation Min Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.003};

float	AdaptationMax_ID
<
	string UIName="Adaptation Max Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.004};

float	Gamma_ID
<
	string UIName="Gamma Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {1.1};

float	RedFilter_ID
<
	string UIName="Red Filter Interior Day";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	GreenFilter_ID
<
	string UIName="Green Filter Interior Day";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	BlueFilter_ID
<
	string UIName="Blue Filter Interior Day";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatR_ID
<
	string UIName="Desat Red Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatG_ID
<
	string UIName="Desat Green Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.2};

float	DesatB_ID
<
	string UIName="Desat Blue Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.6};

float	IntensityContrast_ID
<
	string UIName="Intensity Contrast Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Saturation_ID
<
	string UIName="Saturation Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Brightness_ID
<
	string UIName="Brightness Interior Day";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {0.15};

float	TM_aID
<
	string UIName="Tonemap Highlight Interior Day";
	string UIWidget="Spinner";
> = {6.2};

float	TM_bID
<
	string UIName="Tonemap Midrange Interior Day";
	string UIWidget="Spinner";
> = {0.5};

float	TM_dID
<
	string UIName="Tonemap Mid Limiter Interior Day";
	string UIWidget="Spinner";
> = {1.7};

float	TM_eID
<
	string UIName="Tonemap Black Offset Interior Day";
	string UIWidget="Spinner";
	float UIStep=0.0001;
> = {0.03};

float	TM_fID
<
	string UIName="Tonemap Gamma Interior Day";
	string UIWidget="Spinner";
> = {2.2};

float	TM_wID
<
	string UIName="Tonemap Overexposure Interior Day";
	string UIWidget="Spinner";
> = {8.0};


// Interior night controls
string Param04 = "+++++INTERIOR NIGHT+++++";

float	AdaptationMin_IN
<
	string UIName="Adaptation Min Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.003};

float	AdaptationMax_IN
<
	string UIName="Adaptation Max Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.004};

float	Gamma_IN
<
	string UIName="Gamma Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {1.1};

float	RedFilter_IN
<
	string UIName="Red Filter Interior Night";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	GreenFilter_IN
<
	string UIName="Green Filter Interior Night";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	BlueFilter_IN
<
	string UIName="Blue Filter Interior Night";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatR_IN
<
	string UIName="Desat Red Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatG_IN
<
	string UIName="Desat Green Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.2};

float	DesatB_IN
<
	string UIName="Desat Blue Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.6};

float	IntensityContrast_IN
<
	string UIName="Intensity Contrast Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Saturation_IN
<
	string UIName="Saturation Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Brightness_IN
<
	string UIName="Brightness Interior Night";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {0.15};

float	TM_aIN
<
	string UIName="Tonemap Highlight Interior Night";
	string UIWidget="Spinner";
> = {6.2};

float	TM_bIN
<
	string UIName="Tonemap Midrange Interior Night";
	string UIWidget="Spinner";
> = {0.5};

float	TM_dIN
<
	string UIName="Tonemap Mid Limiter Interior Night";
	string UIWidget="Spinner";
> = {1.7};

float	TM_eIN
<
	string UIName="Tonemap Black Offset Interior Night";
	string UIWidget="Spinner";
	float UIStep=0.0001;
> = {0.03};

float	TM_fIN
<
	string UIName="Tonemap Gamma Interior Night";
	string UIWidget="Spinner";
> = {2.2};

float	TM_wIN
<
	string UIName="Tonemap Overexposure Interior Night";
	string UIWidget="Spinner";
> = {8.0};


// Dungeon day controls
string Param05 = "+++++DUNGEON+++++";

float	AdaptationMin_D
<
	string UIName="Adaptation Min Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.003};

float	AdaptationMax_D
<
	string UIName="Adaptation Max Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.000;
	float UIMax=1.0;
> = {0.004};

float	Gamma_D
<
	string UIName="Gamma Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {1.1};

float	RedFilter_D
<
	string UIName="Red Filter Dungeon";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	GreenFilter_D
<
	string UIName="Green Filter Dungeon";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	BlueFilter_D
<
	string UIName="Blue Filter Dungeon";
	string UIWidget="Spinner";
	float UIStep=0.001;
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatR_D
<
	string UIName="Desat Red Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	DesatG_D
<
	string UIName="Desat Green Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.2};

float	DesatB_D
<
	string UIName="Desat Blue Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.6};

float	IntensityContrast_D
<
	string UIName="Intensity Contrast Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Saturation_D
<
	string UIName="Saturation Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.3};

float	Brightness_D
<
	string UIName="Brightness Dungeon";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=5.0;
> = {0.15};

float	TM_aD
<
	string UIName="Tonemap Highlight Dungeon";
	string UIWidget="Spinner";
> = {6.2};

float	TM_bD
<
	string UIName="Tonemap Midrange Dungeon";
	string UIWidget="Spinner";
> = {0.5};

float	TM_dD
<
	string UIName="Tonemap Mid Limiter Dungeon";
	string UIWidget="Spinner";
> = {1.7};

float	TM_eD
<
	string UIName="Tonemap Black Offset Dungeon";
	string UIWidget="Spinner";
	float UIStep=0.0001;
> = {0.03};

float	TM_fD
<
	string UIName="Tonemap Gamma Dungeon";
	string UIWidget="Spinner";
> = {2.2};

float	TM_wD
<
	string UIName="Tonemap Overexposure Dungeon";
	string UIWidget="Spinner";
> = {8.0};


//------------------------------------
//prod80 color filter parameters start
//------------------------------------

string Param07 = "+++++COLOR FILTER+++++";

bool use_colorhuefx <
   string UIName="Enable Color Filter";
   //Enable - Disable effect
> = {true};
bool use_colorsaturation <
   string UIName="Color Filter: Use Orig. Saturation";
   //The above will use original color saturation as an added limiter to the strength of the effect
> = {false};
float hueMid <
   string UIName="Color Filter: Hue Middle";
   //Set the middle Hue value, which is the most intense represented
   string UIWidget="Spinner";
   float UIMin=0.0;
   float UIMax=1.0;
   float UIStep=0.001;
> = {0.5};
float hueRange <
   string UIName="Color Filter: Hue Range";
   //Set the range to which the Hue should extend in either direction
   string UIWidget="Spinner";
   float UIMin=0.0;
   float UIMax=1.0;
   float UIStep=0.001;
> = {0.2};
float satLimit <
   string UIName="Color Filter: Saturation Limit";
   //Limit the resulting color saturation
   string UIWidget="Spinner";
   float UIMin=0.0;
   float UIMax=1.0;
   float UIStep=0.001;
> = {1.0};
float fxcolorMixD <
   string UIName="Color Filter: Effect Strength Day";
   //Interpolation between the original and the effect
   string UIWidget="Spinner";
   float UIMin=0.0;
   float UIMax=1.0;
   float UIStep=0.001;
> = {1.0};
float fxcolorMixN <
   string UIName="Color Filter: Effect Strength Night";
   //Interpolation between the original and the effect
   string UIWidget="Spinner";
   float UIMin=0.0;
   float UIMax=1.0;
   float UIStep=0.001;
> = {1.0};
float fxcolorMixI <
   string UIName="Color Filter: Effect Strength Interior";
   //Interpolation between the original and the effect
   string UIWidget="Spinner";
   float UIMin=0.0;
   float UIMax=1.0;
   float UIStep=0.001;
> = {1.0};
//------------------------------------
//prod80 color filter parameters end
//------------------------------------

/*
string Param08 = "+++++Night Eye+++++";
// ##########################
// BEGIN NIGHTEYE  PARAMETERS
// ##########################
	// #### GENERAL PARAMETERS ####
		bool nightEyeEnable <
		    string UIName = "Night Eye Enable";
		> = {true};

	// #### CALIBRATION PARAMETERS ####
		// #### Calibrate PARAMETERS ####
		bool nightEyeCalibrate <
		    string UIName = "Night Eye Calibrate";
		> = {false};

		float	nightEyeDayMult
		<
		    string UIName="Night Eye Day";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		    float UIStep=0.01;
		> = {0.25};

		float	nightEyeDayOffset
		<
		    string UIName="Night Eye Day Offset";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		    float UIStep=0.01;
		> = {-1.0};

		float	nightEyeNightMult
		<
		    string UIName="Night Eye Night";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		    float UIStep=0.01;
		> = {1.34};

		float	nightEyeNightOffset
		<
		    string UIName="Night Eye Night Offset";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		    float UIStep=0.01;
		> = {-1.0};

		float	nightEyeInteriorMult
		<
		    string UIName="Night Eye Interior";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		    float UIStep=0.01;
		> = {1.34};

		float	nightEyeInteriorOffset
		<
		    string UIName="Night Eye Interior Offset";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		    float UIStep=0.01;
		> = {-1.0};

	// #### VIGNETTE PARAMETERS ####
		bool nightEyeVignetteEnable <
		    string UIName = "Night Eye Vignette Enable";
		> = {false};

		float	nightEyeVignetteMinDistance
		<
		    string UIName="Night Eye Vignette Min Distance";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {0.5};

		float	nightEyeVignetteMaxDistance
		<
		    string UIName="Night Eye Vignette Max Distance";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {0.9};

		float	nightEyeVignetteDistancePower
		<
		    string UIName="Night Eye Vignette Distance Power";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {1.5};

		float	nightEyeVignetteAspectRatio
		<
		    string UIName="Night Eye Vignette Aspect Ratio Power";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {1.0};

	// #### COLOR CORRECT PARAMETERS ####
		bool nightEyeCCEnable <
		    string UIName = "Night Eye CC Enable";
		> = {true};

		float	nightEyeGamma
		<
		    string UIName="Night Eye Gamma";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {0.5};

		float	nightEyeHueShift
		<
		    string UIName="Night Eye Hue Shift";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		> = {0.25};

		float	nightEyeHueSpeed
		<
		    string UIName="Night Eye Hue Speed";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		> = {0.0};

		float	nightEyeSaturationMult
		<
		    string UIName="Night Eye Saturation";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {0.0};

		float	nightEyeValueMult
		<
		    string UIName="Night Eye Value";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		> = {0.5};

		float3	nightEyeTint <
		    string UIName="Night Eye Tint";
		    string UIWidget="Color";
		> = {1.0, 1.0, 1.0};

		float	nightEyeVignetteValueMult
		<
		    string UIName="Night Eye Vignette Value Mult";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		> = {0.0};

		float	nightEyeVignetteMaskMult
		<
		    string UIName="Night Eye Vignette Mask Mult";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		> = {1.0};

	// #### BLOOM PARAMETERS ####
		bool nightEyeBloomEnable <
		    string UIName = "Night Eye Bloom Enable";
		> = {true};

		float	nightEyeBloomGamma
		<
		    string UIName="Night Eye Bloom Gamma";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {1.0};

		float	nightEyeBloomHueShift
		<
		    string UIName="Night Eye Bloom Hue Shift";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		> = {0.5};

		float	nightEyeBloomHueSpeed
		<
		    string UIName="Night Eye Bloom Hue Speed";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		> = {0.0};

		float	nightEyeBloomSaturationMult
		<
		    string UIName="Night Eye Bloom Saturation";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {1.0};

		float	nightEyeBloomValueMult
		<
		    string UIName="Night Eye Bloom Value";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		> = {20.0};

		float3	nightEyeBloomTint <
		    string UIName="Night Eye Bloom Tint";
		    string UIWidget="Color";
		> = {1.0, 1.0, 1.0};

		float	nightEyeBloomVignetteMult
		<
		    string UIName="Night Eye Bloom Vignette Mult";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		> = {1.0};

		float	nightEyeBloomVignetteMaskMult
		<
		    string UIName="Night Eye Bloom Vignette Mask Mult";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		> = {1.0};


	// #### NOISE PARAMETERS ####
		bool nightEyeNoiseEnable <
		    string UIName = "Night Eye Noise Enable";
		> = {true};

		float	nightEyeNoiseMult
		<
		    string UIName="Night Eye Noise Mult";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		> = {0.15};

		float3	nightEyeNoiseTint <
		    string UIName="Night Eye Noise Tint";
		    string UIWidget="Color";
		> = {1.0, 1.0, 1.0};

		float	nightEyeNoiseVignetteMult
		<
		    string UIName="Night Eye Noise Vignette Mult";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=100.0;
		> = {1.0};

		float	nightEyeNoiseVignetteMaskMult
		<
		    string UIName="Night Eye Noise Vignette Mask Mult";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		> = {1.0};

	// #### WARP PARAMETERS ####
		bool nightEyeWarpEnable <
		    string UIName = "Night Eye Warp Enable";
		> = {false};

		float	nightEyeWarpMult
		<
		    string UIName="Night Eye Warp Mult";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		> = {25.0};

		float	nightEyeWarpShift
		<
		    string UIName="Night Eye Warp Shift";
		    string UIWidget="Spinner";
		    float UIMin=-100.0;
		    float UIMax=100.0;
		> = {-0.05};

		float	nightEyeWarpMinDistance
		<
		    string UIName="Night Eye Warp Min Distance";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {0.4};

		float	nightEyeWarpMaxDistance
		<
		    string UIName="Night Eye Warp Max Distance";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {1.0};

		float	nightEyeWarpDistancePower
		<
		    string UIName="Night Eye Warp Distance Power";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {1.75};

		float	nightEyeWarpAspectRatio
		<
		    string UIName="Night Eye Warp Aspect Ratio Power";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {1.0};
	// #### Eyes PARAMETERS ####
		bool nightEyeEnableEyes <
		    string UIName = "Night Eye Enable Eyes";
		> = {false};

		float	nightEyeEyesSeparation
		<
		    string UIName="Night Eye Eyes Separation";
		    string UIWidget="Spinner";
		    float UIMin=0.0;
		    float UIMax=10.0;
		> = {0.35};
*/
// ##########################
// END NIGHTEYE  PARAMETERS
// ##########################
/*
//--------------------------------------------------
string Param09 = "+++++Procedural Correction+++++";
//parameters for ldr color correction, if enabled
float	ECCGamma
<
	string UIName="CC: Gamma";
	string UIWidget="Spinner";
	float UIMin=0.2;//not zero!!!
	float UIMax=5.0;
> = {1.0};

float	ECCInBlack
<
	string UIName="CC: In black";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.0};

float	ECCInWhite
<
	string UIName="CC: In white";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	ECCOutBlack
<
	string UIName="CC: Out black";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.0};

float	ECCOutWhite
<
	string UIName="CC: Out white";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {1.0};

float	ECCBrightness
<
	string UIName="CC: Brightness";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.0};

float	ECCContrastGrayLevel
<
	string UIName="CC: Contrast gray level";
	string UIWidget="Spinner";
	float UIMin=0.01;
	float UIMax=0.99;
> = {0.5};

float	ECCContrast
<
	string UIName="CC: Contrast";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.0};

float	ECCSaturation
<
	string UIName="CC: Saturation";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=10.0;
> = {1.0};

float	ECCDesaturateShadows
<
	string UIName="CC: Desaturate shadows";
	string UIWidget="Spinner";
	float UIMin=0.0;
	float UIMax=1.0;
> = {0.0};

float3	ECCColorBalanceShadows <
	string UIName="CC: Color balance shadows";
	string UIWidget="Color";
> = {0.5, 0.5, 0.5};

float3	ECCColorBalanceHighlights <
	string UIName="CC: Color balance highlights";
	string UIWidget="Color";
> = {0.5, 0.5, 0.5};

float3	ECCChannelMixerR <
	string UIName="CC: Channel mixer R";
	string UIWidget="Color";
> = {1.0, 0.0, 0.0};

float3	ECCChannelMixerG <
	string UIName="CC: Channel mixer G";
	string UIWidget="Color";
> = {0.0, 1.0, 0.0};

float3	ECCChannelMixerB <
	string UIName="CC: Channel mixer B";
	string UIWidget="Color";
> = {0.0, 0.0, 1.0};
*/

//+++++++++++++++++++++++++++++
//external parameters, do not modify
//+++++++++++++++++++++++++++++
//keyboard controlled temporary variables (in some versions exists in the config file). Press and hold key 1,2,3...8 together with PageUp or PageDown to modify. By default all set to 1.0
float4	tempF1; //0,1,2,3
float4	tempF2; //5,6,7,8
float4	tempF3; //9,0
//x=generic timer in range 0..1, period of 16777216 ms (4.6 hours), w=frame time elapsed (in seconds)
float4	Timer;
//x=Width, y=1/Width, z=ScreenScaleY, w=1/ScreenScaleY
float4	ScreenSize;
//changes in range 0..1, 0 means that night time, 1 - day time
float	ENightDayFactor;
//changes 0 or 1. 0 means that exterior, 1 - interior
float	EInteriorFactor;
//changes in range 0..1, 0 means full quality, 1 lowest dynamic quality (0.33, 0.66 are limits for quality levels)
float	EAdaptiveQualityFactor;
//.x - current weather index, .y - outgoing weather index, .z - weather transition, .w - time of the day in 24 standart hours. Weather index is value from _weatherlist.ini, for example WEATHER002 means index==2, but index==0 means that weather not captured.
float4	WeatherAndTime;
//enb version of bloom applied, ignored if original post processing used
float	EBloomAmount;

texture2D texs0;//color
texture2D texs1;//bloom skyrim
texture2D texs2;//adaptation skyrim
texture2D texs3;//bloom enb
texture2D texs4;//adaptation enb
texture2D texs7;//palette enb

sampler2D _s0 = sampler_state
{
	Texture   = <texs0>;
	MinFilter = POINT;//
	MagFilter = POINT;//
	MipFilter = NONE;//LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s1 = sampler_state
{
	Texture   = <texs1>;
	MinFilter = LINEAR;//
	MagFilter = LINEAR;//
	MipFilter = NONE;//LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s2 = sampler_state
{
	Texture   = <texs2>;
	MinFilter = LINEAR;//
	MagFilter = LINEAR;//
	MipFilter = NONE;//LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s3 = sampler_state
{
	Texture   = <texs3>;
	MinFilter = LINEAR;//
	MagFilter = LINEAR;//
	MipFilter = NONE;//LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s4 = sampler_state
{
	Texture   = <texs4>;
	MinFilter = LINEAR;//
	MagFilter = LINEAR;//
	MipFilter = NONE;//LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s7 = sampler_state
{
	Texture   = <texs7>;
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
	float2 txcoord0 : TEXCOORD0;
};
struct VS_INPUT_POST
{
	float3 pos  : POSITION;
	float2 txcoord0 : TEXCOORD0;
};

/////////////////////
////Begin prod80 code
/////////////////////			
		
	float grayValue(float3 gv)
{
   return dot( gv, float3(0.2125, 0.7154, 0.0721) );
}

float smootherstep(float edge0, float edge1, float x)
{
   x = clamp((x - edge0)/(edge1 - edge0), 0.0, 1.0);
   return x*x*x*(x*(x*6 - 15) + 10);
}

float Hue(float3 color)
{
   float hue = 0.0f;
   float fmin = min(min(color.r, color.g), color.b);
   float fmax = max(max(color.r, color.g), color.b);
   float delta = fmax - fmin;
   
   if (delta == 0.0)
      hue = 0.0;
   else
   {         
      float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
      float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
      float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;

      if (color.r == fmax )
         hue = deltaB - deltaG;
      else if (color.g == fmax)
         hue = (1.0 / 3.0) + deltaR - deltaB;
      else if (color.b == fmax)
         hue = (2.0 / 3.0) + deltaG - deltaR;
   }
      
   if (hue < 0.0)
      hue += 1.0f;
   else if (hue > 1.0)
      hue -= 1.0f;
   return hue;
}
///////////////////
////End prod80 code
///////////////////


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VS_OUTPUT_POST VS_Quad(VS_INPUT_POST IN)
{
	VS_OUTPUT_POST OUT;

	OUT.vpos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);

	OUT.txcoord0.xy=IN.txcoord0.xy;

	return OUT;
}

//skyrim shader specific externals, do not modify
float4	_c1 : register(c1);
float4	_c2 : register(c2);
float4	_c3 : register(c3);
float4	_c4 : register(c4);
float4	_c5 : register(c5);

#define TOD_DAWN_TIME       (TOD_SUNRISE_TIME - 0.5 * TOD_DAWN_DURATION)
#define TOD_DUSK_TIME       (TOD_SUNSET_TIME  + 0.5 * TOD_DUSK_DURATION)

struct TODstruct { float dawn, sunrise, day, sunset, dusk, night; };

TODstruct TOD()
{
    TODstruct o;
    
    float2 quad = { step(WeatherAndTime.w, TOD_DAY_TIME), step(TOD_DAWN_TIME, WeatherAndTime.w) * step(WeatherAndTime.w, TOD_DUSK_TIME)};
    float  tmp  = quad.x > 0.5 ? TOD_SUNRISE_TIME: TOD_SUNSET_TIME;
    
    o.dawn    = max(1.0 - abs((WeatherAndTime.w - TOD_DAWN_TIME)/(0.5 * TOD_DAWN_DURATION)),0.0);
    o.day     = pow(saturate((tmp - WeatherAndTime.w)/(tmp - TOD_DAY_TIME)), 0.6);
    o.dusk    = max(1.0 - abs((WeatherAndTime.w - TOD_DUSK_TIME)/(0.5 * TOD_DUSK_DURATION)),0.0);
    o.sunrise = max(quad.x * quad.y - (o.day + o.dawn), 0.0);
    o.sunset  = max((1.0 - quad.x) * quad.y - (o.day + o.dusk), 0.0);
    o.night   = max((1.0 - quad.y) - (o.dusk + o.dawn), 0.0);
    
    return o;
}

/// Time and Location separation for ENBSeries v0.117 to current version, using "Hack" value to allow Dungeon separated control values.
/// Only functional if using ELE - Lite or ELE - Interior Lighting!
float3 DNEIDFactor(float3 EXTDAY, float3 EXTNIGHT, float3 INTDAY, float3 INTNIGHT, float3 DUNGEON)
{
    if (EInteriorFactor == 1.0 && _c3.z == 1.000001) // Imagespace Brightness "hack" value
    {
        return DUNGEON;
    }
    else if (EInteriorFactor == 1.0) // 
    {
        return lerp(INTNIGHT, INTDAY, ENightDayFactor);
    }
    else
    {
        return lerp(EXTNIGHT, EXTDAY, ENightDayFactor);
    }
}

float3 TODIEDFactor(float3 DAWN, float3 SUNRISE, float3 DAY, float3 SUNSET, float3 DUSK, float3 NIGHT, float3 INTDAY, float3 INTNIGHT, float3 DUNGEON)
{
    if (EInteriorFactor == 1.0 && _c3.z == 1.000001) // Imagespace Brightness "hack" value
    {
        return DUNGEON;
    }
    else if (EInteriorFactor == 1.0) // 
    {
        return lerp(INTNIGHT, INTDAY, ENightDayFactor);
    }
    else
    {
        return (DAWN * TOD().dawn + SUNRISE * TOD().sunrise + DAY * TOD().day + SUNSET * TOD().sunset + DUSK * TOD().dusk + NIGHT * TOD().night);
    }
}

// ALU noise in Next-gen post processing in COD:AW 
float InterleavedGradientNoise( float2 uv )
{
    float3 magic = { 0.06711056, 0.00583715, 52.9829189 };
    return frac( magic.z * frac( dot( uv, magic.xy ) ) );
}

float4 PS_D6EC7DD1(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
	float4 _oC0=0.0; //output

	float4 _c6=float4(0, 0, 0, 0);
	float4 _c7=float4(0.212500006, 0.715399981, 0.0720999986, 1.0);

	float4 r0;
	float4 r1;
	float4 r2;
	float4 r3;
	float4 r4;
	float4 r5;
	float4 r6;
	float4 r7;
	float4 r8;
	float4 r9;
	float4 r10;
	float4 r11;

	float4 _v0=0.0;
		
	_v0.xy=IN.txcoord0.xy;
	
	/*
	
	// ################################## //
		// BEGIN NIGHT EYE SETUP AND WARPING     //
		// ################################## //
		float2 unwarpedTxCoord = _v0.xy;

		// The _c3.w value is from the game needs to be manipulated as
		// below to get a value from 0 (night eye off) to 1 (night eye on).
		// The Day, Night, and Interior GUI controls can be used to tune this.
		float3 nightEyeDayFactor = clamp(_c3.w + nightEyeDayOffset, 0.0, 1.0) * nightEyeDayMult;
		float3 nightEyeNightFactor = clamp(_c3.w + nightEyeNightOffset, 0.0, 1.0) * nightEyeNightMult;
		float3 nightEyeInteriorFactor = clamp(_c3.w + nightEyeInteriorOffset, 0.0, 1.0) * nightEyeInteriorMult;

		// Interpolate night/day/interior
		float nightEyeT;
		nightEyeT = nightEyeDayFactor * ENightDayFactor + 
			nightEyeNightFactor * (1.0 - ENightDayFactor);
		nightEyeT = nightEyeInteriorFactor * EInteriorFactor + 
			nightEyeT * (1.0 - EInteriorFactor);
		float aspectRatio = ScreenSize.z;

		float2 warpVector;
		[branch] if(nightEyeEnable && nightEyeWarpEnable) // Warp
		{
			float2 warpedTxCoord = IN.txcoord0.xy;
			float2 center = float2(0.5, 0.5);
			float2 txCorrected = float2((warpedTxCoord.x - center.x) * 
				aspectRatio / nightEyeWarpAspectRatio + center.x, warpedTxCoord.y);
			float dist;
			[branch]if(nightEyeEnableEyes) // Eyes (2 centers)
			{
				float2 leftEyeCenter = float2(center.x - nightEyeEyesSeparation / 2.0, center.y);
				float2 rightEyeCenter = float2(center.x + nightEyeEyesSeparation / 2.0, center.y);
				float leftEyeDist = distance(txCorrected, leftEyeCenter);
				float rightEyeDist = distance(txCorrected, rightEyeCenter);
				float leftEyeDistT = linStep(nightEyeWarpMinDistance, nightEyeWarpMaxDistance, leftEyeDist);
				float rightEyeDistT = linStep(nightEyeWarpMinDistance, nightEyeWarpMaxDistance, rightEyeDist);
				if(leftEyeDist < rightEyeDist){
					dist = leftEyeDist;
					warpVector = (txCorrected - leftEyeCenter) / leftEyeDist;
				}
				else
				{
					dist = rightEyeDist;
					warpVector = (txCorrected - rightEyeCenter) / rightEyeDist;
				}
			}
			else
			{ 
				dist = distance(txCorrected, center);
				warpVector = (txCorrected - center) / dist;
			}

			float distT = linStep(nightEyeWarpMinDistance, nightEyeWarpMaxDistance, dist);
			distT = pow(distT, nightEyeWarpDistancePower);
			warpedTxCoord += nightEyeT * nightEyeWarpMult * -0.05 * 
				(distT + nightEyeWarpShift * 0.1) * warpVector;

			// Mirror and wrap if warped beyond screen border
			warpedTxCoord = fmod(abs(warpedTxCoord), 2.0);
			if(warpedTxCoord.x > 1.0) warpedTxCoord.x = warpedTxCoord.x - 2.0 * (warpedTxCoord.x - 1.0);
			if(warpedTxCoord.y > 1.0) warpedTxCoord.y = warpedTxCoord.y - 2.0 * (warpedTxCoord.y - 1.0);

			_v0.xy = warpedTxCoord.xy;
		}
		// ################################ //
		// END NIGHT EYE SETUP AND WARPING  //
		// ################################ //
		
	*/


	r1=tex2D(_s0, _v0.xy); //color

	//apply bloom
	float4	xcolorbloom=tex2D(_s3, _v0.xy);

	xcolorbloom.xyz=xcolorbloom-r1;
	xcolorbloom.xyz=max(xcolorbloom, 0.0);
	r1.xyz+=xcolorbloom*EBloomAmount;

	r11=r1; //my bypass
	_oC0.xyz=r1.xyz; //for future use without game color corrections

#ifdef APPLYGAMECOLORCORRECTION
	//apply original
    r0.x=1.0/_c2.y;
    r1=tex2D(_s2, _v0);
    r0.yz=r1.xy * _c1.y;
    r0.w=1.0/r0.y;
    r0.z=r0.w * r0.z;
    r1=tex2D(_s0, _v0);
    r1.xyz=r1 * _c1.y;
    r0.w=dot(_c7.xyz, r1.xyz);
    r1.w=r0.w * r0.z;
    r0.z=r0.z * r0.w + _c7.w;
    r0.z=1.0/r0.z;
    r0.x=r1.w * r0.x + _c7.w;
    r0.x=r0.x * r1.w;
    r0.x=r0.z * r0.x;
    if (r0.w<0) r0.x=_c6.x;
    r0.z=1.0/r0.w;
    r0.z=r0.z * r0.x;
    r0.x=saturate(-r0.x + _c2.x);
//    r2=tex2D(_s3, _v0);//enb bloom
    r2=tex2D(_s1, _v0);//skyrim bloom
    r2.xyz=r2 * _c1.y;
    r2.xyz=r0.x * r2;
    r1.xyz=r1 * r0.z + r2;
    r0.x=dot(r1.xyz, _c7.xyz);
    r1.w=_c7.w;
    r2=lerp(r0.x, r1, _c3.x);
    r1=r0.x * _c4 - r2;
    r1=_c4.w * r1 + r2;
    r1=_c3.w * r1 - r0.y; //khajiit night vision _c3.w
    r0=_c3.z * r1 + r0.y;
    r1=-r0 + _c5;
    _oC0=_c5.w * r1 + r0;

#endif //APPLYGAMECOLORCORRECTION

/*
#ifndef APPLYGAMECOLORCORRECTION
//temporary fix for khajiit night vision, but it also degrade colors.
//	r1=tex2D(_s2, _v0);
//	r0.y=r1.xy * _c1.y;
	r1=_oC0;
	r1.xyz=r1 * _c1.y;
	r0.x=dot(r1.xyz, _c7.xyz);
	r2=lerp(r0.x, r1, _c3.x);
	r1=r0.x * _c4 - r2;
	r1=_c4.w * r1 + r2;
	r1=_c3.w * r1;// - r0.y;
	r0=_c3.z * r1;// + r0.y;
	r1=-r0 + _c5;
	_oC0=_c5.w * r1 + r0;
#endif //!APPLYGAMECOLORCORRECTION
*/

	float4 color=_oC0;	
	

    //adaptation in time
	float4	Adaptation=tex2D(_s4, 0.5);
	float	grayadaptation=max(max(Adaptation.x, Adaptation.y), Adaptation.z);
	/*

    float Gamma=DNEIDFactor(Gamma_ED, Gamma_EN, Gamma_ID, Gamma_IN, Gamma_D);
    float RedFilter=DNEIDFactor(RedFilter_ED, RedFilter_EN, RedFilter_ID, RedFilter_IN, RedFilter_D);
    float GreenFilter=DNEIDFactor(GreenFilter_ED, GreenFilter_EN, GreenFilter_ID, GreenFilter_IN, GreenFilter_D);
    float BlueFilter=DNEIDFactor(BlueFilter_ED, BlueFilter_EN, BlueFilter_ID, BlueFilter_IN, BlueFilter_D);
	
	float DesatR=DNEIDFactor(DesatR_ED, DesatR_EN, DesatR_ID, DesatR_IN, DesatR_D);
	float DesatG=DNEIDFactor(DesatG_ED, DesatG_EN, DesatG_ID, DesatG_IN, DesatG_D);
	float DesatB=DNEIDFactor(DesatB_ED, DesatB_EN, DesatB_ID, DesatB_IN, DesatB_D);
	
	float AdaptationMin=DNEIDFactor(AdaptationMin_ED, AdaptationMin_EN, AdaptationMin_ID, AdaptationMin_IN, AdaptationMin_D);
	float AdaptationMax=DNEIDFactor(AdaptationMax_ED, AdaptationMax_EN, AdaptationMax_ID, AdaptationMax_IN, AdaptationMax_D);
	
    float Saturation=DNEIDFactor(Saturation_ED, Saturation_EN, Saturation_ID, Saturation_IN, Saturation_D);
	float IntensityContrast=DNEIDFactor(IntensityContrast_ED, IntensityContrast_EN, IntensityContrast_ID, IntensityContrast_IN, IntensityContrast_D);
	float Brightness=DNEIDFactor(Brightness_ED, Brightness_EN, Brightness_ID, Brightness_IN, Brightness_D);
	
	float TM_a=DNEIDFactor(TM_aED, TM_aEN, TM_aID, TM_aIN, TM_aD);
	float TM_b=DNEIDFactor(TM_bED, TM_bEN, TM_bID, TM_bIN, TM_bD);
	float TM_d=DNEIDFactor(TM_dED, TM_dEN, TM_dID, TM_dIN, TM_dD);
	float TM_e=DNEIDFactor(TM_eED, TM_eEN, TM_eID, TM_eIN, TM_eD);
	float TM_f=DNEIDFactor(TM_fED, TM_fEN, TM_fID, TM_fIN, TM_fD);
	float TM_w=DNEIDFactor(TM_wED, TM_wEN, TM_wID, TM_wIN, TM_wD);
	*/
	
	float Gamma=TODIEDFactor(Gamma_ET, Gamma_ES, Gamma_ED, Gamma_ES, Gamma_ET, Gamma_EN, Gamma_ID, Gamma_IN, Gamma_D);
    float RedFilter=TODIEDFactor(RedFilter_ET, RedFilter_ES, RedFilter_ED, RedFilter_ES, RedFilter_ET, RedFilter_EN, RedFilter_ID, RedFilter_IN, RedFilter_D);
    float GreenFilter=TODIEDFactor(GreenFilter_ET, GreenFilter_ES, GreenFilter_ED, GreenFilter_ES, GreenFilter_ET, GreenFilter_EN, GreenFilter_ID, GreenFilter_IN, GreenFilter_D);
    float BlueFilter=TODIEDFactor(BlueFilter_ET, BlueFilter_ES, BlueFilter_ED, BlueFilter_ES, BlueFilter_ET, BlueFilter_EN, BlueFilter_ID, BlueFilter_IN, BlueFilter_D);
	
	float DesatR=TODIEDFactor(DesatR_ET, DesatR_ES, DesatR_ED, DesatR_ES, DesatR_ET, DesatR_EN, DesatR_ID, DesatR_IN, DesatR_D);
	float DesatG=TODIEDFactor(DesatG_ET, DesatG_ES, DesatG_ED, DesatG_ES, DesatG_ET, DesatG_EN, DesatG_ID, DesatG_IN, DesatG_D);
	float DesatB=TODIEDFactor(DesatB_ET, DesatB_ES, DesatB_ED, DesatB_ES, DesatB_ET, DesatB_EN, DesatB_ID, DesatB_IN, DesatB_D);
	
	float AdaptationMin=TODIEDFactor(AdaptationMin_ET, AdaptationMin_ES, AdaptationMin_ED, AdaptationMin_ES, AdaptationMin_ET, AdaptationMin_EN, AdaptationMin_ID, AdaptationMin_IN, AdaptationMin_D);
	float AdaptationMax=TODIEDFactor(AdaptationMax_ET, AdaptationMax_ES, AdaptationMax_ED, AdaptationMax_ES, AdaptationMax_ET, AdaptationMax_EN, AdaptationMax_ID, AdaptationMax_IN, AdaptationMax_D);
	
    float Saturation=TODIEDFactor(Saturation_ET, Saturation_ES, Saturation_ED, Saturation_ES, Saturation_ET, Saturation_EN, Saturation_ID, Saturation_IN, Saturation_D);
	float IntensityContrast=TODIEDFactor(IntensityContrast_ET, IntensityContrast_ES, IntensityContrast_ED, IntensityContrast_ES, IntensityContrast_ET, IntensityContrast_EN, IntensityContrast_ID, IntensityContrast_IN, IntensityContrast_D);
	float Brightness=TODIEDFactor(Brightness_ET, Brightness_ES, Brightness_ED, Brightness_ES, Brightness_ET, Brightness_EN, Brightness_ID, Brightness_IN, Brightness_D);
	
	float TM_a=TODIEDFactor(TM_aET, TM_aES, TM_aED, TM_aES, TM_aET, TM_aEN, TM_aID, TM_aIN, TM_aD);
	float TM_b=TODIEDFactor(TM_bET, TM_bES, TM_bED, TM_bES, TM_bET, TM_bEN, TM_bID, TM_bIN, TM_bD);
	float TM_d=TODIEDFactor(TM_dET, TM_dES, TM_dED, TM_dES, TM_dET, TM_dEN, TM_dID, TM_dIN, TM_dD);
	float TM_e=TODIEDFactor(TM_eET, TM_eES, TM_eED, TM_eES, TM_eET, TM_eEN, TM_eID, TM_eIN, TM_eD);
	float TM_f=TODIEDFactor(TM_fET, TM_fES, TM_fED, TM_fES, TM_fET, TM_fEN, TM_fID, TM_fIN, TM_fD);
	float TM_w=TODIEDFactor(TM_wET, TM_wES, TM_wED, TM_wES, TM_wET, TM_wEN, TM_wID, TM_wIN, TM_wD);
	
    float fxcolorMix=lerp(lerp(fxcolorMixN, fxcolorMixD, ENightDayFactor), fxcolorMixI, EInteriorFactor);
	
	
	
	float greyscale = dot(color.xyz, float3(0.3, 0.59, 0.11));
    color.r = lerp(greyscale, color.r, DesatR);
    color.g = lerp(greyscale, color.g, DesatG);
    color.b = lerp(greyscale, color.b, DesatB);	
    	
	color = pow(color, Gamma);
	
	color.r = pow(color.r, RedFilter);
	color.g = pow(color.g, GreenFilter);
	color.b = pow(color.b, BlueFilter);
   
	grayadaptation=max(grayadaptation, 0.0); //0.0
	grayadaptation=min(grayadaptation, 50.0); //50.0
	//float adaptFactor = saturate(pow(1 - grayadaptation*2, 2));
	//IntensityContrast = lerp(IntensityContrastMin, IntensityContrastMax, adaptFactor);
	color.xyz=color.xyz/(grayadaptation*AdaptationMax+AdaptationMin);//*tempF1.x

	color.xyz*=Brightness;
	color.xyz+=0.000001;
	float3 xncol=normalize(color.xyz);
	float3 scl=color.xyz/xncol.xyz;
	scl=pow(scl, IntensityContrast);
	xncol.xyz=pow(xncol.xyz, Saturation);
	color.xyz=scl*xncol.xyz;

	//float	lumamax=ToneMappingOversaturation;
	//color.xyz=(color.xyz * (1.0 + color.xyz/lumamax))/(color.xyz + ToneMappingCurve);
	
    //float4 tone = (0,0,0,0);
    //tone = pow(saturate(tone*(6.2*tone + 0.5) / ( tone*(6.2*tone + 1.7) + 0.06)), 2.2);
    //color.xyz = tone.xyz/tone.w;//color.xyz = tone.xyz / tone.w;
	
	TM_FilmicALU_struct TM_Struct = {TM_a, TM_b, TM_a, TM_d, TM_e, TM_f, 0.0, TM_w};
	
    color.rgb = TM_FilmicALU(color.rgb, TM_Struct);
	
    float Y = dot(color.xyz, float3(0.299, 0.587, 0.114)); //0.299 * R + 0.587 * G + 0.114 * B;
	float U = dot(color.xyz, float3(-0.14713, -0.28886, 0.436)); //-0.14713 * R - 0.28886 * G + 0.436 * B;
	float V = dot(color.xyz, float3(0.615, -0.51499, -0.10001)); //0.615 * R - 0.51499 * G - 0.10001 * B;	
	
	//Y=pow(Y, BrightnessCurve);
	//Y=Y*BrightnessMultiplier;
	//Y=Y/(Y+BrightnessToneMappingCurve);
	//float	desaturatefact=saturate(Y*Y*Y*1.7);
	//U=lerp(U, 0.0, desaturatefact);
	//V=lerp(V, 0.0, desaturatefact);
	//color.xyz=V * float3(1.13983, -0.58060, 0.0) + U * float3(0.0, -0.39465, 2.03211) + Y;
	
	// ADVANCED COLOR FILTER (prod80)

if ( use_colorhuefx == true )
{
   float3 fxcolor = saturate( color.xyz );
   float greyVal = grayValue( fxcolor.xyz );
   float colorHue = Hue( fxcolor.xyz );
   
   float colorSat = 0.0f;
   float minColor = min( min ( fxcolor.x, fxcolor.y ), fxcolor.z );
   float maxColor = max( max ( fxcolor.x, fxcolor.y ), fxcolor.z );
   float colorDelta = maxColor - minColor;
   float colorInt = ( maxColor + minColor ) * 0.5f;
   
   if ( colorDelta != 0.0f )
   {
      if ( colorInt < 0.5f )
         colorSat = colorDelta / ( maxColor + minColor );
      else
         colorSat = colorDelta / ( 2.0f - maxColor - minColor );
   }
   
   //When color intensity not based on original saturation level
   if ( use_colorsaturation == false )
      colorSat = 1.0f;
   
   float hueMin_1 = 0.0f;
   float hueMin_2 = 0.0f;
   float hueMax_1 = 0.0f;
   float hueMax_2 = 0.0f;
   
   if ( hueRange > hueMid )
   {
      hueMin_1 = hueMid - hueRange;
      hueMin_2 = 1.0f + hueMid - hueRange;
      hueMax_1 = hueMid + hueRange;
      hueMax_2 = 1.0f + hueMid;
   
      if ( colorHue >= hueMin_1 && colorHue <= hueMid )
         fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_1, hueMid, colorHue ) * ( colorSat * satLimit ));
      else if ( colorHue > hueMid && colorHue <= hueMax_1 )
         fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, ( 1.0f - smootherstep( hueMid, hueMax_1, colorHue )) * ( colorSat * satLimit ));
      else if ( colorHue >= hueMin_2 && colorHue <= hueMax_2 )
         fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_2, hueMax_2, colorHue ) * ( colorSat * satLimit ));
      else
         fxcolor.xyz = greyVal.xxx;
   
   }
   else if ( hueMid + hueRange > 1.0f )
   {
      hueMin_1 = hueMid - hueRange;
      hueMin_2 = 0.0f - ( 1.0f - hueMid );
      hueMax_1 = hueMid + hueRange;
      hueMax_2 = hueMid + hueRange - 1.0f;
   
      if ( colorHue >= hueMin_1 && colorHue <= hueMid )
         fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_1, hueMid, colorHue ) * ( colorSat * satLimit ));
      else if ( colorHue > hueMid && colorHue <= hueMax_1 )
         fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, ( 1.0f - smootherstep( hueMid, hueMax_1, colorHue )) * ( colorSat * satLimit ));
      else if ( colorHue >= hueMin_2 && colorHue <= hueMax_2 )
         fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_2, hueMax_2, colorHue) * ( colorSat * satLimit ));
      else
         fxcolor.xyz = greyVal.xxx;
      
   }
   else
   {
      hueMin_1 = hueMid - hueRange;
      hueMax_1 = hueMid + hueRange;
      
      if ( colorHue >= hueMin_1 && colorHue <= hueMid )
         fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, smootherstep( hueMin_1, hueMid, colorHue ) * ( colorSat * satLimit ));
      else if ( colorHue > hueMid && colorHue <= hueMax_1 )
         fxcolor.xyz = lerp( greyVal.xxx, fxcolor.xyz, ( 1.0f - smootherstep( hueMid, hueMax_1, colorHue )) * ( colorSat * satLimit ));
      else
         fxcolor.xyz = greyVal.xxx;
   
   }
   color.xyz = lerp( color.xyz, fxcolor.xyz, fxcolorMix );
}
		

	//color.xyz=max(color.xyz, 0.0);
	//color.xyz=color.xyz/(color.xyz+newEBrightnessToneMappingCurveV2);


//color.xyz=tex2D(_s0, _v0.xy) + xcolorbloom.xyz*float3(0.7, 0.6, 1.0)*0.5;
//color.xyz=tex2D(_s0, _v0.xy) + xcolorbloom.xyz*float3(0.7, 0.6, 1.0)*0.5;
//color.xyz*=0.7;


	//pallete texture (0.082+ version feature)
#ifdef E_CC_PALETTE   
	color.rgb=saturate(color.rgb);
	float3	brightness=Adaptation.xyz;//tex2D(_s4, 0.5);//adaptation luminance
//	brightness=saturate(brightness);//old version from ldr games
	brightness=(brightness/(brightness+1.0));//new version
	brightness=max(brightness.x, max(brightness.y, brightness.z));//new version
	float3	palette;
	float4	uvsrc=0.0;
	uvsrc.y=brightness.r;
	uvsrc.x=color.r;
	palette.r=tex2Dlod(_s7, uvsrc).r;
	uvsrc.x=color.g;
	uvsrc.y=brightness.g;
	palette.g=tex2Dlod(_s7, uvsrc).g;
	uvsrc.x=color.b;
	uvsrc.y=brightness.b;
	palette.b=tex2Dlod(_s7, uvsrc).b;
	color.rgb=palette.rgb;
#endif //E_CC_PALETTE

/*

#ifdef E_CC_PROCEDURAL
	float	tempgray;
	float4	tempvar;
	float3	tempcolor;

	//+++ levels like in photoshop, including gamma, lightness, additive brightness
	color=max(color-ECCInBlack, 0.0) / max(ECCInWhite-ECCInBlack, 0.0001);
	if (ECCGamma!=1.0) color=pow(color, ECCGamma);
	color=color*(ECCOutWhite-ECCOutBlack) + ECCOutBlack;

	//+++ brightness
	color=color*ECCBrightness;

	//+++ contrast
	color=(color-ECCContrastGrayLevel) * ECCContrast + ECCContrastGrayLevel;

	//+++ saturation
	tempgray=dot(color, 0.3333);
	color=lerp(tempgray, color, ECCSaturation);

	//+++ desaturate shadows
	tempgray=dot(color, 0.3333);
	tempvar.x=saturate(1.0-tempgray);
	tempvar.x*=tempvar.x;
	tempvar.x*=tempvar.x;
	color=lerp(color, tempgray, ECCDesaturateShadows*tempvar.x);

	//+++ color balance
	color=saturate(color);
	tempgray=dot(color, 0.3333);
	float2	shadow_highlight=float2(1.0-tempgray, tempgray);
	shadow_highlight*=shadow_highlight;
	color.rgb+=(ECCColorBalanceHighlights*2.0-1.0)*color * shadow_highlight.x;
	color.rgb+=(ECCColorBalanceShadows*2.0-1.0)*(1.0-color) * shadow_highlight.y;

	//+++ channel mixer
	tempcolor=color;
	color.r=dot(tempcolor, ECCChannelMixerR);
	color.g=dot(tempcolor, ECCChannelMixerG);
	color.b=dot(tempcolor, ECCChannelMixerB);
#endif //E_CC_PROCEDURAL
*/

/*
		// ##############################
	// BEGIN NIGHTEYE  IMPLEMENTATION
	// ##############################
	if(nightEyeEnable)
	{
		float vignette = 0.0;
		if(nightEyeVignetteEnable) //  Add Vignette
		{
			float2 vignetteTxCoord = IN.txcoord0.xy;
			float2 center = float2(0.5, 0.5);
			float2 txCorrected = float2((vignetteTxCoord.x - center.x) * 
				aspectRatio / nightEyeVignetteAspectRatio + center.x, vignetteTxCoord.y);
			float dist;
			[branch]if(nightEyeEnableEyes) // Eyes (2 centers)
			{
				float2 leftEyeCenter = float2(center.x - nightEyeEyesSeparation / 2.0, center.y);
				float2 rightEyeCenter = float2(center.x + nightEyeEyesSeparation / 2.0, center.y);
				float leftEyeDist = distance(txCorrected, leftEyeCenter);
				float rightEyeDist = distance(txCorrected, rightEyeCenter);
				dist = min(leftEyeDist, rightEyeDist);
			}
			else
			{ 
				dist = distance(txCorrected, center);
			}
			float distT = linStep(nightEyeVignetteMinDistance, nightEyeVignetteMaxDistance, dist);
			vignette = pow(distT, nightEyeVignetteDistancePower);
		}

		if(nightEyeCCEnable) // Color Correct
		{
			float3 nightEye = color.xyz;
			nightEye = pow(nightEye, nightEyeGamma);
			nightEye = RGBtoHSV(nightEye);
			nightEye.x += nightEyeHueShift + nightEyeHueSpeed * Timer.x * 1000.0;
			nightEye.y *= nightEyeSaturationMult;
			nightEye.z *= nightEyeValueMult;
			nightEye = HSVtoRGB(nightEye);
			nightEye *= nightEyeTint;
			float mask = vignette;
			if(nightEyeVignetteMaskMult < 0) mask = -1.0 * (1.0 - vignette);
			mask *= nightEyeVignetteMaskMult;
			nightEye *= (1.0 - mask) + (mask * nightEyeVignetteValueMult);
			color.xyz = saturate((nightEye.xyz * nightEyeT) + (color.xyz * (1.0 - nightEyeT)));
			//color.xyz = lerp(color.xyz, nightEye.xyz, t);
		}
		
		if(nightEyeBloomEnable) // Add Bloom
		{
			float3 nightEyeBloom = tex2D(_s3, _v0);
			nightEyeBloom = pow(nightEyeBloom, nightEyeBloomGamma);
			nightEyeBloom = RGBtoHSV(nightEyeBloom);
			nightEyeBloom.x += nightEyeBloomHueShift + nightEyeBloomHueSpeed * Timer.x * 1000.0;
			nightEyeBloom.y *= nightEyeBloomSaturationMult;
			nightEyeBloom.z *= nightEyeBloomValueMult;
			nightEyeBloom = HSVtoRGB(nightEyeBloom);
			nightEyeBloom *= nightEyeBloomTint;
			float mask = vignette;
			if(nightEyeBloomVignetteMaskMult < 0) mask = -1.0 * (1.0 - vignette);
			mask *= nightEyeBloomVignetteMaskMult;
			nightEyeBloom *= (1.0 - mask) + (mask * nightEyeBloomVignetteMult);
			nightEyeBloom *= nightEyeT;
			color.xyz= saturate(color.xyz + nightEyeBloom.xyz);
		}
		
		if(nightEyeNoiseEnable) //  Add Noise
		{
			float3 noiseCoord = float3(_v0.x, _v0.y, Timer.x);
			float3 nightEyeNoise = randomNoise(noiseCoord);
			nightEyeNoise *= nightEyeNoiseMult;
			nightEyeNoise *= nightEyeNoiseTint;
			float mask = vignette;
			if(nightEyeNoiseVignetteMaskMult < 0) mask = -1.0 * (1.0 - vignette);
			mask *= nightEyeNoiseVignetteMaskMult;
			nightEyeNoise *= mask + ((1.0 - mask) * nightEyeNoiseVignetteMult);
			nightEyeNoise *= nightEyeT;
			color.xyz = saturate(color.xyz + nightEyeNoise.xyz);
		}
		if(nightEyeCalibrate) //  Calibrate
		{

			float2 calibrateCoords = IN.txcoord0;
			float4 calibrateText = 0;
			calibrateText += float4(1.0, 1.0, 0.0, 1.0) *
				EED_drawFloatText(
				//ASCII N   i    g    h
				float4(78, 105, 103, 104),  	
				// ACII t    E   y    e
				float4(116, 69, 121, 101),  	
				nightEyeT,
				calibrateCoords,
				float2(0.85, 0),
				1.2,
				6 // precision
			);

			calibrateText += EED_drawFloatText(
				//ASCII N   i    g    h
				float4(78, 105, 103, 104),  	
				// ACII t    D   a    y
				float4(116, 68, 97, 121),  	
				ENightDayFactor,
				calibrateCoords,
				float2(0.85, 0.05),
				1.0,
				6 // precision
			);

			calibrateText += EED_drawFloatText(
				//ASCII I   n    t    e
				float4(73, 110, 116, 101),  	
				// ACII r    i   o    r
				float4(114, 105, 111, 114),  	
				EInteriorFactor,
				calibrateCoords,
				float2(0.85, 0.075),
				1.0,
				6 // precision
			);

			calibrateText += EED_drawCRegistersText(_c1, _c2, _c3, _c4, _c5, 
				calibrateCoords, float2(0.85, 0.125), 1.0, 6);

			color.xyz += calibrateText.xyz;
		}
		
	}
	// ##############################
	// END NIGHTEYE  IMPLEMENTATION
	// ##############################
*/
    float3 spellfx = -color.xyz + _c5.xyz;
    color.xyz = _c5.w * spellfx.xyz + color.xyz;

	float dither_amp = 1.0;
    float noise = lerp(-0.5, 0.5, InterleavedGradientNoise( vPos )) * dither_amp;
    color.xyz = pow(color.xyz, 1.0/2.2);
    color.xyz = color.xyz + noise * min(color.xyz + 0.5 * pow(1.0/255.0, 2.2), 0.75 * (pow(256.0/255.0, 2.2) - 1.0));
    color.xyz = pow(color.xyz, 2.2);	


	_oC0.w=1.0;
	_oC0.xyz=color.xyz;
	

	return _oC0;	
}


//switch between vanilla and mine post processing
technique Shader_D6EC7DD1 <string UIName="ENBSeries";>
{
	pass p0
	{
		VertexShader  = compile vs_3_0 VS_Quad();
		PixelShader  = compile ps_3_0 PS_D6EC7DD1();

		ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
		ZEnable=FALSE;
		ZWriteEnable=FALSE;
		CullMode=NONE;
		AlphaTestEnable=FALSE;
		AlphaBlendEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}



//original shader of post processing
technique Shader_ORIGINALPOSTPROCESS <string UIName="Vanilla";>
{
	pass p0
	{
		VertexShader  = compile vs_3_0 VS_Quad();
		PixelShader=
	asm
	{
// Parameters:
//   sampler2D Avg;
//   sampler2D Blend;
//   float4 Cinematic;
//   float4 ColorRange;
//   float4 Fade;
//   sampler2D Image;
//   float4 Param;
//   float4 Tint;
// Registers:
//   Name         Reg   Size
//   ------------ ----- ----
//   ColorRange   c1       1
//   Param        c2       1
//   Cinematic    c3       1
//   Tint         c4       1
//   Fade         c5       1
//   Image        s0       1
//   Blend        s1       1
//   Avg          s2       1
//s0 bloom result
//s1 color
//s2 is average color

    ps_3_0
    def c6, 0, 0, 0, 0
    //was c0 originally
    def c7, 0.212500006, 0.715399981, 0.0720999986, 1
    dcl_texcoord v0.xy
    dcl_2d s0
    dcl_2d s1
    dcl_2d s2
    rcp r0.x, c2.y
    texld r1, v0, s2
    mul r0.yz, r1.xxyw, c1.y
    rcp r0.w, r0.y
    mul r0.z, r0.w, r0.z
    texld r1, v0, s1
    mul r1.xyz, r1, c1.y
    dp3 r0.w, c7, r1
    mul r1.w, r0.w, r0.z
    mad r0.z, r0.z, r0.w, c7.w
    rcp r0.z, r0.z
    mad r0.x, r1.w, r0.x, c7.w
    mul r0.x, r0.x, r1.w
    mul r0.x, r0.z, r0.x
    cmp r0.x, -r0.w, c6.x, r0.x
    rcp r0.z, r0.w
    mul r0.z, r0.z, r0.x
    add_sat r0.x, -r0.x, c2.x
    texld r2, v0, s0
    mul r2.xyz, r2, c1.y
    mul r2.xyz, r0.x, r2
    mad r1.xyz, r1, r0.z, r2
    dp3 r0.x, r1, c7
    mov r1.w, c7.w
    lrp r2, c3.x, r1, r0.x
    mad r1, r0.x, c4, -r2
    mad r1, c4.w, r1, r2
    mad r1, c3.w, r1, -r0.y
    mad r0, c3.z, r1, r0.y
    add r1, -r0, c5
    mad oC0, c5.w, r1, r0
	};
		ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
		ZEnable=FALSE;
		ZWriteEnable=FALSE;
		CullMode=NONE;
		AlphaTestEnable=FALSE;
		AlphaBlendEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
    }
}

