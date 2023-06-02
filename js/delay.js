/**
 * Delay function call until after a certain amount of 
 * time has passed since the last time it was called.
 * 
 * @param {function} callback
 * @param {number} ms
 * @return {function}
 */
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
