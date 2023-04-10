/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#ifndef _BINARYVR_BINARYFACE_H_
#define _BINARYVR_BINARYFACE_H_

#ifndef _WIN32
#  ifndef BINARYFACE_API
#    define BINARYFACE_API __attribute__((visibility("default")))
#  endif // BINARYFACE_API
#else
#  ifndef BINARYFACE_API
#    define BINARYFACE_API __declspec(dllimport)
#  endif // BINARYFACE_API
#endif // _WIN32

/**
 *  BinaryFace API version 0.3
 */
#include <stdint.h>

#define BINARYFACE_SDK_VERSION 0x0003

#ifndef BINARYFACE_API
#  define BINARYFACE_API extern
#endif // BINARYFACE_API

typedef enum _binaryface_pixel_format {
  BINARYFACE_PIXEL_FORMAT_GRAY        = 0,  //  8 bits per pixel.
                                            //  The Y channel of NV21 video frame is also okay.

  BINARYFACE_PIXEL_FORMAT_RGBA        = 1,  //  32 bits per pixel
  BINARYFACE_PIXEL_FORMAT_BGRA        = 2,  //

  BINARYFACE_PIXEL_FORMAT_RGB         = 3,  //  24 bits per pixel
  BINARYFACE_PIXEL_FORMAT_BGR         = 4   //
} binaryface_pixel_format;


/**
 *  This constant denotes which side of the pixel matrix stretches toward the sky.
 *  Giving this value is necessary for detecting faces because OpenCV face detector
 * only detects faces heading the air.
 */
typedef enum _binaryface_image_orientations {
  BINARYFACE_IMAGE_ORIENTATION_FIRST_ROW_UP    = 0,
  BINARYFACE_IMAGE_ORIENTATION_LAST_ROW_UP     = 1,
  BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP = 2,
  BINARYFACE_IMAGE_ORIENTATION_LAST_COLUMN_UP  = 3
} binaryface_image_orientations;

typedef enum _binaryface_config_keys {
  BINARYFACE_CONFIG_MAX_NUM_FACES    = 0, /// int
  BINARYFACE_CONFIG_FRAME_PER_SECOND = 1, /// float
  BINARYFACE_CONFIG_ASYNC_DETECTION  = 2, /// int (0 or 1)
  BINARYFACE_CONFIG_VERTICAL_FOV     = 3  /// float
} binaryface_config_keys;

typedef enum _binaryface_ret {
  BINARYFACE_OK = 0,                    /// Success
  BINARYFACE_SDK_VERSION_MISMATCH = 1,  /// Check if your binaryface.h file is up to date
  BINARYFACE_FILE_NOT_FOUND = 2,        /// Data file not found
  BINARYFACE_FILE_CORRUPTED = 3,        /// Check if your api key is valid
  BINARYFACE_INVALID_PARAMETER = 4,     /// Check your parameter
  BINARYFACE_INVALID_SESSION = 5,       /// The session id is not yet assigned or already disposed
  BINARYFACE_EVALUATION_OVER = 6,       /// Evaluation versions have a 2000 frame limit
  BINARYFACE_NOT_IMPLEMENTED = 999,     /// The API function is not yet implemented
  BINARYFACE_UNKNOWN_ERROR = 1000
} binaryface_ret;

typedef enum _binaryface_log_level {
  BINARYFACE_LOG_LEVEL_TRACE    = 0,  /// Logs every API calls
  BINARYFACE_LOG_LEVEL_DEBUG    = 1,
  BINARYFACE_LOG_LEVEL_INFO     = 2,
  BINARYFACE_LOG_LEVEL_WARN     = 3,
  BINARYFACE_LOG_LEVEL_ERR      = 4,
  BINARYFACE_LOG_LEVEL_CRITICAL = 5,
  BINARYFACE_LOG_LEVEL_OFF      = 6,
} binaryface_log_level;

/**
 * You may require only one context per process.
 */
typedef int32_t binaryface_context_t;

/**
 *  sdk_version	        : SDK version. Should be equal to 'BINARYFACE_SDK_VERSION' constant.
 *  data_file_version	: .bf2 file version
 *  num_feature_points	: Number of feature points the context supports. Should be 66 in this version
 */
typedef struct _binaryface_context_info_t {
  int32_t sdk_version;
  int32_t data_file_version;
  int32_t num_feature_points;   /// In this version we only support 66 facial feature points
} binaryface_context_info_t;

/**
 *  You may open one session per camera.
 */
typedef int32_t binaryface_session_t;

/**
 *  image_width:      Image width in pixels
 *  image_height:     Image height in pixels
 *
 *  max_num_faces:    Maximum number of faces to track.
 *
 *  frame_per_second: Expected frame per second of the input video. This value is used to
 *                    smooth the feature point output across frames.
 *
 *  async_face_detection: Facial detection takes a lot of time and doing it every video
 *                        frame causes severe frame drops on mobile devices. If you turn on
 *                        this config,the context spawns a dedicated thread to run facial
 *                        detection in the background.
 *
 *  vertical_fov:     Field of view angle of the camera. This value is used to accurately
 *                    locate human faces in the 3D world coordinates. In Android you can
 *                    query 'Camera.Parameters' to set this value. In iOS you can read this
 *                    documentation to refer to the value: http://apple.co/2bPAdoh .
 */
typedef struct _binaryface_session_config_t {
    int32_t image_width;
    int32_t image_height;
    int32_t max_num_faces;
    float   frame_per_second;
    int32_t async_face_detection;
    float   vertical_fov;
} binaryface_session_config_t;

/**
 *  All values are equal to the configuration you gave except 'camera_matrix' and
 *  'num_tracking_3d_points'.
 *
 *  camera_matrix:  Perspective transformation matrix from the world coordinates to
 *                  screen coordinates. Stored in row major order.
 *
 *  num_tracking_3d_points: Number of tracking points around the head.
 *                          See 'binaryface_session_register_tracking_3d_points' for more
 *                          details.
 */
typedef struct _binaryface_session_info_t {
    int32_t image_width;
    int32_t image_height;
    int32_t max_num_faces;
    float   frame_per_second;
    int32_t async_face_detection;
    float   vertical_fov;
    float   camera_matrix[4][4];      //  World coordinate -> Screen coordinate
    int32_t num_tracking_3d_points;
} binaryface_session_info_t;

/**
 *  face_id:  A constant value identifying a face. For the face of the same
 *            person, this value is retained throughout the successive frames.
 *  score:    A value between 0.0 and 1.0. The higher this value is, the more
 *            the corresponding face is likely a real face.
 */
typedef struct _binaryface_face_info_t {
  int32_t face_id;
  float score;
} binaryface_face_info_t;

/**
 *  rigid_motion_matrix: A 4x4 matrix to transform facial feature points and
 *                       tracking points from average head coordinates to the
 *                       world coordinates. In row major order.
 */
typedef struct _binaryface_face_3d_info_t {
  float rigid_motion_matrix[4][4];
} binaryface_face_3d_info_t;

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  @brief  Open a BinaryFace context. You will need to call this function only
 *          once in your runtime.
 *
 *  @param  bf2_path     .bf2 model file path
 *
 *  @param  api_key      BinaryFace API key of your app.
 *                       See the license document.
 *
 *  @param  sdk_version  SDK version. Simply pass 'BINARYFACE_SDK_VERSION'.
 *                       This function returns BINARYFACE_SDK_VERSION_MISMATCH
 *                       if the SDK binary version mismatches with this
 *                       parameter.
 *
 *  @param  context_out  The context created
 *
 *  @param  info_out     The context information
 */
BINARYFACE_API binaryface_ret binaryface_open_context(
    const char *bf2_path,
    const char *api_key,
    int32_t sdk_version,
    binaryface_context_t *context_out,
    binaryface_context_info_t *info_out);

/**
 *  @brief  Close the BinaryFace context and release all the resources
 *          allocated.
 *
 *  @param  context   BinaryFace context
 */
BINARYFACE_API binaryface_ret binaryface_close_context(
    binaryface_context_t context);

/**
 *  @brief  Open a BinaryFace session. You will need one session per camera.
 *
 *  @param  context           BinaryFace context
 *  @param  config_in         Session configuration
 *  @param  session_out       The session just have opened
 *  @param  session_info_out  A buffer to retrieve the session information
 */
BINARYFACE_API binaryface_ret binaryface_open_session(
    binaryface_context_t context,
    binaryface_session_config_t *config_in,
    binaryface_session_t *session_out,
    binaryface_session_info_t *session_info_out);

/**
 *  @brief  Close the BinaryFace session and release all the resources
 *          allocated.
 *
 *  @param  session   BinaryFace session
 */
BINARYFACE_API binaryface_ret binaryface_close_session(
    binaryface_session_t session);

/**
 *  @brief  Get the BinaryFace session information
 *
 *  @param  session           BinaryFace session
 *  @param  session_info_out  A buffer to retrieve the session information
 */
BINARYFACE_API binaryface_ret binaryface_get_session_info(
    binaryface_session_t session,
    binaryface_session_info_t *session_info_out);

/**
 *  @brief  Configure the session
 *
 *  @param  session   BinaryFace session
 *  @param  key       Configuration key
 *  @param  value     Configuration value
 */
BINARYFACE_API binaryface_ret binaryface_set_session_parameter_int(
    binaryface_session_t session,
    int32_t key,
    int32_t value);

/**
 *  @brief  Configure the session
 *
 *  @param  session   BinaryFace session
 *  @param  key       Configuration key
 *  @param  value     Configuration value
 */
BINARYFACE_API binaryface_ret binaryface_set_session_parameter_float(
    binaryface_session_t session,
    int32_t key,
    float value);

/**
 *  @brief  Register 3D points on the face or around the head.
 *          Successive call of this function deregisters all the previously
 *          registered points.
 *          See the documentation for details.
 *
 *  @param  session     BinaryFace session
 *
 *  @param  num_points  Number of 3D points on the face or around the head
 *
 *  @param  coordinates An array of floating points numbers of length
 *                      3*(num_points) to put the tracking point coordinates in
 *                      the average head space.
 *                      The layout of the input array is like:
 *                      X_1, Y_1, Z_1, X_2, Y_2, Z_2, ..., X_N, Y_N, Z_N
 *                      (N: num_points)
 */
BINARYFACE_API binaryface_ret binaryface_session_register_tracking_3d_points(
    binaryface_session_t session,
    int num_points,
    const float *coordinates);

/**
 *  @brief  Put a new image frame and run facial tracking.
 *          The result is stored in the session and you get the number of faces
 *          and information for each face with successive
 *          'binaryface_get_num_faces' and 'binaryface_get_face_info'
 *          calls.
 *
 *  @params session      BinaryFace session
 *
 *  @params data         Image frame bitmap data in row major order considering
 *                       that the image is a matrix of image_height rows and
 *                       image_width columns. The bytes per pixel depends on
 *                       the 'pixel_format' parameter.
 *
 *  @params y_stride     Number of bytes per row. Give 0 if there is no gap
 *                       between rows.
 *
 *  @params pixel_format Image pixel format. Pick a value among
 *                       'binaryface_pixel_format' enums.
 *
 *  @params orientation  Tells which side of the image frame stretches toward
 *                       the sky.  One of the values of
 *                       'binaryface_image_orientations' enums.
 */
BINARYFACE_API binaryface_ret binaryface_run_tracking(
    binaryface_session_t session,
    const uint8_t *data,
    int32_t y_stride,
    int32_t pixel_format,
    int32_t orientation);

/**
 *  @brief  Gets the number of faces in the facial tracking result.
 *
 *  @params session         BinaryFace session
 *  @params num_faces_out   An int32_t buffer to retrieve the number of faces
 */
BINARYFACE_API binaryface_ret binaryface_get_num_faces(
    binaryface_session_t session,
    int32_t *num_faces_out);

/**
 *  @brief  Gets the information of the specified face
 *
 *  @params session       BinaryFace session
 *
 *  @params face_index    Index of the face.
 *                        0 <= (face_index) < (num_faces returned by
 *                                             binaryface_get_num_faces)
 *
 *  @params face_info_out A buffer to get the face information.
 *
 *  @params coords_out    A floating point number array of length
 *                        2 * (# of feature points) to retrieve facial feature
 *                        locations in screen coordinates. The layout of the
 *                        output is like: X_1, Y_1, X_2, Y_2, ..., X_N, Y_N
 *                        (N: # of facial feature points)
 */
BINARYFACE_API binaryface_ret binaryface_get_face_info(
    binaryface_session_t session,
    int face_index,
    binaryface_face_info_t *face_info_out,
    float *coords_out);

/**
 *  @brief  Gets the face information in the 3D space. Please refer to the
 *          document to learn about average head coordinates, the world
 *          coordinates, and the screen coordinates.
 *
 *  @params session             BinaryFace session
 *
 *  @params face_index          Index of the face
 *                              0 <= (face_index) < (num_faces returned by
 *                                                   binaryface_get_num_faces)
 *
 *  @params face_info_out       A buffer to get the face information in the
 *                              3D space
 *
 *  @params feature_points_out  A floating point number array of length
 *                              3 * (# of feature points) to retrieve facial
 *                              feature locations in average head coordinates.
 *                              The layout of the output is like:
 *                              X_1, Y_1, Z_1, ..., X_N, Y_N, Z_N
 *                              (N: # of facial feature points)
 *
 *  @params tracking_points_out A floating point number array of length
 *                              3 * (# of tracking points) to retrieve tracking
 *                              point locations in average head coordinates.
 */
BINARYFACE_API binaryface_ret binaryface_get_face_3d_info(
    binaryface_session_t session,
    int face_index,
    binaryface_face_3d_info_t *face_info_out,
    float *feature_points_out,
    float *tracking_points_out);

/**
 *  @brief  Gets the number of action triggers the model supports.
 *
 *  @params context                   BinaryFace context
 *
 *  @params num_action_triggers_out   Number of action triggers
 */
BINARYFACE_API binaryface_ret binaryface_get_num_action_triggers(
    binaryface_context_t context,
    int *num_action_triggers_out);

/**
 *  @brief  Gets the name of the specified action trigger
 *
 *  @params context                 BinaryFace context
 *
 *  @params index                   Action trigger index
 *
 *  @params name_out                Pointer to the action trigger name,
 *                                  zero-terminated
 */
BINARYFACE_API binaryface_ret binaryface_get_action_trigger_name(
    binaryface_context_t context,
    int index,
    const char **name_out);

/**
 *  @brief  Get the action trigger index by the action trigger name
 *
 *  @params context                 BinaryFace context
 *
 *  @params name                    Action trigger name
 *
 *  @params index_out               Pointer to the action trigger name.
 *                                  -1 if does not exist
 */
BINARYFACE_API binaryface_ret binaryface_find_action_trigger(
    binaryface_context_t context,
    const char *name,
    int *index_out);

/**
 *  @brief  Gets whether the action is triggered on the specified face
 *
 *  @params session                 BinaryFace session
 *
 *  @params action_trigger_idx      The action trigger index, starting from 0
 *
 *  @params face_index              Index of the face
 *
 *                                  0 <= (face_index) < (num_faces returned by
 *                                                       binaryface_get_num_faces)
 *
 *  @params triggered_out           1 if the action is triggered, 0 if not
 */
BINARYFACE_API binaryface_ret binaryface_check_action_trigger(
    binaryface_session_t session,
    int action_trigger_idx,
    int face_index,
    int *triggered_out);

/**
 *  @brief  Sets the log level for BinaryFace SDK APIs
 *
 *  @params log_level  Log level. One of binaryface_log_level values
 *                     BINARYFACE_LOG_LEVEL_TRACE: traces all API calls
 *                     BINARYFACE_LOG_LEVEL_OFF: turns off all logs
 */
BINARYFACE_API binaryface_ret binaryface_set_log_level(
    int log_level);

#ifdef __cplusplus
}
#endif

#endif // _BINARYVR_BINARYFACE_H_
