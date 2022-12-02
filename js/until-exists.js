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
            console.error(e);
        }
    });
}
