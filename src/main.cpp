#include <iostream>

#include "RtlSdrReceiver.h"

const int numberOfFrames = 5000;

int main()
{
    try
    {
        RtlSdrReceiver rtlSdrReceiver(0, 96e6, 250000, pow(2, 10), 40);

        for (int i = 0; i < numberOfFrames; i++)
        {
            auto res = rtlSdrReceiver.ReadIQData();
            for (auto it = res.first; it != res.second; it++)
            {
                std::cout << it->real() << " " << it->imag() << '\n';
            }
            std::cout << std::endl;
        }
    }
    catch (const RtlSdrReceiverError& error)
    {
        std::cerr << error.what();
    }
}

