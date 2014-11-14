// tutorial01.c
//
// This tutorial was written by Stephen Dranger (dranger@gmail.com).
//
// Code based on a tutorial by Martin Bohme (boehme@inb.uni-luebeckREMOVETHIS.de)
// Tested on Gentoo, CVS version 5/01/07 compiled with GCC 4.1.1

// A small sample program that shows how to use libavformat and libavcodec to
// read video from a file.
//
// Use the Makefile to build all examples.
//
// Run using
//
// tutorial01 myvideofile.mpg
//
// to write the first five frames from "myvideofile.mpg" to disk in PPM
// format.

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "litmus.h"


// These are in milliseconds.
#define PERIOD            33
#define RELATIVE_DEADLINE 33
#define EXEC_COST         10

/* Catch errors.
 */
#define CALL( exp ) do { \
    int ret; \
    ret = exp; \
    if (ret != 0) \
      fprintf(stderr, "%s failed: %m\n", #exp);\
    else \
      fprintf(stderr, "%s ok.\n", #exp); \
  } while (0)


/* Declare the periodically invoked job. 
 * Returns 1 -> task should exit.
 *         0 -> task should continue.
 */
int job();

/* typically, main() does a couple of things: 
 *  1) parse command line parameters, etc.
 *  2) Setup work environment.
 *  3) Setup real-time parameters.
 *  4) Transition to real-time mode.
 *  5) Invoke periodic or sporadic jobs.
 *  6) Transition to background mode.
 *  7) Clean up and exit.
 */

void SaveFrame(AVFrame *pFrame, int width, int height, int iFrame) {
  FILE *pFile;
  char szFilename[32];
  int  y;
  
  // Open file
  sprintf(szFilename, "frame%d.ppm", iFrame);
  pFile=fopen(szFilename, "wb");
  if(pFile==NULL)
    return;
  
  // Write header
  fprintf(pFile, "P6\n%d %d\n255\n", width, height);
  
  // Write pixel data
  for(y=0; y<height; y++)
    fwrite(pFrame->data[0]+y*pFrame->linesize[0], 1, width*3, pFile);
  
  // Close file
  fclose(pFile);
}

int main(int argc, char *argv[]) {
  AVFormatContext *pFormatCtx = NULL;
  int             i, videoStream;
  AVCodecContext  *pCodecCtx = NULL;
  AVCodec         *pCodec = NULL;
  AVFrame         *pFrame = NULL; 
  AVFrame         *pFrameRGB = NULL;
  AVPacket        packet;
  int             frameFinished;
  int             numBytes;
  uint8_t         *buffer = NULL;

  AVDictionary    *optionsDict = NULL;
  struct SwsContext      *sws_ctx = NULL;

  // Real-Time Setup
  int do_exit;
  int count = 0;

  /* rt_task defined in rt_param.h
    struct rt_task {
  lt_t    exec_cost;
  lt_t    period;
  lt_t    relative_deadline;
  lt_t    phase;
  unsigned int  cpu;
  unsigned int  priority;
  task_class_t  cls;
  budget_policy_t  budget_policy;
  release_policy_t release_policy;
  */

  struct rt_task param;

  /* Setup task parameters */
  init_rt_task_param(&param);
  param.exec_cost = ms2ns(EXEC_COST);
  param.period = ms2ns(PERIOD);
  param.relative_deadline = ms2ns(RELATIVE_DEADLINE);

  /* What to do in the case of budget overruns? */
  param.budget_policy = NO_ENFORCEMENT;

  /* The task class parameter is ignored by most plugins. */
  param.cls = RT_CLASS_SOFT;

  /* The priority parameter is only used by fixed-priority plugins. */
  param.priority = LITMUS_LOWEST_PRIORITY;

  /* The task is in background mode upon startup. */ 

  // END REAL TIME SETUP

  /*****
   * 1) Command line paramter parsing would be done here.
   */
  if(argc < 2) {
    printf("Please provide a movie file\n");
    return -1;
  }

  /*****
   * 2) Work environment (e.g., global data structures, file data, etc.) would
   *    be setup here.
   */

  // Register all formats and codecs
  av_register_all();
  
  // Open video file
  if(avformat_open_input(&pFormatCtx, argv[1], NULL, NULL)!=0)
    return -1; // Couldn't open file
  
  // Retrieve stream information
  if(avformat_find_stream_info(pFormatCtx, NULL)<0)
    return -1; // Couldn't find stream information
  
  // Dump information about file onto standard error
  av_dump_format(pFormatCtx, 0, argv[1], 0);

  /*****
  * End Work Environment Setup
  */

  


  
  // Find the first video stream
  videoStream=-1;
  for(i=0; i<pFormatCtx->nb_streams; i++)
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
      videoStream=i;
      break;
    }
  if(videoStream==-1)
    return -1; // Didn't find a video stream
  
  // Get a pointer to the codec context for the video stream
  pCodecCtx=pFormatCtx->streams[videoStream]->codec;
  
  // Find the decoder for the video stream
  pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
  if(pCodec==NULL) {
    fprintf(stderr, "Unsupported codec!\n");
    return -1; // Codec not found
  }
  // Open codec
  if(avcodec_open2(pCodecCtx, pCodec, &optionsDict)<0)
    return -1; // Could not open codec
  
  // Allocate video frame
  pFrame=av_frame_alloc();
  
  // Allocate an AVFrame structure
  pFrameRGB=av_frame_alloc();
  if(pFrameRGB==NULL)
    return -1;
  
  // Determine required buffer size and allocate buffer
  numBytes=avpicture_get_size(PIX_FMT_RGB24, pCodecCtx->width,
			      pCodecCtx->height);
  buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));

  sws_ctx =
    sws_getContext
    (
        pCodecCtx->width,
        pCodecCtx->height,
        pCodecCtx->pix_fmt,
        pCodecCtx->width,
        pCodecCtx->height,
        PIX_FMT_RGB24,
        SWS_BILINEAR,
        NULL,
        NULL,
        NULL
    );
  
  // Assign appropriate parts of buffer to image planes in pFrameRGB
  // Note that pFrameRGB is an AVFrame, but AVFrame is a superset
  // of AVPicture
  avpicture_fill((AVPicture *)pFrameRGB, buffer, PIX_FMT_RGB24,
		 pCodecCtx->width, pCodecCtx->height);

  /*****
   * 3) Setup real-time parameters. 
   *    In this example, we create a sporadic task that does not specify a 
   *    target partition (and thus is intended to run under global scheduling). 
   *    If this were to execute under a partitioned scheduler, it would be assigned
   *    to the first partition (since partitioning is performed offline).
   */
  CALL( init_litmus() );  // Defined in litmus.h

  /* To specify a partition, do
   *
   * param.cpu = CPU;
   * be_migrate_to(CPU);
   *
   * where CPU ranges from 0 to "Number of CPUs" - 1 before calling
   * set_rt_task_param().
   */
  CALL( set_rt_task_param(gettid(), &param) );  // Defined in litmus.h

  /*****
   * 4) Transition to real-time mode.
   */
  CALL( task_mode(LITMUS_RT_TASK) );  // Defined in litmus.h

  /* The task is now executing as a real-time task if the call didn't fail. */

  
  // Read frames and save first five frames to disk
  i=0;
  while(av_read_frame(pFormatCtx, &packet)>=0) {
    /* Wait until the next job is released. */
    sleep_next_period();
    // Print frame number
    printf("Frame %d\n", i);
    // Is this a packet from the video stream?
    if(packet.stream_index==videoStream) {
      // Decode video frame
      avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, 
			   &packet);
      
      // Did we get a video frame?
      if(frameFinished) {
	// Convert the image from its native format to RGB
        sws_scale
        (
            sws_ctx,
            (uint8_t const * const *)pFrame->data,
            pFrame->linesize,
            0,
            pCodecCtx->height,
            pFrameRGB->data,
            pFrameRGB->linesize
        );
	
	// Save the frame to disk
	if(++i<=5)
	  SaveFrame(pFrameRGB, pCodecCtx->width, pCodecCtx->height, 
		    i);
      }
    }
    
    // Free the packet that was allocated by av_read_frame
    av_free_packet(&packet);
  }

  /*****
  * 6) Transition to background mode.
  */
  CALL( task_mode(BACKGROUND_TASK) );
  
  // Free the RGB image
  av_free(buffer);
  av_free(pFrameRGB);
  
  // Free the YUV frame
  av_free(pFrame);
  
  // Close the codec
  avcodec_close(pCodecCtx);
  
  // Close the video file
  avformat_close_input(&pFormatCtx);


  /***** 
   * 7) Clean up, maybe print results and stats, and exit.
   */
  
  return 0;
}