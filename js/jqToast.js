/**
 * Jquery toast wrapper function
 *
 * @requires jquery, jquery-toast
 * @param {string} text
 * @param {object} options
 * @returns {object} toast
 */
function toast(text, options = {}) {
    const defaultOptions = {
        // Text that is to be shown in the toast
        text: text,
        // Optional heading to be shown on the toast
        heading: "",
        // Type of toast icon
        icon: "",
        // fade, slide or plain
        showHideTransition: "fade",
        // Boolean value true or false
        allowToastClose: true,
        // false to make it sticky or number representing the miliseconds as time after which toast needs to be hidden
        hideAfter: 5000,
        // false if there should be only one toast at a time or a number representing the maximum number of toasts to be shown at a time
        stack: 5,
        // bottom-left or bottom-right or bottom-center or top-left or top-right or top-center or mid-center or an object representing the left, right, top, bottom values
        position: "bottom-left",
        // Background color of the toast
        // bgColor: '#444444',
        // Text color of the toast
        // textColor: '#eeeeee',
        // Text alignment i.e. left, right or center
        textAlign: "left",
        // Whether to show loader or not. True by default
        loader: true,
        // Background color of the toast loader
        // loaderBg: '#9EC600',
        // will be triggered before the toast is shown
        beforeShow: function(e, ui) {},
        // will be triggered after the toat has been shown
        afterShown: function(e, ui) {},
        // will be triggered before the toast gets hidden
        beforeHide: function(e, ui) {},
        // will be triggered after the toast has been hidden
        afterHidden: function(e, ui) {},
        
        // ui open triggers
        open: function(e, ui) {},
        beforeOpen: function(e, ui) {},
        afterOpen: function(e, ui) {},
        
        // ui closure triggers
        close: function(e, ui) {
            $(ui).remove();
        },
        beforeClose: function(e, ui) {},
        afterClose: function(e, ui) {},
    };
    var t = $.toast({
        // default options
        ...defaultOptions,
        // update default options with user options
        ...options,
    });
    return t;
}
