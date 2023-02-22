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
 *   console.log(item);
 * }
 */
function untilExists(selector, target) {
    target = target ?? document;
    return new Promise((resolve, reject) => {
        try {
            let el = $(selector);
            if (el.length) {
                return resolve(el);
            }
            return new MutationObserver(function(mutations, observer) {
                el = $(selector);
                if (el.length) {
                    resolve(el);
                    observer.disconnect();
                }
            }).observe(target, {
                childList: true,
                subtree: true
            });
        } catch(e) {
            reject(e);
        }
    });
}
