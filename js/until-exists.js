/** Wait for an element to exist.
 * 
 * This function will wait for an element to exist before resolving
 * the promise. This is useful for pages that load content via AJAX
 * and/or heavily dynamically intense content.
 * 
 * @author xransum <https://github.com/xransum>
 * @see https://github.com/xransum/script-junkyard/blob/main/js/until-exists.js
 * 
 * @param {string} selector The selector to wait for.
 * @param {HTMLElement} target The target element to observe.
 * @returns {Promise} A promise that will resolve with the element.
 * @promise {HTMLElement} The element that was found as a jQuery object.
 * 
 * @example
 * var el = await untilExists('#someElement');
 * console.log(el);
 **/
function untilExists(selector, target = document) {
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
