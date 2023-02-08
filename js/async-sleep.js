/**
 * A function that will pause the execution of the script for the 
 * amount of milliseconds specified.
 *  
 * @param {number} ms The amount of milliseconds to pause the script for.
 *  
 * @returns {Promise} A promise that will resolve after the specified amount of time.
 *  
 * @example
 *  
 * await sleep(2000);
 */
function sleep(ms) {
    // Returns a promise to allow for better async stack support in case of errors.
    return new Promise((resolve) => {
        // setTimeout will call the resolve after the specified 
        // amount of time.
        setTimeout(resolve, ms);
    });
}
