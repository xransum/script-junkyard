/**
 * A function that will take a string and convert it to a valid lowercase id.
 * 
 * @param {String} str The string to convert.
 * 
 * @returns {String} The converted string.
 * 
 * @example
 * 
 * stringToId('Hello World');
 * // hello-world
 */
function stringToId(text) {
    let str = text;
    return str.toLowerCase().replace(/\W+/g, '-').replace(/\-{2,}/g, '-').replace(/^\-+|\-+$/g, '');
}
