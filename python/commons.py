from .maths import gcd


# convert float to int, when arg force is False returns float if
# the value after conversion is unchanged.
def float_to_int(val, force=True):
    i = int(val)
    if force or i == val:
        return i
    return val

# get aspect ratio for a given size width, height.
def get_aspect_ratio(w, h):
    _gcd_ = gcd(w, h)
    wrat = float_to_int(round(w/_gcd_, 1), False)
    hrat = float_to_int(round(h/_gcd_, 1), False)
    return f'{hrat}:{wrat}'

