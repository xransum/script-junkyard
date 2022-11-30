function timedDelay(callback, ms) {
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