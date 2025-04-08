/**
 * An optimized version of dedent-js (https://www.npmjs.com/package/dedent-js)
 * 
 * @param {string|Array} content - The string or template literal to dedent
 * @param {...*} values - Values to interpolate into template literal
 * @returns {string} The dedented string
 */
function dedent(content, ...values) {
    // Use rest parameter syntax instead of arguments object
    let strings = Array.isArray(content) ? content : [content];
    
    // Combine regex operations and use more efficient string methods
    const lastString = strings[strings.length - 1].replace(/\r?\n[\t ]*$/, '');
    strings[strings.length - 1] = lastString;

    // Use more efficient matching approach
    const matches = strings
        .flatMap(str => str.match(/\n[\t ]+/g) || [])
        .map(value => value.length - 1);

    if (matches.length) {
        const size = Math.min(...matches);
        const pattern = new RegExp(`\n[\t ]{${size}}`, 'g');
        
        // Use map instead of for loop
        strings = strings.map(str => str.replace(pattern, '\n'));
    }

    // Remove leading whitespace
    strings[0] = strings[0].replace(/^\r?\n/, '');

    // Use template literals and reduce for string interpolation
    return values.reduce((result, value, i) => 
        result + value + strings[i + 1], strings[0]);
}
