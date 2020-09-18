
import numpy as np

from csndfile cimport *

cdef class SndFileReader:
    cdef SNDFILE *hdl
    cdef object filename
    cdef SF_INFO _sfinfo

    def __init__(self, filename):
        cdef int sfmode
        sfmode = SFM_READ

        self.hdl = NULL

        # Fill the sfinfo struct
        self._sfinfo.frames = 0
        self._sfinfo.channels = 0
        self._sfinfo.samplerate = 0
        self._sfinfo.sections = 0
        self._sfinfo.format = 0
        self._sfinfo.seekable = SF_FALSE

        self.hdl = sf_open(filename, sfmode, & self._sfinfo)
        if self.hdl is NULL:
            raise RuntimeError(f"Failed to open file for reading {filename}")
        self.filename = filename
        if self._sfinfo.channels > 2:
            raise RuntimeError("Cannot Support More Than 2 Channels")

        print(f"Opened {filename} for reading")

    def __del__(self):
        self.close()

    def close(self):
        if self.hdl is not NULL:
            sf_close(self.hdl)
            self.hdl = NULL

    @property
    def totalFrames(self):
        return self._sfinfo.frames

    def getSamplingRate(self):
        return self._sfinfo.samplerate

    def getFormat(self):
        return self._sfinfo.format

    def readMonoFloat(self, frames):
        cdef SF_INFO info;
        cdef sf_count_t framesRead

        sf_command(self.hdl, SFC_GET_CURRENT_SF_INFO, &info, sizeof(info));

        cdef float[::1] data
        # Use Fortran order to cope with interleaving
        nArr = np.empty(frames * self._sfinfo.channels, dtype=np.float32)
        data = nArr

        framesRead = sf_readf_float(self.hdl, &data[0], frames)
        if self._sfinfo.channels == 1:
            #print(f"Channel = 1 {framesRead}")
            return nArr[:framesRead]
        elif self._sfinfo.channels == 2:
            #print(f"Channel = 2 {framesRead}")
            mono = np.empty(framesRead, dtype=np.float32)
            for curFrame in range(0, framesRead, 1):
                mono[curFrame] = ( nArr[curFrame*2] + nArr[curFrame*2+1] ) / 2

            #print(f"Returning mono data {mono}")
            return mono

        raise RuntimeError("Cannot Support More Than 2 Channels")


cdef class SndFileWriter:
    cdef SNDFILE *hdl
    cdef object filename
    cdef SF_INFO _sfinfo

    def __init__(self, filename, format, channels, samplingRate):
        cdef int sfmode
        sfmode = SFM_WRITE

        self.hdl = NULL

        # Fill the sfinfo struct
        self._sfinfo.channels = channels
        self._sfinfo.samplerate = samplingRate
        self._sfinfo.format = format
        self._sfinfo.sections = 0
        self._sfinfo.seekable = SF_FALSE

        self.hdl = sf_open(filename, sfmode, & self._sfinfo)
        if self.hdl is NULL:
            raise RuntimeError(f"Failed to open file for writing {filename}")
        self.filename = filename

        print(f"Opened File {filename} for writing")

    def __del__(self):
        self.close()

    def close(self):
        if self.hdl is not NULL:
            sf_write_sync(self.hdl)
            sf_close(self.hdl)
            self.hdl = NULL

    def writeFloat(self, data, frameCount):
        cdef sf_count_t framesWritten
        cdef float[::1] memView

        if not data.flags['C_CONTIGUOUS']:
            print("WARNING: Data for Writing is not a contiguous array, turning it into one, might violate interleaving, Fortran/C framing etc assumptions")
            data = np.ascontiguousarray(data)

        memView = data
        framesWritten = sf_writef_float(self.hdl, &memView[0], frameCount)
        if framesWritten != frameCount:
            raise RuntimeError(f"Requested {frameCount} frames to write, could write only {framesWritten}")

