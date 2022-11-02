/** A function that returns a promise that resolves after determining the
 * window that the script is running in is the root window instead of being 
 * injected within an iframe.
 * 
 * Examples -
 * Example 1:
 *    strictWindow(function() {
 *        'use strict';
 *        // code here
 *    });
 *  
 * Example 2:
 *     (async function() {
 *          await strictWindow();
 *          // Your code here
 *     })();
 *  
 * Example 3:
 *     (function(factory) {
 *         strictWindow(factory);
 *     })(function() {
 *         'use strict';
 *         // code here
 *     });
 *  
 * @param callback {function} - optional callback function to be executed when resolved.
 * @returns {Promise} - a promise that resolves when the window is root.
 **/
function strictWindow(callback) {
    return new Promise((resolve, reject) => {
        if (window.top === window.self) {
            /** The frames object does not play nice with unsafeWindow.
             *
             * These next three work in Firefox, but not Tampermonkey, nor pure Chrome.
             * console.log ("Ex: 1", frames[1].variableOfInterest);                // undefined
             * console.log ("Ex: 2", unsafeWindow.frames[1].variableOfInterest);   // undefined
             * console.log ("Ex: 3", frames[1].unsafeWindow);                      // undefined
             *
             * This will throw a silent crash to all browsers.
             * console.log ("Ex: 4", unsafeWindow.frames[1].unsafeWindow.variableOfInterest);
             **/
            
            // Aside from the above, we can resolve the Promise and continue.
            console.debug("Userscript detected to be running in main window.");
            resolve();
            
            if (typeof(callback) === 'function') {
                callback();
            }
        } else {
            console.debug("Detected Userscript trying to be run within an iframe.", "Frame ID: " + window.self.frameElement.id);
          	// Don't need to reject since the intent is to be strict, no need to require catch exceptions.
            // reject();
        }
        return;
    });
}
