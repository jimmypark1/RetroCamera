/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#include "face_mod.hpp"
#include <vector>
#include <set>
#include <algorithm>

#include <rapidjson/document.h>
#include <rapidjson/filereadstream.h>
#include <rapidjson/filewritestream.h>
#include <rapidjson/writer.h>

#include <stb_image.h>

using namespace std;
using namespace Eigen;
using namespace rapidjson;

namespace facemod {

std::vector<std::pair<int, float> > FACE_MOD_AXES_RECIPE_X[FACE_MOD_NUM_POLY_VERTICES] = {
  {
    {16, 2.67809f},
    {8, -1.14524f},
    {7, 0.82306f},
    {1, 0.63227f},
    {15, -1.21199f},
  },
  {
    {0, -0.61147f},
    {16, 0.29037f},
    {2, 0.98322f},
    {19, 0.82368f},
    {8, -1.62564f},
    {9, -0.42179f},
    {18, 0.53778f},
  },
  {
    {3, 1.49532f},
    {9, -0.93534f},
    {10, 0.93058f},
    {19, 0.00168f},
    {1, -1.47021f},
  },
  {
    {17, -0.28563f},
    {18, -0.52566f},
    {19, -0.82842f},
    {4, 0.60662f},
    {10, 0.41973f},
    {11, 1.62024f},
    {2, -1.00193f},
  },
  {
    {3, -0.63458f},
    {17, -2.58666f},
    {11, 1.14499f},
    {12, 1.21806f},
    {5, -0.81633f},
  },
  {
    {17, -1.51468f},
    {12, 1.63264f},
    {13, 0.11988f},
    {6, -1.66749f},
    {4, 1.21360f},
  },
  {
    {16, -0.51774f},
    {17, 0.51909f},
    {5, 1.42574f},
    {7, -1.41534f},
    {13, 0.82498f},
    {14, -0.82886f},
  },
  {
    {0, -1.23096f},
    {16, 1.54011f},
    {6, 1.69186f},
    {14, -0.12170f},
    {15, -1.63162f},
  },
  {
    {0, 1.87715f},
    {1, 2.20414f},
    {9, -0.13778f},
    {15, -0.85672f},
  },
  {
    {8, -1.14732f},
    {1, 0.15547f},
    {2, 1.72588f},
    {10, 0.74244f},
  },
  {
    {11, 1.15130f},
    {9, -0.74980f},
    {2, -1.71870f},
    {3, -0.14871f},
  },
  {
    {12, 0.85758f},
    {10, 0.13650f},
    {3, -2.21013f},
    {4, -1.86956f},
  },
  {
    {11, 0.90283f},
    {4, -1.67320f},
    {5, -2.17438f},
    {13, -0.14103f},
  },
  {
    {12, 1.17275f},
    {14, -0.97916f},
    {6, -1.59943f},
    {5, 0.18430f},
  },
  {
    {15, -1.17577f},
    {13, 0.97604f},
    {6, 1.60399f},
    {7, -0.17845f},
  },
  {
    {0, 1.67201f},
    {8, -0.90686f},
    {14, 0.14222f},
    {7, 2.17141f},
  },
  {
    {0, -2.20269f},
    {17, 1.20541f},
    {18, 1.58337f},
    {1, -0.47694f},
    {6, 0.72853f},
    {7, -1.19315f},
  },
  {
    {16, -1.23265f},
    {18, -1.58717f},
    {3, 0.47967f},
    {4, 2.09627f},
    {5, 1.18930f},
    {6, -0.73336f},
  },
  {
    {16, -2.36223f},
    {17, 2.37970f},
    {19, -0.00150f},
    {3, 1.21236f},
    {1, -1.20315f},
  },
  {
    {1, -2.45733f},
    {18, 0.02327f},
    {3, 2.47668f},
    {2, -0.01439f},
  },
};

std::vector<std::pair<int, float> > FACE_MOD_AXES_RECIPE_Y[FACE_MOD_NUM_POLY_VERTICES] = {
  {
    {16, 0.10825f},
    {8, 0.78857f},
    {7, -2.59533f},
    {1, 1.78026f},
    {15, -0.91889f},
  },
  {
    {0, -1.25016f},
    {16, -0.76451f},
    {2, 0.77376f},
    {19, -0.08073f},
    {8, 0.14913f},
    {9, 1.55839f},
    {18, -0.39655f},
  },
  {
    {3, -0.67941f},
    {9, 1.34673f},
    {10, 1.35529f},
    {19, -2.95925f},
    {1, -0.66935f},
  },
  {
    {17, -0.75315f},
    {18, -0.38863f},
    {19, -0.08573f},
    {4, -1.24547f},
    {10, 1.56173f},
    {11, 0.15100f},
    {2, 0.78302f},
  },
  {
    {3, 1.75769f},
    {17, 0.09855f},
    {11, 0.79240f},
    {12, -0.91788f},
    {5, -2.57841f},
  },
  {
    {17, 1.66954f},
    {12, -0.36734f},
    {13, -1.54011f},
    {6, -0.51867f},
    {4, 2.34027f},
  },
  {
    {16, 1.18006f},
    {17, 1.21167f},
    {5, 0.20964f},
    {7, 0.20312f},
    {13, -1.19584f},
    {14, -1.19345f},
  },
  {
    {0, 2.31972f},
    {16, 1.70817f},
    {6, -0.51180f},
    {14, -1.53725f},
    {15, -0.36401f},
  },
  {
    {0, -1.56126f},
    {1, 0.25512f},
    {9, 1.07209f},
    {15, -1.12487f},
  },
  {
    {8, -0.04426f},
    {1, -2.38068f},
    {2, -1.61652f},
    {10, 0.84472f},
  },
  {
    {11, -0.04544f},
    {9, 0.84133f},
    {2, -1.62119f},
    {3, -2.38069f},
  },
  {
    {12, -1.10814f},
    {10, 1.07295f},
    {3, 0.24749f},
    {4, -1.56604f},
  },
  {
    {11, 1.19720f},
    {4, 1.70422f},
    {5, 0.02185f},
    {13, -1.24961f},
  },
  {
    {12, -0.09755f},
    {14, -0.82307f},
    {6, 1.78230f},
    {5, 2.25274f},
  },
  {
    {15, -0.09367f},
    {13, -0.82554f},
    {6, 1.77574f},
    {7, 2.25409f},
  },
  {
    {0, 1.70580f},
    {8, 1.20663f},
    {14, -1.25108f},
    {7, 0.01987f},
  },
  {
    {0, 0.24740f},
    {17, -0.20736f},
    {18, 1.96611f},
    {1, 1.62779f},
    {6, -1.44259f},
    {7, -1.83901f},
  },
  {
    {16, -0.20859f},
    {18, 2.01611f},
    {3, 1.58456f},
    {4, 0.24804f},
    {5, -1.78393f},
    {6, -1.48850f},
  },
  {
    {16, -3.38047f},
    {17, -3.47943f},
    {19, 2.51114f},
    {3, 0.67955f},
    {1, 0.69189f},
  },
  {
    {1, 0.01070f},
    {18, -4.48826f},
    {3, -0.01082f},
    {2, 3.79504f},
  },
};

void FaceMod::reset()
{
  displacements_ = MatrixXf::Zero(2, FACE_MOD_NUM_POLY_VERTICES);
  rgba_bitmap_.resize(FACE_MOD_TEXTURE_SIZE * FACE_MOD_TEXTURE_SIZE * 4);
}

void FaceMod::init(Eigen::MatrixXf displacements,
    Eigen::MatrixXf &x_offset,
    Eigen::MatrixXf &y_offset)
{
  assert(displacements.rows() == 2);
  assert(displacements.cols() == FACE_MOD_NUM_POLY_VERTICES);
  displacements_ = displacements;
  rgba_bitmap_.resize(FACE_MOD_TEXTURE_SIZE * FACE_MOD_TEXTURE_SIZE * 4);

  for (int i = 0; i < FACE_MOD_TEXTURE_SIZE; i++) {
    for (int j = 0; j < FACE_MOD_TEXTURE_SIZE; j++) {
      float disp_x = x_offset(i, j);
      float disp_y = y_offset(i, j);

      int disp_xi = (int)floorf(disp_x * FACE_MOD_DISP_TEX_SCALE * 128 + 128 + 0.5f);
      int disp_yi = (int)floorf(disp_y * FACE_MOD_DISP_TEX_SCALE * 128 + 128 + 0.5f);

      disp_xi = min(max(disp_xi, 0), 255);
      disp_yi = min(max(disp_yi, 0), 255);

      unsigned char *pt = rgba_bitmap_.data() + (i * FACE_MOD_TEXTURE_SIZE + j) * 4;

      pt[0] = disp_xi;
      pt[1] = disp_yi;
      pt[2] = 0;
      pt[3] = 255;
    }
  }
}

//  base64
using byte = unsigned char;

static bool dlookupok = false;
static char dlookup[256];
const static char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
const static char padchar = '=';

static const char *getdlookup()
{
    if (!dlookupok) {
        memset(dlookup, 0, sizeof(dlookup));
        for (int i = 0; i < strlen(lookup); i++) {
            dlookup[(int) lookup[i]] = i;
        }
    }

    dlookupok = true;
    return dlookup;
}

static std::string b64_encode(const std::vector<byte> &src)
{
    std::string encoded;

    int outputSize = (int)(4 * ((src.size() / 3) + (src.size() % 3 > 0 ? 1 : 0)));
    encoded.reserve(outputSize);

    uint32_t tmp;
    int i;
    int padding;
    int srcsz = (int)src.size();

    for (i = 0; i < srcsz; i += 3) {
        padding = (i + 3) - srcsz;
        tmp = 0;

        switch (padding) {
        case 2:
            tmp |= (src[i] << 16);
            break;
        case 1:
            tmp |= (src[i] << 16) | (src[i + 1] << 8);
            break;
        default:
            tmp |= (src[i] << 16) | (src[i + 1] << 8) | (src[i + 2]);
            break;
        }

        encoded +=                         lookup[(tmp & 0xfc0000) >> 18];
        encoded +=                         lookup[(tmp & 0x03f000) >> 12];
        encoded += padding > 1 ? padchar : lookup[(tmp & 0x000fc0) >> 6];
        encoded += padding > 0 ? padchar : lookup[(tmp & 0x00003f)];
    }

    return encoded;
}

static std::vector<byte> b64_decode(const std::string &src)
{
    const char *dlookup = getdlookup();
    std::vector<byte> decoded;

    int outputSize = (int)((src.size() / 4) * 3);
    decoded.reserve(outputSize);

    char ch[4];
    uint32_t tmp;
    int i, j;
    int padding = 0;

    for (i = 0; i < src.size(); i += 4) {
        for (j = 0; j < 4; j++) {
            if (src[i + j] == padchar) {
                ch[j] = '\0';
                padding++;
            } else {
                ch[j] = dlookup[src[i + j]];
            }
        }

        tmp = 0;
        tmp |= (ch[0] << 18) | (ch[1] << 12) | (ch[2] << 6) | ch[3];

        decoded.push_back((tmp & 0xff0000) >> 16);
        decoded.push_back((tmp & 0xff00) >> 8);
        decoded.push_back((tmp & 0xff));
    }
    return decoded;
}


bool FaceMod::decode(const char *data)
{
  Document d;
  d.Parse<0>(data);

  if (d.HasParseError()) return false;

  if (!d.HasMember("guide_points")) return false;
  if (!d.HasMember("bitmap")) return false;

  if (d["guide_points"].Size() != 2 * FACE_MOD_NUM_POLY_VERTICES) return false;

  displacements_ = MatrixXf::Zero(2, FACE_MOD_NUM_POLY_VERTICES);

  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < FACE_MOD_NUM_POLY_VERTICES; j++) {
      displacements_(i, j) = d["guide_points"][j * 2 + i].GetFloat();
    }
  }

  string b64_jpeg(d["bitmap"].GetString());
  vector<byte> decoded = b64_decode(b64_jpeg);

  int width = 0;
  int height = 0;
  int comp = 0;

  stbi_uc *decoded_image = stbi_load_from_memory(decoded.data(), (int)decoded.size(), &width, &height, &comp, 4);
  if (!decoded_image) return false;

  if (width != FACE_MOD_TEXTURE_SIZE) return false;
  if (height != FACE_MOD_TEXTURE_SIZE) return false;

  rgba_bitmap_.resize(FACE_MOD_TEXTURE_SIZE * FACE_MOD_TEXTURE_SIZE * 4);

  comp = 4; // TODO: right?

  unsigned char *p = (unsigned char *)decoded_image;
  for (int i = 0; i < FACE_MOD_TEXTURE_SIZE; i++) {
    for (int j = 0; j < FACE_MOD_TEXTURE_SIZE; j++) {
      for (int k = 0; k < comp; k++) {
        rgba_bitmap_[(i * FACE_MOD_TEXTURE_SIZE + j) * 4 + k] = *p;
        p++;
      }
      for (int k = comp; k < 4; k++) {
        rgba_bitmap_[(i * FACE_MOD_TEXTURE_SIZE + j) * 4 + k] = 0;
      }
    }
  }
  free(decoded_image);

  return true;
}

void FaceMod::translate(
  const Eigen::MatrixXf& input_pts,
  Eigen::MatrixXf& output_axes,
  Eigen::MatrixXf& output_pos,
  Eigen::MatrixXf& output_offset)
{
  MatrixXf input_augmented_pts = MatrixXf::Zero(2, FACE_MOD_NUM_POLY_VERTICES);
  int col = 0;

  //  Create input augmented points
  for (int i : {0, 4, 8, 12, 16, 73, 70, 67}) {
    input_augmented_pts.col(col++) << input_pts.col(i);
  }

  float a = (input_augmented_pts.col(0) - input_augmented_pts.col(2)).norm();
  float b = (input_augmented_pts.col(0) - input_augmented_pts.col(4)).norm();
  float c = (input_augmented_pts.col(2) - input_augmented_pts.col(4)).norm();

  float grow_factor = a * b * c / sqrt(
          (a + b + c) * (b + c - a) * (c + a - b) * (a + b - c));

  //  Augment the boundary
  for (int i = 0; i < 8; i++) {
    Vector2f p0 = input_augmented_pts.col(i);
    Vector2f p1 = input_augmented_pts.col((i + 1) % 8);

    Vector2f midp = 0.5f * (p0 + p1);
    Vector2f direction = p1 - p0;
    direction /= direction.norm();

    Vector2f gp = midp + grow_factor * Vector2f(-direction(1), direction(0));
    input_augmented_pts.col(col++) << gp;
  }

  //  Two eyes
  input_augmented_pts.col(col++) << 0.5f * (input_pts.col(36) + input_pts.col(39));
  input_augmented_pts.col(col++) << 0.5f * (input_pts.col(42) + input_pts.col(45));

  //  Nose tip
  input_augmented_pts.col(col++) << input_pts.col(30);

  //  Mouth center
  input_augmented_pts.col(col++) << 0.5f * (input_pts.col(48) + input_pts.col(54));

  assert(col == FACE_MOD_NUM_POLY_VERTICES);

  //  Axes
  output_axes = MatrixXf::Zero(4, FACE_MOD_NUM_POLY_VERTICES);

  //  Pos
  output_pos = MatrixXf::Zero(2, FACE_MOD_NUM_POLY_VERTICES);

  //  Offset
  output_offset = MatrixXf::Zero(2, FACE_MOD_NUM_POLY_VERTICES);

  for (int i = 0; i < FACE_MOD_NUM_POLY_VERTICES; i++) {
    //  X recipe
    Vector2f x_sum = Vector2f::Zero();

    //  Y recipe
    Vector2f y_sum = Vector2f::Zero();

    for (auto& p : FACE_MOD_AXES_RECIPE_X[i]) {
      int idx = p.first;
      float weight = p.second;
      x_sum += (input_augmented_pts.col(idx) - input_augmented_pts.col(i)) * weight;
    }
    for (auto& p : FACE_MOD_AXES_RECIPE_Y[i]) {
      int idx = p.first;
      float weight = p.second;
      y_sum += (input_augmented_pts.col(idx) - input_augmented_pts.col(i)) * weight;
    }

    output_axes.col(i).segment(0, 2) = x_sum;
    output_axes.col(i).segment(2, 2) = y_sum;

    output_pos.col(i) = input_augmented_pts.col(i);

    output_offset.col(i) =
      displacements_(0, i) * x_sum +
      displacements_(1, i) * y_sum;
  }

}

}
