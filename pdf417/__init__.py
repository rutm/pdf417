from PIL import Image
from PIL import ImageDraw
from ._pdf417 import PDF417


def write_to_ps(filename, barcode):
    cols = (barcode.bit_columns / 8) + 1

    with open(filename, 'w+') as f:
        f.write("/Times findfont\n12 scalefont setfont\n100 80 moveto\n(A PDF417 example.)show\n")
        f.write("stroke\n100 100 translate\n{0} {1} scale\n".format(
            barcode.bit_columns / 2.0,
            barcode.code_rows * 3 / 2.0)
        )
        f.write("{0} {1} 1 [{2} 0 0 {3} 0 {4}]{{<".format(
            barcode.bit_columns,
            barcode.code_rows,
            barcode.bit_columns,
            -barcode.code_rows,
            barcode.code_rows)
        )

        for index, bit in enumerate(barcode.bits):
            if not index % cols:
                f.write('\n')
            f.write('{:02X}'.format(bit & 0xFF))

        f.write("\n>}image\nshowpage\n")


def to_bitmap_chunks(barcode):
    bitmap = ''.join(['{:08b}'.format(x & 0xFF) for x in barcode.bits])
    amount = 8 * int(barcode.bit_rows)
    chunks = [bitmap[start:start + amount] for start in xrange(0, len(bitmap), amount)]

    return chunks


def write_to_png(filename, barcode, x_scale=3, y_scale=9, margin=3):

    full_width = (barcode.bit_columns * x_scale) + (margin * 2)
    full_height = (barcode.code_rows * y_scale) + (margin * 2)

    image = Image.new("RGB", (full_width, full_height), 'white')
    draw = ImageDraw.Draw(image)

    chunks = to_bitmap_chunks(barcode)

    x = margin
    y = margin

    for line in chunks:
        for bar in line:
            if int(bar):
                for xx in xrange(x, x + x_scale):
                    for yy in xrange(y, y + y_scale):
                        draw.point((xx, yy), fill='black')
            x += x_scale
        y += y_scale
        x = margin

    del draw

    image.save(filename, 'PNG')


