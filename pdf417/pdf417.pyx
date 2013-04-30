from libc.stdlib cimport malloc, free
from cpython cimport bool

cdef extern from "pdf417lib.h":
    cdef struct _pdf417param:
        char *outBits
        int lenBits
        int bitColumns
        int codeRows
        int codeColumns
        int codewords[928]
        int lenCodewords
        int errorLevel
        char *text
        int lenText
        int options
        float aspectRatio
        float yHeight
        int error

    ctypedef _pdf417param pdf417param

    ctypedef _pdf417param *pPdf417param

    void paintCode(pPdf417param p)

    void pdf417init(pPdf417param param)

    void pdf417free(pPdf417param param)

    cdef:
        int PDF417_USE_ASPECT_RATIO
        int PDF417_FIXED_RECTANGLE
        int PDF417_FIXED_COLUMNS
        int PDF417_FIXED_ROWS
        int PDF417_AUTO_ERROR_LEVEL
        int PDF417_USE_ERROR_LEVEL
        int PDF417_USE_RAW_CODEWORDS
        int PDF417_INVERT_BITMAP

        int PDF417_ERROR_SUCCESS
        int PDF417_ERROR_TEXT_TOO_BIG
        int PDF417_ERROR_INVALID_PARAMS

cdef class PDF417:

    cdef:
        pdf417param *ptr

        int is_encode

        public int bit_columns
        public double bit_rows
        public int bit_length

        int _code_rows
        int _code_columns

        float _y_height
        float _aspect_ratio

        object _bits

        public int error_level
        public bool invert_bitmap

    def __cinit__(self):
        self.ptr = <pdf417param *>malloc(sizeof(pdf417param))
        if not self.ptr:
            raise MemoryError('memory allocation failed for self.ptr')

        pdf417init(self.ptr)

        self._bits = []

    def __dealloc__(self):
        self.cleanup()
        free(self.ptr)

    def __init__(self):
        self.is_encode = 0
        self.code_rows = 1
        self.code_columns = 0
        self.aspect_ratio = 0.5
        self.y_height = 3
        self.invert_bitmap = False
        self.error_level = 0

    property bits:

        def __get__(self):
            if not self.encode:
                raise AttributeError("Initially need to call encode function")

            for i in range(self.bit_length):
                self._bits.append(self.ptr.outBits[i])

            return self._bits

        def __set__(self, value):
            raise AttributeError(" 'bits' is read-only property")

        def __del__(self):
            del self._bits[:]

    property code_rows:

        def __get__(self):
            return self._code_rows

        def __set__(self, value):
            self._code_rows = int(value)

        def __del__(self):
            self._code_rows = 0

    property code_columns:

        def __get__(self):
            return self._code_columns

        def __set__(self, value):
            self._code_columns = int(value)

        def __del__(self):
            self._code_columns = 0

    property aspect_ratio:

        def __get__(self):
            return self._aspect_ratio

        def __set__(self, value):
            self._aspect_ratio = float(value)

        def __del__(self):
            self._aspect_ratio = 0

    property y_height:

        def __get__(self):
            return self._y_height

        def __set__(self, value):
            self._y_height = float(value)

        def __del__(self):
            self._y_height = 0

    def encode(self, text):
        if self.is_encode:
            raise Exception('Need to cleanup the object before re-use')

        byte_text = text.encode('UTF-8')
        self.ptr.text = byte_text

        if self.code_rows > 0 and self.code_columns > 0:
            self.ptr.codeRows = self.code_rows
            self.ptr.codeColumns = self.code_columns
            self.ptr.options |= PDF417_FIXED_RECTANGLE
        elif self.code_rows > 0:
            self.ptr.codeRows = self.code_rows
            self.ptr.options |= PDF417_FIXED_ROWS
        elif self.code_columns > 0:
            self.ptr.codeColumns = self.code_columns
            self.ptr.options |= PDF417_FIXED_COLUMNS

        self.ptr.aspectRatio = self.aspect_ratio
        self.ptr.yHeight = self.y_height

        if self.invert_bitmap:
            self.ptr.options |= PDF417_INVERT_BITMAP

        if 0 <= self.error_level <= 8:
            self.ptr.errorLevel = self.error_level
            self.ptr.options |= PDF417_USE_ERROR_LEVEL

        paintCode(self.ptr)

        if self.ptr.error != PDF417_ERROR_SUCCESS:
            raise Exception('Could not generate bitmap. Error code: {}'.format(self.ptr.error))

        self.bit_columns = self.ptr.bitColumns
        self.bit_rows = ((self.ptr.bitColumns - 1) / 8) + 1
        self.bit_length = self.ptr.lenBits
        self.code_rows = self.ptr.codeRows
        self.code_columns = self.ptr.codeColumns
        self.aspect_ratio = self.ptr.aspectRatio
        self.y_height = self.ptr.yHeight

        self.is_encode = 1

    def cleanup(self):
        if self.ptr.outBits:
            pdf417free(self.ptr)

        self.is_encode = 0

        del self.bits
