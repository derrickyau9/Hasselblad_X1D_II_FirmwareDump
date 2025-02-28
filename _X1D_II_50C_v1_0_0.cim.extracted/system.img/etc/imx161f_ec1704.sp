{
   "stream_profile": {
       "name": "imx161_with_fpga",
       "stream_groups": [
           {
               "id": "still_r43_cap",
               "shooter_id": "still-X1DM2_normal",
               "shooter_param": "res=4x3;normal_cap=offline;",
               "still_process_pipe": [
                   {
                       "id": "main_pipe",
                       "nodes": [
                          {
                            "id": "input",
                            "param": ""
                          }
                       ]
                   },
                   {
                       "id":"hdr_pipe",
                       "nodes": [
                           {
                               "id": "input",
                               "param": ""
                           }
                       ]
                   }
               ],
               "sensor_fps": "DCAM_FPS_2997",
               "streams" : [
                    {
                       "id" : "liveview",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_RGBA8888",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 1280,
                       "height": 960,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 5
                    },
                    {
                       "id" : "liveview_lcd",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_RGBA8888",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 1024,
                       "height": 768,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 5
                    },
                    {
                       "id" : "liveview_cfv",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_RGBA8888",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 640,
                       "height": 480,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 4
                    },
                    {
                       "id" : "liveview_hdmi_720p",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_RGBA8888",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 960,
                       "height": 720,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 4
                    },
                    {
                       "id" : "liveview_hdmi_1080p",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_RGBA8888",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 1440,
                       "height": 1080,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 4
                    },
                    {
                       "id" : "liveview_raw",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_RAW16_OPAQUE",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 2756,
                       "height": 1240,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 4
                    },
                    {
                       "id" : "liveview_rawob",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_RAW16_OPAQUE",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 2816,
                       "height": 1260,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 4
                    },
                    {
                       "id" : "liveview_rawob_zoom",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_RAW16_OPAQUE",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 1280,
                       "height": 576,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 4
                    },
                    {
                       "id" : "still_small_yuv",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_STILL",
                       "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",
                       "format": "DUSS_PIXFMT_YUV8_SP422_YUV",
                       "fps": 300,
                       "width": 4136,
                       "height": 3100,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "buffer_nr": 2
                    },
                    {
                       "id" : "still_small_raw",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_STILL",
                       "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",
                       "format": "DUSS_PIXFMT_RAW16_OPAQUE",
                       "fps": 300,
                       "width": 4136,
                       "height": 3100,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "buffer_nr": 2
                    },
                    {
                       "id" : "still_raw",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_STILL",
                       "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",
                       "format": "DUSS_PIXFMT_RAW16_OPAQUE",
                       "fps": 300,
                       "width": 8384,
                       "height": 6304,
                       "width_alignment": 8384,
                       "height_alignment": 6305,
                       "vmem_flag": 31,
                       "buffer_nr": 8
                    }
               ]
           },
           {
               "id": "still_r43_jandr_cap",
               "shooter_id": "still-X1DM2_normal",
               "shooter_param": "res=4x3_jandr;normal_cap=offline;",
               "still_raw_process_pipe": [
                   {
                       "id": "raw_process_pipe",
                       "nodes": [
                          {
                            "id": "input",
                            "param": ""
                          },
                          {
                            "id": "frame_adjust",
                            "param": "output_buffer_nr=1;x_begin=64;y_begin=100;crop_width=8256;crop_height=6200;"
                          }
                       ]
                   }
               ],
               "still_process_pipe": [
                   {
                       "id": "main_pipe",
                       "nodes": [
                          {
                            "id": "input",
                            "param": ""
                          },
                          {
                            "id": "pfr",
                            "param": "output_buffer_nr=0;"
                          },
                          {
                            "id": "hiso",
                            "param": "output_buffer_nr=0;y_offset=256;"
                          },
                          {
                            "id": "xidiri",
                            "param": "output_buffer_nr=0;is_split_output=true;"
                          }
                       ]
                   },
                   {
                       "id":"hdr_pipe",
                       "nodes": [
                           {
                               "id": "input",
                               "param": ""
                           }
                       ]
                   }
               ],
               "sensor_fps": "DCAM_FPS_2997",
               "main_jpeg_encoder": "plat_imgtec_rst",
               "streams" : [
                    {
                       "id" : "liveview",
                       "copy_from": "still_r43_cap/liveview"
                    },
                    {
                       "id" : "liveview_lcd",
                       "copy_from": "still_r43_cap/liveview_lcd"
                    },
                    {
                       "id" : "liveview_cfv",
                       "copy_from": "still_r43_cap/liveview_cfv"
                    },
                    {
                       "id" : "liveview_hdmi_720p",
                       "copy_from": "still_r43_cap/liveview_hdmi_720p"
                    },
                    {
                       "id" : "liveview_hdmi_1080p",
                       "copy_from": "still_r43_cap/liveview_hdmi_1080p"
                    },
                    {
                       "id" : "liveview_raw",
                       "copy_from": "still_r43_cap/liveview_raw"
                    },
                    {
                       "id" : "still_small_yuv",
                       "copy_from": "still_r43_cap/still_small_yuv"
                    },
                    {
                       "id" : "still_small_raw",
                       "copy_from": "still_r43_cap/still_small_raw"
                    },
                    {
                       "id" : "still_raw",
                       "copy_from": "still_r43_cap/still_raw",
                       "buffer_nr": 2
                    },
                    {
                       "id" : "still_yuv",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_STILL",
                       "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",
                       "format": "DUSS_PIXFMT_YUV8_SP422_YUV",
                       "fps": 300,
                       "width": 8256,
                       "height": 6200,
                       "y_offset": 256,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "vmem_flag": 31,
                       "buffer_nr": 4
                    }
               ]
           },
           {
               "id": "still_r43_jpeg_cap",
               "shooter_id": "still-X1DM2_normal",
               "shooter_param": "res=4x3_jpeg;normal_cap=offline;",
               "still_raw_process_pipe": [
                   {
                       "id": "raw_process_pipe",
                       "nodes": [
                          {
                            "id": "input",
                            "param": ""
                          },
                          {
                            "id": "frame_adjust",
                            "param": "output_buffer_nr=1;x_begin=64;y_begin=100;crop_width=8256;crop_height=6200;"
                          }
                       ]
                   }
               ],
               "still_process_pipe": [
                   {
                       "id": "main_pipe",
                       "nodes": [
                          {
                            "id": "input",
                            "param": ""
                          },
                          {
                            "id": "pfr",
                            "param": "output_buffer_nr=0;"
                          },
                          {
                            "id": "hiso",
                            "param": "output_buffer_nr=0;y_offset=256;"
                          },
                          {
                            "id": "xidiri",
                            "param": "output_buffer_nr=0;is_split_output=true;"
                          }
                       ]
                   },
                   {
                       "id":"hdr_pipe",
                       "nodes": [
                           {
                               "id": "input",
                               "param": ""
                           }
                       ]
                   }
               ],
               "sensor_fps": "DCAM_FPS_2997",
               "main_jpeg_encoder": "plat_imgtec_rst",
               "streams" : [
                    {
                       "id" : "liveview",
                       "copy_from": "still_r43_cap/liveview"
                    },
                    {
                       "id" : "liveview_lcd",
                       "copy_from": "still_r43_cap/liveview_lcd"
                    },
                    {
                       "id" : "liveview_cfv",
                       "copy_from": "still_r43_cap/liveview_cfv"
                    },
                    {
                       "id" : "liveview_hdmi_720p",
                       "copy_from": "still_r43_cap/liveview_hdmi_720p"
                    },
                    {
                       "id" : "liveview_hdmi_1080p",
                       "copy_from": "still_r43_cap/liveview_hdmi_1080p"
                    },
                    {
                       "id" : "liveview_raw",
                       "copy_from": "still_r43_cap/liveview_raw"
                    },
                    {
                       "id" : "still_small_yuv",
                       "copy_from": "still_r43_cap/still_small_yuv"
                    },
                    {
                       "id" : "still_small_raw",
                       "copy_from": "still_r43_cap/still_small_raw"
                    },
                    {
                       "id" : "still_raw",
                       "copy_from": "still_r43_cap/still_raw",
                       "buffer_nr": 2
                    },
                    {
                       "id" : "still_yuv",
                       "copy_from": "still_r43_jandr_cap/still_yuv",
                       "buffer_nr": 4
                    }
               ]
           },
           {
               "id": "still_r43_raw_playback",
               "shooter_id": "still-X1DM2_normal",
               "shooter_param": "res=4x3_raw_pb;",
               "still_raw_process_pipe": [
                   {
                       "id": "raw_process_pipe",
                       "nodes": [
                          {
                            "id": "input",
                            "param": ""
                          },
                          {
                            "id": "frame_adjust",
                            "param": "output_buffer_nr=1;x_begin=64;y_begin=100;crop_width=8256;crop_height=6200;"
                          }
                       ]
                   }
               ],
               "still_process_pipe": [
                   {
                       "id": "main_pipe",
                       "nodes": [
                          {
                            "id": "input",
                            "param": ""
                          },
                          {
                            "id": "pfr",
                            "param": "output_buffer_nr=0;"
                          },
                          {
                            "id": "hiso",
                            "param": "output_buffer_nr=0;y_offset=256;"
                          },
                          {
                            "id": "xidiri",
                            "param": "output_buffer_nr=0;is_split_output=false;"
                          }
                       ]
                   }
               ],
               "sensor_fps": "DCAM_FPS_2997",
               "streams" : [
                    {
                       "id" : "still_yuv",
                       "copy_from": "still_r43_jandr_cap/still_yuv",
                       "fps": "DCAM_FPS_0",
                       "buffer_nr": 7
                    }
               ]
           },
           {
               "id": "still_r43_normal_raw_pattern",
               "shooter_id": "still-rawonly",
               "shooter_param": "res=4x3_raw_pat;",
               "sensor_fps": "DCAM_FPS_2997",
               "streams" : [
                    {
                       "id" : "still_raw",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_STILL",
                       "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",
                       "format": "DUSS_PIXFMT_RAW16_OPAQUE",
                       "fps": 300,
                       "width": 8384,
                       "height": 6304,
                       "width_alignment": 8384,
                       "height_alignment": 6305,
                       "vmem_flag": 31,
                       "buffer_nr": 5
                    }
               ]
           },
           {
               "id": "video_1080P@2997",
               "shooter_id": "video-single",
               "sensor_fps": "DCAM_FPS_2997",
               "streams" : [
                   {
                       "id": "yuv_piv",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_VIDEO",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_YUV8_SP420_YUV",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 2756,
                       "height": 1552,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "buffer_nr": 5,
                       "local_filters": [
                           {
                             "type": "dzoom",
                             "id" : "dzoom_1",
                             "style": "pull",
                             "parameter": ""
                           }
                       ]
                    },
                    {
                       "id" : "liveview",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_YUV8_SP420_YUV",
                       "fps": "DCAM_FPS_2997",
                       "width": 640,
                       "height": 360,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "buffer_nr": 5
                    },
                    {
                       "id": "video",
                       "type": "DCAM_STREAM_TYPE_FILTER",
                       "usage": "DCAM_STREAM_USAGE_VIDEO",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_YUV8_SP420_YUV",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 1920,
                       "height": 1080,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "buffer_nr": 5,
                       "remote_filter": {
                             "stream_id": "yuv_piv",
                             "filter_id": "dzoom_1",
                             "output_port_index": 0
                        }
                    }
               ]
           },
           {
               "id": "video_2720P@2997",
               "shooter_id": "video-single",
               "sensor_fps": "DCAM_FPS_2997",
               "streams" : [
                    {
                       "id": "yuv_piv",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_VIDEO",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_YUV8_SP420_YUV",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 2756,
                       "height": 1552,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "buffer_nr": 5,
                       "local_filters": [
                           {
                             "type": "dzoom",
                             "id" : "dzoom_1",
                             "style": "pull",
                             "parameter": ""
                           }
                       ]
                    },
                    {
                       "id" : "liveview",
                       "type": "DCAM_STREAM_TYPE_COMMON",
                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_YUV8_SP420_YUV",
                       "fps": "DCAM_FPS_2997",
                       "width": 640,
                       "height": 360,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "buffer_nr": 5
                    },
                    {
                       "id": "video",
                       "type": "DCAM_STREAM_TYPE_FILTER",
                       "usage": "DCAM_STREAM_USAGE_VIDEO",
                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
                       "format": "DUSS_PIXFMT_YUV8_SP420_YUV",
                       "flag": ["DCAM_STREAM_FLAG_ON_DEMAND"],
                       "fps": "DCAM_FPS_2997",
                       "width": 2720,
                       "height": 1530,
                       "width_alignment": 128,
                       "height_alignment": 1,
                       "buffer_nr": 5,
                       "remote_filter": {
                             "stream_id": "yuv_piv",
                             "filter_id": "dzoom_1",
                             "output_port_index": 0
                        }
                    }
               ]
           }
       ]
   }
}
