import Foundation
import PlaygroundSupport
import Accelerate

// A little playground helper function
func plotArrayInPlayground<T>(arrayToPlot:Array<T>, title:String) {
    for currentValue in arrayToPlot {
        XCPCaptureValue(identifier: title, value: currentValue)
    }
}

let sineArraySize = 64 // Should be power of two for the FFT

let frequency1 = 4.0
let phase1 = 0.0
let amplitude1 = 2.0
let sineWave = (0..<sineArraySize).map {
    amplitude1 * sin(2.0 * M_PI / Double(sineArraySize) * Double($0) * frequency1 + phase1)
}

let frequency2 = 1.0
let phase2 = M_PI / 2.0
let amplitude2 = 1.0
let sineWave2 = (0..<sineArraySize).map {
    amplitude2 * sin(2.0 * M_PI / Double(sineArraySize) * Double($0) * frequency2 + phase2)
}

plotArrayInPlayground(arrayToPlot: sineWave, title: "Sine wave 1")
plotArrayInPlayground(arrayToPlot: sineWave2, title: "Sine wave 2")

// Simple loop-based array addition
var combinedSineWave = [Double](repeating:0.0, count:sineArraySize)
for currentIndex in 0..<sineArraySize {
    combinedSineWave[currentIndex] = sineWave[currentIndex] + sineWave2[currentIndex]
}

// Accelerate-enabled array addition
infix operator  +++ {}
func +++ (a: [Double], b: [Double]) -> [Double] {
    assert(a.count == b.count, "Expected arrays of the same length, instead got arrays of two different lengths")

    var result = [Double](repeating:0.0, count:a.count)
    vDSP_vaddD(a, 1, b, 1, &result, 1, UInt(a.count))
    return result
}

let combinedSineWave2 = sineWave +++ sineWave2

plotArrayInPlayground(combinedSineWave, "Combined wave (loop addition)")
plotArrayInPlayground(arrayToPlot: combinedSineWave2, title: "Combined wave (Accelerate)")

// Wrapping vecLib in overloaded functions
func sqrt(x: [Double]) -> [Double] {
    var results = [Double](repeating:0.0, count:x.count)
    vvsqrt(&results, x, [Int32(x.count)])
    return results
}

sqrt(4.0)
sqrt([4.0, 3.0, 16.0])


// Accelerate-enabled FFT
let fft_weights: FFTSetupD = vDSP_create_fftsetupD(vDSP_Length(log2(Float(sineArraySize))), FFTRadix(kFFTRadix2))!

func fft( inputArray:[Double]) -> [Double] {
    var inputArray = inputArray
    var fftMagnitudes = [Double](repeating:0.0, count:inputArray.count)
    var zeroArray = [Double](repeating:0.0, count:inputArray.count)
    var splitComplexInput = DSPDoubleSplitComplex(realp: &inputArray, imagp: &zeroArray)
    
    vDSP_fft_zipD(fft_weights, &splitComplexInput, 1, vDSP_Length(log2(CDouble(inputArray.count))), FFTDirection(FFT_FORWARD));
    vDSP_zvmagsD(&splitComplexInput, 1, &fftMagnitudes, 1, vDSP_Length(inputArray.count));

    let roots = sqrt(fftMagnitudes) // vDSP_zvmagsD returns squares of the FFT magnitudes, so take the root here
    var normalizedValues = [Double](repeating:0.0, count:inputArray.count)

    vDSP_vsmulD(roots, vDSP_Stride(1), [2.0 / Double(inputArray.count)], &normalizedValues, vDSP_Stride(1), vDSP_Length(inputArray.count))
    return normalizedValues
}

let fftOfWave1 = fft(inputArray: sineWave)
let fftOfWave2 = fft(inputArray: sineWave2)
let fftOfWave3 = fft(combinedSineWave)

fftOfWave1.filter {$0 > 0.1}

//func filter(includeElement: (T) -> Bool) -> [T]

extension Slice {
    func filterWithIndicesAdjustedByMultiplier(indexAdjustment:Double, includeElement: (T) -> Bool) -> [(Double, T)] {
        var filterResults: [(Double, T)] = []
        for (index, arrayElement) in enumerate(self) {
            let t = arrayElement as T;
            if includeElement(t) {
                filterResults.append(Double(index) * indexAdjustment, t)
            }
        }
        return filterResults
    }
}

plotArrayInPlayground(fftOfWave1, "FFT of sine wave 1")
plotArrayInPlayground(fftOfWave2, "FFT of sine wave 2")
plotArrayInPlayground(fftOfWave3, "FFT of combined sine waves")

let amplitudeThreshold = 0.00001
func identifyFrequenciesAndAmplitudesOfWaveform(waveform:[Double]) -> [(Double, Double)] {
    let fftOfWaveform = fft(inputArray: waveform)
    let halfFFT = fftOfWaveform[0..<(waveform.count / 2)]
    return halfFFT.filterWithIndicesAdjustedByMultiplier(1.0) { $0 > amplitudeThreshold }
}

identifyFrequenciesAndAmplitudesOfWaveform(waveform: sineWave)
identifyFrequenciesAndAmplitudesOfWaveform(waveform: sineWave2)
identifyFrequenciesAndAmplitudesOfWaveform(combinedSineWave)

