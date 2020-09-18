# sndfile

Cython wrapper for libsndfile. Other python libraries like wav etc are not compatible with a lot of wav formats. 
libsndfile is by far the best for reading/writing wav data, http://www.mega-nerd.com/libsndfile/

Objective of this is to read audio data for MIR so everything is reduced current to reading/writing mono audio, it would be very easy to map countless other functions available in libsndfile, more coming up.    

Also a big shout out to cython, did not imagine how easy it would be to map things to python, have mapped other private libraries I have written to python. Love it.
https://cython.org


### Installation
(Use python 3.6+)

```python
python setup.py install
```

Cleanup if required before build

```shell script
rm -fr ./build sndfile.c
```


### Usage

```python
python test.py
```

