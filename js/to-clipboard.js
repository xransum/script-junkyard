function toClipboard(text) {
    const onSuccess = function() {
        if (typeof debugging !== 'undefined' && debugging === true) {
            console.debug("Successfully copied text to clipboard!");
        }
        return true;
    };
    const onError = function(err) {
        if (typeof debugging !== 'undefined' && debugging === true) {
            console.debug("Failed to copy text to clipboard...");
            console.error(err);
        }
    };
    
    var status = false;
    if (!navigator.clipboard) {
        var textArea = document.createElement("textarea");
        textArea.value = text;
        
        // Avoid scrolling to bottom
        textArea.style.top = "0";
        textArea.style.left = "0";
        textArea.style.position = "fixed";
        
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        
        try {
            if (document.execCommand('copy')) {
                status = onSuccess();
            }
        } catch (e) {
            onError(e);
        }
        
        document.body.removeChild(textArea);
    }
    
    if (!status) {
        navigator.clipboard.writeText(text).then(onSuccess, onError);
    }
    return;
}