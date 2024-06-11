/**
 * Convert a suffix to a number.
 * @param suffix string
 * @return number
 * @example
 * convertAbbreviatedNumber('1.2k') // 1200
 * convertAbbreviatedNumber('49K')  // 49000
 * convertAbbreviatedNumber('124.2m') // 124200000
 */
function convertSuffixToNumber(suffix) {
    var number = parseFloat(suffix.match(/[\d.]+/)[0]);
    var suffixMatch = suffix.match(/[a-zA-Z]/);
    if (!suffixMatch) {
        return number;
    }
    var suffix = suffixMatch[0];
    if (!!suffix.match(/[a-zA-Z]/)) {
        suffix = suffix.toLowerCase();
    }
    
    var suffixes = {
        k: 1e3,
        m: 1e6,
        b: 1e9,
        t: 1e12,
        q: 1e15,
        s: 1e18,
        o: 1e21,
        n: 1e24
    };
    if (!suffixes[suffix]) {
        return number;
    }
    return number * suffixes[suffix];
}
