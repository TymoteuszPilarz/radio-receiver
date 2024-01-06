#ifndef RDS_DECODER_H
#define RDS_DECODER_H

#include"RtlSdrReceiver.h"
#include<cmath>

struct frequency
{
    float sampl = 250e3;
    float pilot = 19e3;
    float symb = pilot/16.0;
    float rds = 3.0 * pilot;
};



class RDSDecoder
{
    public:
    RDSDecoder();


    protected:

    frequency f;
    float xddd = 3.0*f.sampl;


    float f_sampl = 250e3;
    float f_samp_audio = 25e3;
    float f_pilot = 19e3;
    float f_symb = f_pilot/16.0;
    float f_rds = 3.0*f_pilot;
};













#endif //RDS_DECODER_H