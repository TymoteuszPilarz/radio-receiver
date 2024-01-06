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
#include <cassert>

#include <rtl-sdr.h>

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
    explicit RtlSdrReceiverError(const std::string& msg) : std::runtime_error(msg)
    {
    }

    /**
     * @brief Sets message string used by \p what() function
     * @param msg message
     */
    explicit RtlSdrReceiverError(const char* msg) : std::runtime_error(msg)
    {
    }
};

/**
 * @brief Class representing an RTL-SDR device
 * @tparam bufferSize Number of IQ samples in buffer, must be a power of 2
 * @tparam sampleRate Sampling frequency in Hz. Possible values are: 225001-300000 and 900001-3200000
 */
template <std::size_t bufferSize, std::size_t sampleRate = 250000>
class RtlSdrReceiver
{
    static_assert((bufferSize > 0) && ((bufferSize & (bufferSize - 1)) == 0)); // Check if bufferSize is a power of 2
    static_assert((sampleRate >= 225001 && sampleRate <= 300000) || (sampleRate >= 900001 && sampleRate <= 3200000));

public:
    /**
     * @brief Returns the number of currently plugged in RTL-SDR devices
     * @return Number of devices
     */
    static unsigned int GetNumOfDevices()
    {
        return rtlsdr_get_device_count();
    }

    /**
     * @brief Opens the RTL-SDR device with given parameters
     * @param iqBuffer Reference to the IQ samples buffer which will be filled after each \c ReadIQData() call
     * @param frequency Center frequency in Hz
     * @param autoGain Enables tuner automatic gain mode if the device support this feature, otherwise \p gain parameter is used
     * @param gain Tuner gain in dB. This parameter is ignored if the tuner automatic gain mode is successfully enabled
     * @param ppm Frequency correction value in ppm
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    RtlSdrReceiver(std::vector<std::complex<float>>& iqBuffer, int frequency, bool autoGain = false, float gain = 0, int ppm = 0) : iqBuffer(iqBuffer)
    {
        rtlsdr_dev* devicePtr;

        auto deviceCount = rtlsdr_get_device_count();
        bool success = false;
        for (auto i = 0; i < deviceCount; ++i)
        {
            if (rtlsdr_open(&devicePtr, i) == 0)
            {
                success = true;
                break;
            }
        }

        if (!success)
        {
            throw RtlSdrReceiverError("Failed to open the device");
        }

        device = std::unique_ptr<rtlsdr_dev, deviceDeleter>(devicePtr);

        SetFrequency(frequency);

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
    /**
     * @brief Sets the center frequency
     * @param frequency Center frequency in Hz
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void SetFrequency(int frequency)
    {
        assert(frequency >= 0);

        if (rtlsdr_set_center_freq(device.get(), frequency) != 0)
        {
            throw RtlSdrReceiverError("Failed to set the center frequency");
        }
    }

    /**
     * @brief Disables automatic gain mode, then sets the tuner gain
     * @param gain Tuner gain in dB
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void SetGain(float gain)
    {
        if (rtlsdr_set_tuner_gain_mode(device.get(), 1) != 0)
        {
            throw RtlSdrReceiverError("Failed to set the tuner gain mode to manual");
        }

        gain *= 10; // Required by rtl-sdr library
        auto nearestGain = GetNearestGain(static_cast<int>(gain));
        if (nearestGain == 0)
        {
            throw RtlSdrReceiverError("Failed to get a list of supported gains by the tuner");
        }

        if (rtlsdr_set_tuner_gain(device.get(), nearestGain) != 0)
        {
            throw RtlSdrReceiverError("Failed to set the tuner gain");
        }
    }

    /**
     * @brief Sets the tuner automatic gain mode if supported by the device
     * @return \c true on success, \c false on failure
     */
    bool SetAutoGain()
    {
        if (rtlsdr_set_tuner_gain_mode(device.get(), 0) != 0)
        {
            return false;
        }

        return true;
    }

    /**
     * @brief Sets the frequency correction value
     * @param ppm Frequency correction value in ppm
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void SetFrequencyCorrection(int ppm)
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

    /**
     * @brief Resets the device buffer
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void ResetBuffer()
    {
        if (rtlsdr_reset_buffer(device.get()) != 0)
        {
            throw RtlSdrReceiverError("Failed to reset the device buffer");
        }
    }

    /**
     * @brief Reads data from RTL-SDR device
     * @throw RtlSdrReceiverError. Use \c what() for more details
     */
    void ReadIQData()
    {
        int nRead; // number of bytes read
        if (rtlsdr_read_sync(device.get(), buffer.data(), static_cast<int>(bufferSize) * 2, &nRead) != 0)
        {
            throw RtlSdrReceiverError("Failed to read samples from the device");
        }

        for (auto i = 0; i < bufferSize; i++)
        {
            auto sample = std::complex<float>(buffer[i].real(), buffer[i].imag());
            sample -= std::complex(127.5, 127.5);
            sample /= 127.5;

            iqBuffer[i] = sample;
        }
    }

protected:
    /**
     * @brief Returns device pointer allowing the derived class to implement additional functionalities
     * @return Device pointer
     * @warning Do not free the memory referred by this pointer as it is managed by RtlSdrReceiver class
     */
    rtlsdr_dev* GetDevice()
    {
        return device.get();
    }

private:
    using deviceDeleter = decltype([](rtlsdr_dev* devicePtr)
    {
        rtlsdr_close(devicePtr);
    });
    std::unique_ptr<rtlsdr_dev, deviceDeleter> device;

    std::vector<std::complex<uint8_t>> buffer = std::vector<std::complex<uint8_t>>(bufferSize);
    std::vector<std::complex<float>>& iqBuffer;

    /**
     * @brief Finds the nearest tuner gain value to the one specified in the \p targetGain parameter
     * @param targetGain Desired tuner gain in dB * 10
     * @return The nearest tuner gain value to the one specified in the \p targetGain parameter
     * that is supported by the device or 0 on failure
     */
    int GetNearestGain(int targetGain)
    {
        auto count = rtlsdr_get_tuner_gains(device.get(), nullptr);
        if (count == 0)
        {
            return 0;
        }

        auto gains = new int[count];
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
};

#endif //RTLSDR_FM_RECEIVER_RTLSDRRECEIVER_H
