/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#pragma once

#include <Eigen/Dense>
#include <set>
#include <cstdint>
#include <vector>

namespace facemod {

static const int FACE_MOD_TEXTURE_SIZE = 256;
static const int FACE_MOD_NUM_POLY_VERTICES = 20;
static const int FACE_MOD_NUM_POLY_TRIANGLES = 30;
static const float FACE_MOD_DISP_TEX_SCALE = 8.0f;

static const int FACE_MOD_TRIANGLES[FACE_MOD_NUM_POLY_TRIANGLES][3] =
{
  {0, 15, 7},
  {7, 15, 14},
  {6, 16, 7},
  {6, 14, 13},
  {18, 16, 17},
  {6, 7, 14},
  {0, 7, 16},
  {8, 0, 1},
  {0, 8, 15},
  {2, 9, 1},
  {1, 9, 8},
  {1, 0, 16},
  {19, 1, 18},
  {16, 18, 1},
  {16, 6, 17},
  {6, 5, 17},
  {3, 18, 17},
  {5, 12, 4},
  {12, 5, 13},
  {4, 12, 11},
  {5, 4, 17},
  {17, 4, 3},
  {19, 2, 1},
  {2, 19, 3},
  {3, 11, 10},
  {19, 18, 3},
  {3, 10, 2},
  {4, 11, 3},
  {2, 10, 9},
  {6, 13, 5},
};

static const float FACE_MOD_POLY_VERTICES[FACE_MOD_NUM_POLY_VERTICES][2] = {
    {0.24127f, 0.46416f},
    {0.29698f, 0.67231f},
    {0.50061f, 0.76921f},
    {0.70235f, 0.67396f},
    {0.75952f, 0.46415f},
    {0.70636f, 0.33078f},
    {0.50007f, 0.26515f},
    {0.29412f, 0.33141f},
    {0.01547f, 0.63613f},
    {0.28597f, 0.95787f},
    {0.71360f, 0.95903f},
    {0.98428f, 0.63809f},
    {0.97686f, 0.30025f},
    {0.68282f, 0.04774f},
    {0.31667f, 0.04831f},
    {0.02373f, 0.30067f},
    {0.39027f, 0.45537f},
    {0.60556f, 0.45458f},
    {0.49958f, 0.52766f},
    {0.50022f, 0.64787f}
};

class FaceMod {
public:
  FaceMod() { }

  void reset();

  void init(
    Eigen::MatrixXf displacements,
    Eigen::MatrixXf &x_offset,
    Eigen::MatrixXf &y_offset);

  bool decode(const char *data);

  void translate(
    const Eigen::MatrixXf& input_pts,
    Eigen::MatrixXf& output_axes,
    Eigen::MatrixXf& output_pos,
    Eigen::MatrixXf& output_offset);

  unsigned char *getRGBABitmap() {
    return rgba_bitmap_.data();
  }

protected:
  Eigen::MatrixXf displacements_;
  std::vector<unsigned char> rgba_bitmap_;
};

} // namespace facemod
