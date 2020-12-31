import PIML from "./piml.min.js";

(function() {
    function setPreviewValue(previewEl, value) {
        previewEl.innerHTML = PIML.parse(value);
    }

    let frontInput = document.getElementById("front-input"),
        frontPreview = document.getElementById("front-preview"),
        backInput = document.getElementById("back-input"),
        backPreview = document.getElementById("back-preview"),
        form = document.getElementById("cardForm"),
        inputPreviewMap = {
            "front-input": frontPreview,
            "back-input": backPreview
        };

    form.addEventListener("keyup", e => {
        let previewEl = inputPreviewMap[e.target.id];

        if (!previewEl) {
            return;
        }

        setPreviewValue(previewEl, e.target.value);
    });

    setPreviewValue(frontPreview, frontInput.value);
    setPreviewValue(backPreview, backInput.value);
})();
