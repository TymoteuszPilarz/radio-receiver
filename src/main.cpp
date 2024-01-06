#include <iostream>
#include <complex>
#include <vector>

#include "RtlSdrReceiver.h"

constexpr std::size_t bufferSize = 32768;
constexpr int frequency = 105900000;
constexpr float gain = 40.f;
constexpr int numberOfFrames = 5000;

int main()
{
    try
    {
        std::vector<std::complex<float>> iqBuffer(bufferSize);
        RtlSdrReceiver<bufferSize> rtlSdrReceiver(iqBuffer, frequency, false, gain);

        for (auto i = 0; i < numberOfFrames; i++)
        {
            rtlSdrReceiver.ReadIQData();
            for (const auto& elem : iqBuffer)
            {
                std::cout << elem.real() << " " << elem.imag() << '\n';
            }
            std::cout << std::endl;
        }
    }
    catch (const RtlSdrReceiverError& error)
    {
        std::cerr << error.what();
    }
}

