/*============================== jpeg2img ==============================*/
/* 
  
    This is a mex interface to the Independent Jpeg Group's (IJG)
    libjpeg library that can take in RGB and grayscale JPEG images, then
    output the RGB image array.  It is presumed that one has, in
    Matlab, a variable containing the compressed JPEG information
    (as opposed to a JPEG file, for which one would use imread).
   
    The syntaxes is:
      
        RGB  = jpeg2img(jpgBuffer);
        GRAY = jpeg2img(jpgBuffer); 
   
   RGB is a mxnx3 uint8 array containing the 24-bit image stored in
   the jpeg source data.
   
   GRAY is a mxn uint8 array containing the 8-bit grayscale image
   stored in the jpeg source data.
   
   
   KNOWN BUGS:
   -----------
   who knows?
  
   ENHANCEMENTS UNDER CONSIDERATION:
   ---------------------------------
   ???
   
   
   The IJG code is available at:
   ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
   

   Author: 	Copyright 1984-2006 The MathWorks, Inc.
   		$Revision: 1.1.6.3 $  $Date: 2006/10/04 22:54:39 $
   	
		Revised by Patricio A. Vela, pvela@gatech.edu

   Created:	2008/10/13
   Modified:	2008/10/13

   Version:	0.0.1
*/
/*============================== jpeg2img ==============================*/

static char rcsid[] = 
  "$Id: jpeg2img.c, v0.0.1 2008/10/13$";


#include <mex.h>
#include <stdio.h>
#include <setjmp.h>
#include <jpeglib.h>
#include <jerror.h>

EXTERN(void) jpeg_buffer_src JPP((j_decompress_ptr cinfo, JOCTET* inBuffer,
                                                             size_t bufflen));
static mxArray *ReadRgbJPEG(j_decompress_ptr cinfoPtr);
static mxArray *ReadGrayJPEG(j_decompress_ptr cinfoPtr);
static void my_error_exit (j_common_ptr cinfo);
static void my_output_message (j_common_ptr cinfo);

struct my_error_mgr {
  struct jpeg_error_mgr pub;	/* "public" fields */
  jmp_buf setjmp_buffer;	/* for return to caller */
};

typedef struct my_error_mgr *my_error_ptr;



#define mexBuffer	prhs[0]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{ 
mxArray *outArray;

JOCTET *inBuffer;
size_t bufflen;

struct jpeg_decompress_struct cinfo;
struct my_error_mgr jerr;

int current_row;


/*==(1) Parse arguments and extract jpeg data.				*/
if (nrhs < 1)
  mexErrMsgTxt("Not enough input arguments.");

if(!mxIsUint8(mexBuffer))
  mexErrMsgTxt("First argument is not a uint8 buffer.");

bufflen = mxGetM(mexBuffer) * mxGetN(mexBuffer) * sizeof(JOCTET); /* (?) */
inBuffer = (JOCTET*)mxGetPr(mexBuffer);


/*==(2) Initialize the jpeg decompression object.			*/
cinfo.err = jpeg_std_error(&jerr.pub);
jerr.pub.output_message = my_output_message;
jerr.pub.error_exit = my_error_exit;
if(setjmp(jerr.setjmp_buffer))		/* Error ocurred, abort process. */
 {
  jpeg_destroy_decompress(&cinfo);
  return;
 }
jpeg_create_decompress(&cinfo);

/*==(3) Instantiate the source information.				*/
jpeg_buffer_src(&cinfo, inBuffer, bufflen);
/* Somehow this worked without the function declaration.  Weird.  */
/* I guess the linker found it somehow. */

/*==(4) Read the jpg header to get info about size and color depth.	*/
jpeg_read_header(&cinfo, TRUE);
jpeg_start_decompress(&cinfo);
if (cinfo.output_components == 1) 
  outArray = ReadGrayJPEG(&cinfo);		/* grayscale. */
else 
  outArray = ReadRgbJPEG(&cinfo);		/* color. */

/*==(5) Clean up							*/

jpeg_finish_decompress(&cinfo);
jpeg_destroy_decompress(&cinfo);

/*==(6) Set output.							*/
plhs[0]=outArray;
  
return;		
}


/*---------------------------- ReadRgbJPEG ---------------------------*/
/*
*/
static mxArray* ReadRgbJPEG(j_decompress_ptr cinfoPtr)
{
long i,j,k,row_stride;
int dims[3];                  /* For the call to mxCreateNumericArray */
mxArray *img;
JSAMPARRAY buffer;
int current_row;
uint8_T *pr_red, *pr_green, *pr_blue;

/*--(1) Allocate buffer for one scan line.	*/
row_stride = cinfoPtr->output_width * cinfoPtr->output_components;
buffer = (*cinfoPtr->mem->alloc_sarray)
    ((j_common_ptr) cinfoPtr, JPOOL_IMAGE, row_stride, 1);

/*--(2) Create 3 matrices, one for each channel.			*/
dims[0]  = cinfoPtr->output_height;
dims[1]  = cinfoPtr->output_width;
dims[2]  = 3;
img = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);

/*--(3) Get pointers to the real part of each matrix.  			*/
pr_red   = (uint8_T *) mxGetData(img);
pr_green = pr_red + (dims[0]*dims[1]);
pr_blue  = pr_red + (2*dims[0]*dims[1]);

while (cinfoPtr->output_scanline < cinfoPtr->output_height) 
 {
  current_row = cinfoPtr->output_scanline; /* Temp var won't get ++'d */
  jpeg_read_scanlines(cinfoPtr, buffer,1); /*  by jpeg_read_scanlines */
  for (i=0;i<cinfoPtr->output_width;i++) 
   {     
    j=(i)*cinfoPtr->output_height+current_row;       
    pr_red[j]   = buffer[0][i*3+0];
    pr_green[j] = buffer[0][i*3+1];
    pr_blue[j]  = buffer[0][i*3+2];
   }
 }
return img;
}


/*--------------------------- ReadGrayJPEG ---------------------------*/
/*
*/

static mxArray* ReadGrayJPEG(j_decompress_ptr cinfoPtr)
{
long i,j,k,row_stride;
int dims[3];                  /* For the call to mxCreateNumericArray */
mxArray *img;
JSAMPARRAY buffer;
int current_row;
uint8_T *pr_gray;
    
/*--(1) Allocate buffer for one scan line				*/
row_stride = cinfoPtr->output_width * cinfoPtr->output_components;
buffer = (*cinfoPtr->mem->alloc_sarray)
    ((j_common_ptr) cinfoPtr, JPOOL_IMAGE, row_stride, 1);

/*--(2) Create matrix, for output graylevels.				*/
dims[0]  = cinfoPtr->output_height;
dims[1]  = cinfoPtr->output_width;
dims[2]  = 1;

img = mxCreateNumericArray(2, dims, mxUINT8_CLASS, mxREAL);

/*--(3) Get pointers to the real part of each matrix .			*/
pr_gray   = (uint8_T *) mxGetData(img);

while (cinfoPtr->output_scanline < cinfoPtr->output_height) 
 {
  current_row=cinfoPtr->output_scanline; /* Temp var won't get ++'d */
  jpeg_read_scanlines(cinfoPtr, buffer,1); /*  by jpeg_read_scanlines */
  for (i=0;i<cinfoPtr->output_width;i++) 
   {     
    j=(i)*cinfoPtr->output_height+current_row;       
    pr_gray[j]   = buffer[0][i];
   }
 }
return img;
}


/*--------------------------- my_error_exit --------------------------*/
/* 
    Routine that replaces the standard error_exit method:
*/

static void my_error_exit (j_common_ptr cinfo)
{
/* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
my_error_ptr myerr = (my_error_ptr) cinfo->err;

if ((cinfo->err->msg_code == JERR_EMPTY_IMAGE)) 
 {
  /* We may be able to handle these.  The message may indicate that this
   * bit-depth and/or compression mode aren't supported by this "flavor"
   * of the library.  Continue on.  */
  return;
 }

/* Always display the message. */
/* We could postpone this until after returning, if we chose. */
(*cinfo->err->output_message) (cinfo);

/* Return control to the setjmp point */
longjmp(myerr->setjmp_buffer, 1);
}


/*------------------------- my_output_message ------------------------*/
/*  
    Routine to replace the standard output_message method:
*/
static void my_output_message (j_common_ptr cinfo)
{
char buffer[JMSG_LENGTH_MAX];

/* Create the message */
(*cinfo->err->format_message) (cinfo, buffer);

/* Send it to stderr, adding a newline */
mexWarnMsgTxt(buffer);
}

/**/
/*============================== jpeg2img ==============================*/
