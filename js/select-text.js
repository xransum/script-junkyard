function selectText(el) {
    let sel, range;
    // Browser compatibility
    // older ie
    if (window.getSelection && document.createRange) {
        sel = window.getSelection();
        // creates range object
        // set range to elements range
        // remove window range
        // set window range
        window.setTimeout(function() {
            range = document.createRange();
            range.selectNodeContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }, 1);
    } else if (document.selection) {
        sel = document.selection.createRange();
        // creates range object
        // set raselectnge
        // call  event listener
        if (sel.text == '') {
            range = document.body.createTextRange();
            range.moveToElementText(el);
            range.select();
        }
    } else {
        // do nothing
    }
    return;
}