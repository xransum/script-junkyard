/** Delayed function execution.
 * 
 * When called consecutively, this function will delay the execution
 * of the callback function until the delay time has passed. This is
 * useful for functions that are called multiple times in a short
 * period of time, such as when a user is typing in a text box.
 * 
 * @author xransum <https://github.com/xransum>
 * @see https://github.com/xransum/script-junkyard/blob/main/js/delay.js
 * 
 * @param {function} callback The function to execute.
 * @param {number} ms The number of milliseconds to delay.
 * @returns {function} The callback function.
 * 
 * @example
 * var delayedFunction = delay(function() {
 *    console.log('Hello World!');
 * }, 1000);
 **/
function delay(callback, ms) {
    var timer = 0;
    return function() {
        var context = this;
        var args = arguments;

        clearTimeout(timer);
        timer = setTimeout(function() {
            callback.apply(context, args);
        }, ms || 0);
    };
}
