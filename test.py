import sndfile
import matplotlib.pyplot as plt
import numpy as np

samples = None

sndFileReader = sndfile.SndFileReader(b"./test.wav")
sndFileWriter = sndfile.SndFileWriter(b"./testout.wav", sndFileReader.getFormat(), 1, sndFileReader.getSamplingRate())

data = sndFileReader.readMonoFloat(8192)
while data is not None and data.size > 0:

    if samples is None:
        samples = data
    else:
        samples = np.append(samples, data)

    sndFileWriter.writeFloat(data, data.size)
    data = sndFileReader.readMonoFloat(8192)

sndFileWriter.close()

x = np.arange(0, samples.size, 1)
plt.plot(x, samples)
plt.show()
