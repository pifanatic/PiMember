let params = new URLSearchParams(window.location.search);

if (params.has("q")) {
    let query = params.get("q"),
        els = document.querySelectorAll("[highlightable]"),
        regex = new RegExp(`(${query})`, "i");

    els.forEach(el => {
        let match = el.innerHTML.match(regex)

        if (match) {
            el.innerHTML = el.innerHTML.replaceAll(match[0], `<span class="highlight">${match[1]}</span>`);
        }
    });
}
