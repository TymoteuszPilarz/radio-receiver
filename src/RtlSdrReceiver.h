//
// Created by Tymoteusz Pilarz on 11/11/2023.
//

#ifndef RTLSDR_FM_RECEIVER_RTLSDRRECEIVER_H
#define RTLSDR_FM_RECEIVER_RTLSDRRECEIVER_H

#include <vector>
#include <complex>
#include <stdexcept>
#include <string>
#include <memory>
#include <utility>

#include <rtl-sdr.h>

/**
 * @brief Class representing RTL-SDR device
 */
class RtlSdrReceiver
{
public:
    /**
     * @brief Opens the RTL-SDR device with given parameters
     * @param deviceIndex Index of RTL-SDR device corresponding to the USB port number if more than one devices are plugged-in.
     * If only single device is connected, its index will be equal to 0
     * @param frequency Center frequency in Hz
     * @param samplingRate Sampling frequency in Hz. Possible values are: 225001-300000 and 900001-3200000
     * @param bufferSize Number of IQ samples in buffer, must be a power of 2
     * @param gain Tuner gain in dB. This parameter is ignored if the tuner automatic gain mode is successfully enabled
     * @param ppm Frequency correction value in ppm
     * @param autoGain Enables tuner automatic gain mode if the device support this feature, otherwise \p gain parameter is used
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    RtlSdrReceiver(int deviceIndex, int frequency, int samplingRate, int bufferSize, float gain = 0, int ppm = 0,
                   bool autoGain = false);

    /**
     * @brief Sets the center frequency
     * @param frequency Center frequency in Hz
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void SetFrequency(int frequency);

    /**
     * @brief Sets the sampling rate
     * @param samplingRate Sampling frequency in Hz. Possible values are: 225001-300000 and 900001-3200000
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void SetSamplingRate(int samplingRate);

    /**
     * @brief Sets the size of the IQ samples buffer
     * @param bufferSize Number of IQ samples in buffer, must be a power of 2
     */
    void SetBufferSize(int bufferSize);

    /**
     * @brief Sets the tuner gain
     * @param gain Tuner gain in dB
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void SetGain(float gain);

    /**
     * @brief Sets the tuner automatic gain mode if supported by the device
     * @return \c true on success, \c false on failure
     */
    bool SetAutoGain();

    /**
     * @brief Sets the frequency correction value
     * @param ppm Frequency correction value in ppm
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void SetFrequencyCorrection(int ppm);

    /**
     * @brief Resets the device buffer
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void ResetBuffer();

    /**
     * @brief Reads data from RTL-SDR device
     * @return A pair of IQ <begin, end> iterators of the samples buffer.
     * The length of the range defined by the pair of iterators depends on the number of elements read by this function.
     * Every sample has its real and imaginary part normalized to the range of [-1, 1]
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    std::pair<std::vector<std::complex<float>>::iterator, std::vector<std::complex<float>>::iterator> ReadIQData();

private:
    /**
     * @brief Custom deleter for \c rtlsdr_dev type
     */
    using deviceDeleter = decltype([](rtlsdr_dev* devicePtr)
    {
        rtlsdr_close(devicePtr);
    });

    /**
     * @brief RTL-SDR device pointer
     */
    std::unique_ptr<rtlsdr_dev, deviceDeleter> device;

    /**
     * @brief IQ samples buffer
     */
    std::vector<std::complex<uint8_t>> buffer;
    std::vector<std::complex<float>> normalizedBuffer;

    /**
     * @brief Finds the nearest tuner gain value to the one specified in the \p targetGain parameter
     * @param targetGain Desired tuner gain in dB * 10
     * @return The nearest tuner gain value to the one specified in the \p targetGain parameter
     * that is supported by the device or 0 on failure
     */
    int GetNearestGain(int targetGain);

protected:
    /**
     * @brief Returns device pointer allowing the derived class to implement additional functionalities
     * @return Device pointer
     * @warning Do not free the memory referred by this pointer as it is managed by RtlSdrReceiver class
     */
    rtlsdr_dev* GetDevice();
};

/**
 * @brief Exception class used by RtlSdrReceiver
 */
class RtlSdrReceiverError : public std::runtime_error
{
public:
    /**
     * @brief Sets message string used by \p what() function
     * @param msg message
     */
    explicit RtlSdrReceiverError(const std::string& msg);

    /**
     * @brief Sets message string used by \p what() function
     * @param msg message
     */
    explicit RtlSdrReceiverError(const char* msg);
};

#endif //RTLSDR_FM_RECEIVER_RTLSDRRECEIVER_H
