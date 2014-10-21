#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <stdio.h>

static AVFormatContext *p_fmt_ctx = NULL;
static AVCodecContext *p_codec_ctx = NULL;
static AVCodec *p_codec = NULL;
static AVFrame *p_frame = NULL;
static AVFrame *p_frame_RBG = NULL;
static AVPacket packet;
static AVDictionary *p_options_dict = NULL;

/* Open the inputfile, if file has a video stream,
 * fill out the static structs - p_fmt_ctx and
 * p_codec_ctx with relevant information
 */
static int open_file(const char *filename) {
    int ret;
    int i,video_stream_index;

    ret = avformat_open_input(&p_fmt_ctx,filename,NULL,NULL);
    if (ret != 0) {
        av_log(NULL, AV_LOG_ERROR, "Cannot open input file\n");
        return ret;
    }

    /* Get the stream info */
    ret = avformat_find_stream_info(p_fmt_ctx, NULL);
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "Cannot find stream info\n");
        return ret;
    }

    //for testing
    av_dump_format(p_fmt_ctx, 0, filename, 0);

    /* Select Video Stream */
    ret = av_find_best_stream(p_fmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, &p_codec, 0);
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "Cannot find a videostream in the inputfile");
        return ret;
    }

    video_stream_index = ret;
    p_codec_ctx = p_fmt_ctx->streams[video_stream_index]->codec;

    /* init the video decoder */
    ret = avcodec_open2(p_codec_ctx, p_codec, &p_options_dict);
    if(ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "Cannot open video decoder\n");
        return ret;
    }
    
    return 0;
}

int main() {
    av_register_all();
    open_file("../dark side of the moon.mp4");
}
