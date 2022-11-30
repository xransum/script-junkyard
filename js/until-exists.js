function untilExists(selector, target) {
    target = target ?? document.body;

    return new Promise((resolve, reject) => {
        var el = $(selector);
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
    });
}
