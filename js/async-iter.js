/**
 * A function that iterates over an array and yields the value of each item in the array.
 *
 * @link       https://github.com/xransum/script-junkyard/blob/main/js/async-iter.js
 * @global
 *
 * @param {Array} arr - The array to iterate over.
 * @yield {Promise} A promise that will resolve with the value of the current item in the array.
 *
 * @example
 * var someItems = [1, 2, 3];
 * for await (let item of iter(someItems)) {
 *    console.log(item);
 * }
 *
 */
function* iter(arr) {
    let i = 0;
    while (i < arr.length) {
        yield Promise.resolve(arr[i], i);
        i++;
    }
}
