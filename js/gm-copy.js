/**
 * A wrapper function for copying text to user clipboard with a status toast.
 *
 * @link       https://github.com/xransum/script-junkyard/blob/main/js/gm-copy.js
 * @global
 * 
 * @see        https://wiki.greasespot.net/GM.setClipboard
 * @see        https://github.com/xransum/script-junkyard/blob/main/js/jq-toast.js
 *
 * @param {string} text - Text to copy.
 *
 * @example
 * gmCopyText("abc");
 *
 */
function gmCopyText(text) {
    try {
        GM_setClipboard(text);
        toast("Text copied to clipboard!");
    } catch (e) {
        toast("Text copied to clipboard!", {
            icon: "error"
        });
    }
}
