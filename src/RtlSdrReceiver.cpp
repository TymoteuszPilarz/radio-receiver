//
// Created by Tymoteusz Pilarz on 11/11/2023.
//

#include <cassert>

#include "RtlSdrReceiver.h"

RtlSdrReceiver::RtlSdrReceiver(int deviceIndex, int frequency, int samplingRate, int bufferSize, float gain, int ppm,
                               bool autoGain)
{
    assert(deviceIndex >= 0);

    rtlsdr_dev* devicePtr;
    if (rtlsdr_open(&devicePtr, deviceIndex) != 0)
    {
        throw RtlSdrReceiverError("Failed to open the device");
    }

    device = std::unique_ptr<rtlsdr_dev, deviceDeleter>(devicePtr);

    SetFrequency(frequency);
    SetSamplingRate(samplingRate);
    SetBufferSize(bufferSize);

    if (autoGain)
    {
        if (!SetAutoGain())
        {
            SetGain(gain);
        }
    }
    else
    {
        SetGain(gain);
    }

    SetFrequencyCorrection(ppm);
    ResetBuffer();
}

void RtlSdrReceiver::SetFrequency(int frequency)
{
    assert(frequency >= 0);

    if (rtlsdr_set_center_freq(device.get(), frequency) != 0)
    {
        throw RtlSdrReceiverError("Failed to set the center frequency");
    }
}

void RtlSdrReceiver::SetSamplingRate(int samplingRate)
{
    assert((samplingRate >= 225001 && samplingRate <= 300000) || (samplingRate >= 900001 && samplingRate <= 3200000));

    if (rtlsdr_set_sample_rate(device.get(), samplingRate) != 0)
    {
        throw RtlSdrReceiverError("Failed to set the sampling rate");
    }
}

void RtlSdrReceiver::SetBufferSize(int bufferSize)
{
    assert((bufferSize > 0) &&
           ((bufferSize & (bufferSize - 1)) == 0)); // Efficient way to check if the given number is a power of 2

    buffer = std::vector<std::complex<uint8_t>>(bufferSize);
    normalizedBuffer = std::vector<std::complex<float>>(bufferSize);
}

void RtlSdrReceiver::SetGain(float gain)
{
    if (rtlsdr_set_tuner_gain_mode(device.get(), 1) != 0)
    {
        throw RtlSdrReceiverError("Failed to set the tuner gain mode to manual");
    }

    gain *= 10; // Required by rtl-sdr library
    int nearestGain = GetNearestGain(static_cast<int>(gain));
    if (nearestGain == 0)
    {
        throw RtlSdrReceiverError("Failed to get a list of supported gains by the tuner");
    }

    if (rtlsdr_set_tuner_gain(device.get(), nearestGain) != 0)
    {
        throw RtlSdrReceiverError("Failed to set the tuner gain");
    }
}

bool RtlSdrReceiver::SetAutoGain()
{
    if (rtlsdr_set_tuner_gain_mode(device.get(), 0) != 0)
    {
        return false;
    }

    return true;
}

void RtlSdrReceiver::SetFrequencyCorrection(int ppm)
{
    if (rtlsdr_get_freq_correction(device.get()) == ppm)
    {
        return;
    }

    if (rtlsdr_set_freq_correction(device.get(), ppm) != 0)
    {
        throw RtlSdrReceiverError("Failed to set the frequency correction value");
    }
}

void RtlSdrReceiver::ResetBuffer()
{
    if (rtlsdr_reset_buffer(device.get()) != 0)
    {
        throw RtlSdrReceiverError("Failed to reset the device buffer");
    }
}

std::pair<std::vector<std::complex<float>>::iterator, std::vector<std::complex<float>>::iterator>
RtlSdrReceiver::ReadIQData()
{
    int nRead; // number of bytes read
    if (rtlsdr_read_sync(device.get(), buffer.data(), static_cast<int>(buffer.size()) * 2, &nRead) != 0)
    {
        throw RtlSdrReceiverError("Failed to read samples from the device");
    }

    for (auto i = 0; i < buffer.size(); i++)
    {
        auto sample = std::complex<float>(buffer[i].real(), buffer[i].imag());
        sample -= std::complex(127.5, 127.5);
        sample /= 127.5;

        normalizedBuffer[i] = sample;
    }

    return {normalizedBuffer.begin(), normalizedBuffer.begin() + nRead / 2};
}

int RtlSdrReceiver::GetNearestGain(int targetGain)
{
    auto count = rtlsdr_get_tuner_gains(device.get(), nullptr);
    if (count == 0)
    {
        return 0;
    }

    int* gains = new int[count];
    count = rtlsdr_get_tuner_gains(device.get(), gains);

    auto nearest = gains[0];
    int err1, err2;

    for (auto i = 0; i < count; i++)
    {
        err1 = abs(targetGain - nearest);
        err2 = abs(targetGain - gains[i]);
        if (err2 < err1)
        {
            nearest = gains[i];
        }
    }

    delete[] gains;

    return nearest;
}

rtlsdr_dev* RtlSdrReceiver::GetDevice()
{
    return device.get();
}

RtlSdrReceiverError::RtlSdrReceiverError(const std::string& msg) : runtime_error(msg)
{
}

RtlSdrReceiverError::RtlSdrReceiverError(const char* msg) : runtime_error(msg)
{
}
