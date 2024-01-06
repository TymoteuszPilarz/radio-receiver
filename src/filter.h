#include <iostream>
#include <vector>

// Function to compute the output of a rational transfer function
std::vector<double> filter(const std::vector<double>& numeratorCoeffs, const std::vector<double>& denominatorCoeffs, const std::vector<double>& inputSignal) {
    std::vector<double> outputSignal(inputSignal.size(), 0.0);

    int numOrder = numeratorCoeffs.size() - 1; // Order of the numerator
    int denOrder = denominatorCoeffs.size() - 1; // Order of the denominator

    // Iterate through the input signal
    for (size_t i = 0; i < inputSignal.size(); ++i) {
        double output = 0.0;

        // Compute the output of the transfer function at time index i
        for (int j = 0; j <= numOrder && i - j >= 0; ++j) {
            output += numeratorCoeffs[j] * inputSignal[i - j];
        }

        for (int j = 1; j <= denOrder && i - j >= 0; ++j) {
            output -= denominatorCoeffs[j] * outputSignal[i - j];
        }

        output /= denominatorCoeffs[0]; // Normalize by the denominator coefficient

        outputSignal[i] = output;
    }

    return outputSignal;
}


