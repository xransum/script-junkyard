/**
 * A function that will iterate over an array and yield the value of each item in the array.
 *  
 * @param {Array} arr The array to iterate over.
 *  
 * @returns {Promise} A promise that will resolve with the value of the current item in the array.
 *  
 * @example
 *  
 * var someItems = [1, 2, 3];
 * for await (let item of iter(someItems)) {
 *    console.log(item);
 * }
 */
function* iter(arr) {
    let i = 0;
    while (i < arr.length) {
        yield Promise.resolve(arr[i], i);
        i++;
    }
}
