/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#pragma once

#if defined(__APPLE__)

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <TargetConditionals.h>

#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
#define BF_VIDEO_FORMAT_YUV420 1
#else
#define BF_VIDEO_FORMAT_RGBA   1
#endif

#elif defined(__ANDROID__)

#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>

#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>

#define BF_VIDEO_FORMAT_NV21   1

#else

#define BF_VIDEO_FORMAT_RGBA   1

#endif

