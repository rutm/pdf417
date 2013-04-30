import os
import sys
import sysconfig
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

here = os.path.abspath(os.path.dirname(__file__))

requires = [
    'cython',
    ]


ext_dir = os.path.join(here, 'ext')

def distutils_dir_name(dname):
    f = "{dirname}.{platform}-{version[0]}.{version[1]}"
    return f.format(dirname=dname,
                    platform=sysconfig.get_platform(),
                    version=sys.version_info)                


library_dirs = [ext_dir,
                '/usr/local/lib',
                '/usr/lib',
                '/opt/local/lib',
                os.path.join('build', distutils_dir_name('lib'))
                ]

include_dirs = [ext_dir,
                '/usr/local/include',
                '/usr/include',
                ]


ext_modules = [
    Extension('libpdf417',
                include_dirs=include_dirs,
                sources = ['ext/pdf417lib.c']
    ),
    Extension('pdf417._pdf417',
              ['pdf417/pdf417.pyx'],
              include_dirs=include_dirs,
              library_dirs=library_dirs,
              libraries=['pdf417'],
              extra_compile_args=[],
              define_macros=[('NDEBUG',)]
    )
]

setup(
    name='pdf417',
    description='Cython bindings for pdf417 library.',
    author="Alexey Gelyadov",
    author_email="gelaxe@gmail.com",
    url='https://github.com/rutm/pdf417',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Programming Language :: Cython',
        'Topic :: Software Development :: Libraries'
    ],

    packages=['pdf417'],
    cmdclass={'build_ext': build_ext},
    ext_modules=ext_modules,
    install_requires=requires,
)

