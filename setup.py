from distutils.core import Extension, setup
from Cython.Build import cythonize

# define an extension that will be cythonized and compiled
ext = Extension(name="sndfile", sources=["sndfile.pyx"], libraries=["sndfile"])
setup(name="sndfile",
      version='1.0',
      description='LibSndFile Wrapper',
      author='Ameya Desai',
      author_email='ameya.desai.contact@gmail.com',
      url='https://ameyadesai.info',
      ext_modules=cythonize(ext, language_level = "3"))
