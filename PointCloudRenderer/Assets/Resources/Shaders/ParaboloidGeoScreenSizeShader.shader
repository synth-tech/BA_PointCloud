﻿
Shader "Custom/ParaboloidGeoScreenSizeShader"
{
	/*
	This shader renders the given vertices as circles with the given color.
	The point size is the radius of the circle given in WORLD COORDINATES
	Implemented using geometry shader
	*/
	Properties{
		_PointSize("Point Size", Float) = 5
		[Toggle] _Circles("Circles", Int) = 0
	}

	SubShader
	{
		LOD 200

		Pass
		{
			Cull off

			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			struct VertexInput
			{
				float4 position : POSITION;
				float4 color : COLOR;
			};

			struct VertexMiddle {
				float4 position : SV_POSITION;
				float4 color : COLOR;
				float size : POINTSIZE;
			};

			struct VertexOutput
			{
				float4 position : SV_POSITION;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			float _PointSize;
			int _ScreenWidth;
			int _ScreenHeight;
			float _FOV;
			int _Circles;
			float4x4 _InverseProjMatrix;

			VertexMiddle vert(VertexInput v) {
				VertexMiddle o;
				o.color = v.color;
				float4 viewpos = mul(UNITY_MATRIX_MV, v.position);
				o.position = mul(UNITY_MATRIX_P, viewpos);
				float slope = tan(_FOV / 2);
				o.size = _PointSize * slope * viewpos.z * 2 / _ScreenHeight;
				return o;
			}

			VertexOutput createParaboloidPoint(VertexMiddle input, float xsize, float ysize, float zsize, float u, float v) {
				VertexOutput nPoint;
				nPoint.position = input.position;
				nPoint.position.x += u*xsize*input.position.w;
				nPoint.position.y += v*ysize*input.position.w;
				nPoint.position /= nPoint.position.w;
				float4 viewposition = mul(_InverseProjMatrix, nPoint.position);
				viewposition /= viewposition.w;
				//viewposition givesalso the direction in which the object can be moved torwards the camera
				float4 vpn = float4(normalize(float3(viewposition.x, viewposition.y, viewposition.z)),0);
				viewposition += (1 - (u*u + v*v))*vpn*zsize;
				viewposition = mul(UNITY_MATRIX_P, viewposition);
				viewposition /= viewposition.w;
				nPoint.position = viewposition;
				nPoint.color = input.color;
				nPoint.uv = float2(u, v);
				return nPoint;
			}

			[maxvertexcount(68)]
			void geom(point VertexMiddle input[1], inout TriangleStream<VertexOutput> outputStream) {
				float xsize = _PointSize / _ScreenWidth;
				float ysize = _PointSize / _ScreenHeight;

				float sqr = sqrt(2) / 2;

				VertexOutput middle = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0, 0);
				//inner ring
				VertexOutput ir1 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0.25, 0);
				VertexOutput ir2 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, sqr*0.25, sqr*0.25);
				VertexOutput ir3 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0, 0.25);
				VertexOutput ir4 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -sqr*0.25, sqr*0.25);
				VertexOutput ir5 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -0.25, 0);
				VertexOutput ir6 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -sqr*0.25, -sqr*0.25);
				VertexOutput ir7 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0, -0.25);
				VertexOutput ir8 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, sqr*0.25, -sqr*0.25);
				//middle ring
				VertexOutput mr1 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0.5, 0);
				VertexOutput mr2 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, sqr*0.5, sqr*0.5);
				VertexOutput mr3 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0, 0.5);
				VertexOutput mr4 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -sqr*0.5, sqr*0.5);
				VertexOutput mr5 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -0.5, 0);
				VertexOutput mr6 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -sqr*0.5, -sqr*0.5);
				VertexOutput mr7 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0, -0.5);
				VertexOutput mr8 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, sqr*0.5, -sqr*0.5);
				//outer ring
				VertexOutput or1 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 1, 0);
				VertexOutput or2 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, sqr*1, sqr*1);
				VertexOutput or3 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0, 1);
				VertexOutput or4 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -sqr*1, sqr*1);
				VertexOutput or5 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -1, 0);
				VertexOutput or6 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -sqr*1, -sqr*1);
				VertexOutput or7 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 0, -1);
				VertexOutput or8 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, sqr*1, -sqr*1);
				//edges
				VertexOutput e11 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 1, 1);
				VertexOutput em11 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -1, 1);
				VertexOutput em1m1 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, -1, -1);
				VertexOutput e1m1 = createParaboloidPoint(input[0], xsize, ysize, input[0].size, 1, -1);
				
				//Create Triangles
				//Inner Circle
				outputStream.Append(ir1);
				outputStream.Append(middle);
				outputStream.Append(ir2);
				outputStream.Append(ir3);
				outputStream.RestartStrip();
				outputStream.Append(ir3);
				outputStream.Append(middle);
				outputStream.Append(ir4);
				outputStream.Append(ir5);
				outputStream.RestartStrip();
				outputStream.Append(ir5);
				outputStream.Append(middle);
				outputStream.Append(ir6);
				outputStream.Append(ir7);
				outputStream.RestartStrip();
				outputStream.Append(ir7);
				outputStream.Append(middle);
				outputStream.Append(ir8);
				outputStream.Append(ir1);
				outputStream.RestartStrip();
				////Middle Circle
				outputStream.Append(mr1);
				outputStream.Append(ir1);
				outputStream.Append(mr2);
				outputStream.Append(ir2);
				outputStream.Append(mr3);
				outputStream.Append(ir3);
				outputStream.Append(mr4);
				outputStream.Append(ir4);
				outputStream.Append(mr5);
				outputStream.Append(ir5);
				outputStream.Append(mr6);
				outputStream.Append(ir6);
				outputStream.Append(mr7);
				outputStream.Append(ir7);
				outputStream.Append(mr8);
				outputStream.Append(ir8);
				outputStream.Append(mr1);
				outputStream.Append(ir1);
				outputStream.RestartStrip();
				////Outer Circle
				outputStream.Append(or1);
				outputStream.Append(mr1);
				outputStream.Append(or2);
				outputStream.Append(mr2);
				outputStream.Append(or3);
				outputStream.Append(mr3);
				outputStream.Append(or4);
				outputStream.Append(mr4);
				outputStream.Append(or5);
				outputStream.Append(mr5);
				outputStream.Append(or6);
				outputStream.Append(mr6);
				outputStream.Append(or7);
				outputStream.Append(mr7);
				outputStream.Append(or8);
				outputStream.Append(mr8);
				outputStream.Append(or1);
				outputStream.Append(mr1);
				outputStream.RestartStrip();
				////Outer part
				outputStream.Append(or1);
				outputStream.Append(or2);
				outputStream.Append(e11);
				outputStream.Append(or3);
				outputStream.RestartStrip();
				outputStream.Append(or3);
				outputStream.Append(or4);
				outputStream.Append(em11);
				outputStream.Append(or5);
				outputStream.RestartStrip();
				outputStream.Append(or5);
				outputStream.Append(or6);
				outputStream.Append(em1m1);
				outputStream.Append(or7);
				outputStream.RestartStrip();
				outputStream.Append(or7);
				outputStream.Append(or8);
				outputStream.Append(e1m1);
				outputStream.Append(or1);
				outputStream.RestartStrip();
			}

			float4 frag(VertexOutput o) : COLOR{
				if (_Circles >= 0.5 && o.uv.x*o.uv.x + o.uv.y*o.uv.y > 1) {
					discard;
				}
				return o.color;
			}

			ENDCG
		}
	}
}
